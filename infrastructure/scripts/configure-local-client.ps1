[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [string]$ClientRoot = 'D:\L2-ASHEN-DYNASTY'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    & (Join-Path $PSScriptRoot 'ensure-l2encdec.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw "ensure-l2encdec.ps1 failed with exit code $LASTEXITCODE"
    }

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $toolPath = Join-Path $repositoryRoot 'server\runtime\tools\l2encdec\l2encdec_win.exe'
    $systemPath = Join-Path $ClientRoot 'system'
    $l2IniPath = Join-Path $systemPath 'l2.ini'
    $l2ExePath = Join-Path $systemPath 'L2.exe'

    if (-not (Test-Path -LiteralPath $ClientRoot -PathType Container)) {
        throw "Client root was not found: $ClientRoot"
    }
    foreach ($requiredPath in @($toolPath, $l2IniPath, $l2ExePath)) {
        if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
            throw "Required file was not found: $requiredPath"
        }
    }
    if (Test-Path -LiteralPath (Join-Path $ClientRoot 'System L2Agonia')) {
        throw 'Refusing a custom L2Agonia client. Use the clean L2-ASHEN-DYNASTY client.'
    }
    foreach ($bannedName in @('CliExt.dll', 'entry.dll')) {
        if (Test-Path -LiteralPath (Join-Path $systemPath $bannedName)) {
            throw "Refusing client with custom binary: $bannedName"
        }
    }

    $localRoot = Join-Path $ClientRoot '.ashen-local'
    if (-not (Test-Path -LiteralPath $localRoot)) {
        $null = New-Item -ItemType Directory -Path $localRoot
    }

    $decodedPath = Join-Path $localRoot 'l2.decoded.ini'
    $encodedPath = Join-Path $localRoot 'l2.encoded.ini'
    $verifyPath = Join-Path $localRoot 'l2.verify.ini'

    & $toolPath -c decode -p 413 -o $decodedPath $l2IniPath
    if ($LASTEXITCODE -ne 0) {
        throw "l2.ini decode failed with exit code $LASTEXITCODE"
    }

    $decoded = Get-Content -LiteralPath $decodedPath -Raw -Encoding Default
    if ($decoded -notmatch '(?im)^ServerAddr=') {
        throw 'Decoded l2.ini does not contain ServerAddr.'
    }

    $currentAddress = ([regex]::Match($decoded, '(?im)^ServerAddr=(.*)$')).Groups[1].Value.Trim()
    if ($currentAddress -eq '127.0.0.1') {
        Write-Host "Client already targets ServerAddr=127.0.0.1"
        Write-Host "Client root: $ClientRoot"
        Write-Host 'Launch with system\L2.exe'
        exit 0
    }

    if (-not $PSCmdlet.ShouldProcess($l2IniPath, "Set ServerAddr from $currentAddress to 127.0.0.1")) {
        exit 0
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    Copy-Item -LiteralPath $l2IniPath -Destination (Join-Path $localRoot "l2.ini.pre-sprint6-$stamp")
    $updated = [regex]::Replace($decoded, '(?im)^ServerAddr=.*$', 'ServerAddr=127.0.0.1')
    [IO.File]::WriteAllText($decodedPath, $updated, [Text.Encoding]::GetEncoding(1252))

    & $toolPath -c encode -p 413 -o $encodedPath $decodedPath
    if ($LASTEXITCODE -ne 0) {
        throw "l2.ini encode failed with exit code $LASTEXITCODE"
    }
    Copy-Item -LiteralPath $encodedPath -Destination $l2IniPath -Force

    & $toolPath -c decode -p 413 -o $verifyPath $l2IniPath
    if ($LASTEXITCODE -ne 0) {
        throw "l2.ini verification decode failed with exit code $LASTEXITCODE"
    }
    $verified = Get-Content -LiteralPath $verifyPath -Raw -Encoding Default
    if ($verified -notmatch '(?im)^ServerAddr=127\.0\.0\.1\s*$') {
        throw 'Verification failed: ServerAddr is not 127.0.0.1 after rewrite.'
    }

    Write-Host 'Client configured for local Login/Game servers.'
    Write-Host "Client root: $ClientRoot"
    Write-Host 'ServerAddr=127.0.0.1'
    Write-Host 'Launch with system\L2.exe'
    exit 0
}
catch {
    Write-Error "Local client configuration failed: $($_.Exception.Message)"
    exit 1
}
