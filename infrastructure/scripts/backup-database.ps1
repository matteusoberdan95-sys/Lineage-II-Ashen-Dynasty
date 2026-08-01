[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$plainTextPassword = $null
$temporarySqlPath = $null

try {
    Assert-L2MariaDbLocal

    $credential = Get-L2DatabaseCredential
    $plainTextPassword = ConvertFrom-L2SecureString -SecureString $credential.Password
    $dumpTool = Join-Path (Get-L2MariaDbBinDirectory) 'mariadb-dump.exe'
    $backupDirectory = Join-Path (Get-L2RepositoryRoot) 'database\backups'
    if (-not (Test-Path -LiteralPath $backupDirectory)) {
        $null = New-Item -ItemType Directory -Path $backupDirectory
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $temporarySqlPath = Join-Path $backupDirectory "$script:L2DatabaseName`_$timestamp.sql"
    $backupPath = "$temporarySqlPath.gz"

    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $dumpTool
    $startInfo.Arguments = @(
        '--protocol=TCP',
        "--host=$script:L2DatabaseHost",
        "--port=$script:L2DatabasePort",
        "--user=$script:L2DatabaseUser",
        '--default-character-set=utf8',
        '--single-transaction',
        '--quick',
        '--skip-lock-tables',
        '--hex-blob',
        '--databases',
        $script:L2DatabaseName
    ) -join ' '
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.EnvironmentVariables['MYSQL_PWD'] = $plainTextPassword

    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo

    try {
        if (-not $process.Start()) {
            throw 'mariadb-dump did not start.'
        }

        $fileStream = [IO.File]::Create($temporarySqlPath)
        try {
            $process.StandardOutput.BaseStream.CopyTo($fileStream)
        }
        finally {
            $fileStream.Dispose()
        }

        $standardError = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) {
            $sanitizedError = $standardError.Replace($plainTextPassword, '***')
            throw "mariadb-dump failed with exit code $($process.ExitCode): $($sanitizedError.Trim())"
        }
    }
    finally {
        $process.Dispose()
    }

    if ((Get-Item -LiteralPath $temporarySqlPath).Length -eq 0) {
        throw 'mariadb-dump generated an empty file.'
    }

    $inputStream = [IO.File]::OpenRead($temporarySqlPath)
    $outputStream = [IO.File]::Create($backupPath)
    $gzipStream = [IO.Compression.GZipStream]::new(
        $outputStream,
        [IO.Compression.CompressionLevel]::Optimal
    )
    try {
        $inputStream.CopyTo($gzipStream)
    }
    finally {
        $gzipStream.Dispose()
        $outputStream.Dispose()
        $inputStream.Dispose()
    }

    Remove-Item -LiteralPath $temporarySqlPath -Force
    $temporarySqlPath = $null

    $backupItem = Get-Item -LiteralPath $backupPath
    $backupHash = (Get-FileHash -LiteralPath $backupPath -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Host "Backup created: $backupPath"
    Write-Host "Size: $($backupItem.Length) bytes"
    Write-Host "SHA-256: $backupHash"

    $plainTextPassword = $null
    exit 0
}
catch {
    if ($temporarySqlPath -and (Test-Path -LiteralPath $temporarySqlPath)) {
        Remove-Item -LiteralPath $temporarySqlPath -Force
    }
    $plainTextPassword = $null
    Write-Error "Database backup failed: $($_.Exception.Message)"
    exit 1
}
