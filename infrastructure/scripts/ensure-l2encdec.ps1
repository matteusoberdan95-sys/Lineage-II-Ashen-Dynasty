[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $toolsRoot = Join-Path $repositoryRoot 'server\runtime\tools'
    $dest = Join-Path $toolsRoot 'l2encdec'
    $exePath = Join-Path $dest 'l2encdec_win.exe'
    if (Test-Path -LiteralPath $exePath -PathType Leaf) {
        Write-Host "l2encdec already present: $exePath"
        exit 0
    }

    if (-not (Test-Path -LiteralPath $toolsRoot)) {
        $null = New-Item -ItemType Directory -Path $toolsRoot
    }

    $zipPath = Join-Path $toolsRoot 'l2encdec_windows.zip'
    $url = 'https://github.com/ritsuwastaken/open-l2encdec/releases/download/1.3.9/l2encdec_windows.zip'
    $expectedHash = '3A7743C03A635DBBF7892C4F3D65D0D13D5FC04830721540AD9E430C7BD0495E'

    Invoke-WebRequest -Uri $url -OutFile $zipPath
    $actualHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
    if ($actualHash -ne $expectedHash) {
        throw "l2encdec hash mismatch. Expected $expectedHash, got $actualHash"
    }

    if (Test-Path -LiteralPath $dest) {
        Remove-Item -LiteralPath $dest -Recurse -Force
    }
    Expand-Archive -LiteralPath $zipPath -DestinationPath $dest
    if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) {
        throw "l2encdec executable was not extracted: $exePath"
    }

    Write-Host "l2encdec installed for local use: $exePath"
    Write-Host 'Source: open-l2encdec 1.3.9 (MIT), SHA-256 verified.'
    exit 0
}
catch {
    Write-Error "Unable to ensure l2encdec: $($_.Exception.Message)"
    exit 1
}
