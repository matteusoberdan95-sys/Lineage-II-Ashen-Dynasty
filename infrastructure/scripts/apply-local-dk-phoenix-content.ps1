[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying Ashen DK/Phoenix content.'
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization\game\data'
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    if (-not (Test-Path -LiteralPath $overlayRoot -PathType Container)) {
        throw "DK/Phoenix overlay root was not found: $overlayRoot"
    }

    $files = @(
        'stats\items\09600-09699.xml',
        'stats\armorsets\ashen_dk.xml',
        'stats\npcs\93200-93299.xml',
        'spawns\Ashen\AshenDkPhoenix.xml'
    )

    foreach ($relative in $files) {
        $source = Join-Path $overlayRoot $relative
        $destination = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "DK/Phoenix overlay missing: $source"
        }
        $destinationDirectory = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $destinationDirectory -Force
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    Write-Host 'Ashen DK/Phoenix content overlays applied (ADR-009 implementation).'
    Write-Host 'Items 9600-9699, sets 106-108, NPCs 93200-93201, Death Pass spawns.'
}
catch {
    throw "Ashen DK/Phoenix content apply failed: $($_.Exception.Message)"
}
