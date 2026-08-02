[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [string]$ClientRoot = 'D:\L2-ASHEN-DYNASTY'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    & (Join-Path $PSScriptRoot 'ensure-l2encdec.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw "ensure-l2encdec.ps1 failed with exit code $LASTEXITCODE"
    }

    $context = Get-L2RuntimeContext
    $repoRoot = $context.RepositoryRoot
    $toolPath = Join-Path $repoRoot 'server\runtime\tools\l2encdec\l2encdec_win.exe'
    $python = Get-Command python -ErrorAction Stop
    $manifest = Join-Path $repoRoot 'infrastructure\customization\ashen_client\ashen_client_manifest.csv'
    $generate = Join-Path $PSScriptRoot '_generate_ashen_client_manifest.py'
    $applyPy = Join-Path $PSScriptRoot 'apply_ashen_client_patch.py'
    $systemPath = Join-Path $ClientRoot 'system'
    $localRoot = Join-Path $ClientRoot '.ashen-local'
    $workRoot = Join-Path $localRoot 'client-patch-work'
    $decodedDir = Join-Path $workRoot 'decoded'
    $patchedDir = Join-Path $workRoot 'patched'

    if (-not (Test-Path -LiteralPath $ClientRoot -PathType Container)) {
        throw "Client root was not found: $ClientRoot"
    }
    if (Test-Path -LiteralPath (Join-Path $ClientRoot 'System L2Agonia')) {
        throw 'Refusing a custom L2Agonia client. Use the clean L2-ASHEN-DYNASTY client.'
    }
    foreach ($bannedName in @('CliExt.dll', 'entry.dll')) {
        if (Test-Path -LiteralPath (Join-Path $systemPath $bannedName)) {
            throw "Refusing client with custom binary: $bannedName"
        }
    }

    & $python.Source $generate
    if ($LASTEXITCODE -ne 0) {
        throw "Manifest generation failed with exit code $LASTEXITCODE"
    }
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw "Manifest missing after generation: $manifest"
    }

    if (-not $PSCmdlet.ShouldProcess($systemPath, 'Apply Ashen client name/icon patch')) {
        exit 0
    }

    foreach ($dir in @($localRoot, $workRoot, $decodedDir, $patchedDir)) {
        if (-not (Test-Path -LiteralPath $dir)) {
            $null = New-Item -ItemType Directory -Path $dir -Force
        }
    }

    $files = @(
        @{ Dat = 'itemname-e.dat'; Bin = 'itemname-e.bin' },
        @{ Dat = 'npcname-e.dat'; Bin = 'npcname-e.bin' },
        @{ Dat = 'armorgrp.dat'; Bin = 'armorgrp.bin' },
        @{ Dat = 'weapongrp.dat'; Bin = 'weapongrp.bin' },
        @{ Dat = 'etcitemgrp.dat'; Bin = 'etcitemgrp.bin' },
        @{ Dat = 'npcgrp.dat'; Bin = 'npcgrp.bin' }
    )

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path $localRoot "client-patch-backup-$stamp"
    $null = New-Item -ItemType Directory -Path $backupRoot -Force

    foreach ($entry in $files) {
        $datPath = Join-Path $systemPath $entry.Dat
        if (-not (Test-Path -LiteralPath $datPath -PathType Leaf)) {
            throw "Required client DAT missing: $datPath"
        }
        Copy-Item -LiteralPath $datPath -Destination (Join-Path $backupRoot $entry.Dat) -Force
        $decodedPath = Join-Path $decodedDir $entry.Bin
        & $toolPath -c decode -p 413 -o $decodedPath $datPath
        if ($LASTEXITCODE -ne 0) {
            throw "Decode failed for $($entry.Dat)"
        }
    }

    & $python.Source $applyPy --manifest $manifest --decoded-dir $decodedDir --output-dir $patchedDir
    if ($LASTEXITCODE -ne 0) {
        throw "apply_ashen_client_patch.py failed with exit code $LASTEXITCODE"
    }

    foreach ($entry in $files) {
        $patchedBin = Join-Path $patchedDir $entry.Bin
        $encodedPath = Join-Path $workRoot ($entry.Dat + '.encoded')
        $datPath = Join-Path $systemPath $entry.Dat
        & $toolPath -c encode -p 413 -o $encodedPath $patchedBin
        if ($LASTEXITCODE -ne 0) {
            throw "Encode failed for $($entry.Dat)"
        }
        Copy-Item -LiteralPath $encodedPath -Destination $datPath -Force
    }

    Write-Host 'Ashen client patch applied (Sprint 24 / ADR-011).'
    Write-Host "Client: $ClientRoot"
    Write-Host "Backup: $backupRoot"
    Write-Host 'Restart the L2 client to load updated names/icons.'
}
catch {
    throw "Ashen client patch apply failed: $($_.Exception.Message)"
}
