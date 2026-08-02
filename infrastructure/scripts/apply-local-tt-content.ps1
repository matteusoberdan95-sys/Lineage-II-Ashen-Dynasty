[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying Ashen TT content.'
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization\game\data'
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    if (-not (Test-Path -LiteralPath $overlayRoot -PathType Container)) {
        throw "TT overlay root was not found: $overlayRoot"
    }

    $files = @(
        'stats\items\09300-09399.xml',
        'stats\armorsets\ashen_tt.xml',
        'stats\npcs\93000-93099.xml',
        'spawns\Ashen\AshenTT.xml'
    )

    foreach ($relative in $files) {
        $source = Join-Path $overlayRoot $relative
        $destination = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "TT overlay missing: $source"
        }
        $destinationDirectory = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $destinationDirectory -Force
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    Write-Host 'Ashen TT content overlays applied (ADR-007 implementation).'
    Write-Host 'Items 9300-9399, sets 100-102, NPCs 93000-93001, Death Pass spawns.'
}
catch {
    throw "Ashen TT content apply failed: $($_.Exception.Message)"
}
