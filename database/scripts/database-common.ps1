Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:L2DatabaseName = 'l2jmobiusinterlude'
$script:L2DatabaseUser = 'l2server'
$script:L2DatabaseHost = '127.0.0.1'
$script:L2DatabasePort = 3306

function Get-L2RepositoryRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

function Get-L2MariaDbBinDirectory {
    $service = Get-CimInstance Win32_Service |
        Where-Object Name -eq 'MariaDB' |
        Select-Object -First 1

    if (-not $service) {
        throw 'The MariaDB Windows service was not found.'
    }

    $match = [regex]::Match([string]$service.PathName, '^"([^"]+)"')
    if (-not $match.Success) {
        throw 'Unable to determine the MariaDB service executable.'
    }

    $binDirectory = Split-Path $match.Groups[1].Value -Parent
    foreach ($tool in @('mariadb.exe', 'mariadb-dump.exe')) {
        $toolPath = Join-Path $binDirectory $tool
        if (-not (Test-Path -LiteralPath $toolPath -PathType Leaf)) {
            throw "Required MariaDB tool was not found: $toolPath"
        }
    }

    return $binDirectory
}

function Assert-L2MariaDbLocal {
    $service = Get-Service -Name 'MariaDB' -ErrorAction SilentlyContinue
    if (-not $service) {
        throw 'The MariaDB service was not found.'
    }
    if ($service.Status -ne 'Running') {
        throw "The MariaDB service is not running. Current state: $($service.Status)"
    }

    $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $script:L2DatabasePort -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) {
        throw "MariaDB is not listening on port $script:L2DatabasePort."
    }

    $unsafeListeners = @($listeners | Where-Object LocalAddress -ne $script:L2DatabaseHost)
    if ($unsafeListeners.Count -gt 0) {
        $addresses = ($unsafeListeners.LocalAddress | Sort-Object -Unique) -join ', '
        throw "MariaDB has non-local listeners: $addresses"
    }
}

function ConvertFrom-L2SecureString {
    param(
        [Parameter(Mandatory)]
        [Security.SecureString]$SecureString
    )

    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    }
}

function Invoke-L2MariaDbSql {
    param(
        [Parameter(Mandatory)]
        [string]$User,

        [Parameter(Mandatory)]
        [string]$PlainTextPassword,

        [Parameter(Mandatory)]
        [string]$Sql,

        [string]$Database,

        [string[]]$SensitiveValues = @()
    )

    $clientPath = Join-Path (Get-L2MariaDbBinDirectory) 'mariadb.exe'
    $arguments = @(
        '--protocol=TCP',
        "--host=$script:L2DatabaseHost",
        "--port=$script:L2DatabasePort",
        "--user=$User",
        '--connect-timeout=10',
        '--default-character-set=utf8',
        '--batch',
        '--raw',
        '--skip-column-names',
        '--show-warnings'
    )
    if ($Database) {
        $arguments += "--database=$Database"
    }

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $clientPath
    $startInfo.Arguments = $arguments -join ' '
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.EnvironmentVariables['MYSQL_PWD'] = $PlainTextPassword

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo

    try {
        if (-not $process.Start()) {
            throw 'MariaDB client process did not start.'
        }

        $sqlBytes = [Text.UTF8Encoding]::new($false).GetBytes($Sql)
        $process.StandardInput.BaseStream.Write($sqlBytes, 0, $sqlBytes.Length)
        $process.StandardInput.Close()
        $standardOutput = $process.StandardOutput.ReadToEnd()
        $standardError = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        if ($process.ExitCode -ne 0) {
            $sanitizedError = $standardError
            foreach ($secret in @($PlainTextPassword) + $SensitiveValues) {
                if ($secret) {
                    $sanitizedError = $sanitizedError.Replace($secret, '***')
                }
            }
            throw "MariaDB client failed with exit code $($process.ExitCode): $($sanitizedError.Trim())"
        }

        return $standardOutput.Trim()
    }
    finally {
        $process.Dispose()
    }
}

function New-L2DatabasePassword {
    $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!#$%&*+,-.:=?@^_~'
    $bytes = New-Object byte[] 32
    $generator = [Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $generator.GetBytes($bytes)
    }
    finally {
        $generator.Dispose()
    }

    $characters = foreach ($value in $bytes) {
        $alphabet[$value % $alphabet.Length]
    }
    return -join $characters
}

function Get-L2DatabaseCredentialPath {
    return Join-Path (Get-L2RepositoryRoot) 'secrets\l2server.credential.xml'
}

function Get-L2DatabaseCredential {
    $credentialPath = Get-L2DatabaseCredentialPath
    if (-not (Test-Path -LiteralPath $credentialPath -PathType Leaf)) {
        throw "The protected database credential was not found: $credentialPath"
    }

    $credential = Import-Clixml -LiteralPath $credentialPath
    if ($credential.UserName -ne $script:L2DatabaseUser) {
        throw "Unexpected database credential user: $($credential.UserName)"
    }

    return $credential
}

function Invoke-L2DatabaseServiceState {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Running', 'Stopped')]
        [string]$DesiredState
    )

    $verb = if ($DesiredState -eq 'Running') { 'Start-Service' } else { 'Stop-Service' }
    $scriptText = @"
`$ErrorActionPreference = 'Stop'
$verb -Name 'MariaDB'
(Get-Service -Name 'MariaDB').WaitForStatus('$DesiredState', [TimeSpan]::FromSeconds(30))
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptText))
    $process = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList @(
        '-NoProfile',
        '-EncodedCommand',
        $encoded
    )

    if ($process.ExitCode -ne 0) {
        throw "Unable to set MariaDB service state to $DesiredState. Exit code: $($process.ExitCode)"
    }
}
