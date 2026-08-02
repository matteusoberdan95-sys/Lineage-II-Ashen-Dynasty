[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying Ashen Draconic content.'
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization\game\data'
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    if (-not (Test-Path -LiteralPath $overlayRoot -PathType Container)) {
        throw "Draconic overlay root was not found: $overlayRoot"
    }

    $files = @(
        'stats\items\09400-09499.xml',
        'stats\armorsets\ashen_draconic.xml',
        'stats\npcs\93100-93199.xml',
        'spawns\Ashen\AshenDraconic.xml'
    )

    foreach ($relative in $files) {
        $source = Join-Path $overlayRoot $relative
        $destination = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Draconic overlay missing: $source"
        }
        $destinationDirectory = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $destinationDirectory -Force
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    Write-Host 'Ashen Draconic content overlays applied (ADR-008 implementation).'
    Write-Host 'Items 9400-9499, sets 103-105, NPCs 93100-93101, Death Pass spawns.'
}
catch {
    throw "Ashen Draconic content apply failed: $($_.Exception.Message)"
}
