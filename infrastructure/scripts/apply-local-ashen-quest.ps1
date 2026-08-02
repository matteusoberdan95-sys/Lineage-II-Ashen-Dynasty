[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying Ashen quest content.'
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization\game\data'
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'

    $questSource = Join-Path $overlayRoot 'scripts\quests\Q00900_AshenScaleOfTransition'
    $questDestination = Join-Path $dataRoot 'scripts\quests\Q00900_AshenScaleOfTransition'
    if (-not (Test-Path -LiteralPath $questSource -PathType Container)) {
        throw "Ashen quest overlay missing: $questSource"
    }

    if (Test-Path -LiteralPath $questDestination) {
        Remove-Item -LiteralPath $questDestination -Recurse -Force
    }
    $null = New-Item -ItemType Directory -Path $questDestination -Force
    Copy-Item -Path (Join-Path $questSource '*') -Destination $questDestination -Recurse -Force

    $spawnSource = Join-Path $overlayRoot 'spawns\Ashen\AshenQuest.xml'
    $spawnDestination = Join-Path $dataRoot 'spawns\Ashen\AshenQuest.xml'
    if (-not (Test-Path -LiteralPath $spawnSource -PathType Leaf)) {
        throw "Ashen quest spawn missing: $spawnSource"
    }
    $spawnDirectory = Split-Path -Parent $spawnDestination
    if (-not (Test-Path -LiteralPath $spawnDirectory -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $spawnDirectory -Force
    }
    Copy-Item -LiteralPath $spawnSource -Destination $spawnDestination -Force

    # Chronicler NPC lives in the TT NPC overlay file (93002).
    $npcSource = Join-Path $overlayRoot 'stats\npcs\93000-93099.xml'
    $npcDestination = Join-Path $dataRoot 'stats\npcs\93000-93099.xml'
    if (-not (Test-Path -LiteralPath $npcSource -PathType Leaf)) {
        throw "TT/quest NPC overlay missing: $npcSource"
    }
    Copy-Item -LiteralPath $npcSource -Destination $npcDestination -Force

    Write-Host 'Ashen quest overlays applied (Sprint 16).'
    Write-Host 'Q900 Ashen Scale of Transition, NPC 93002, Death Pass spawn.'
}
catch {
    throw "Ashen quest apply failed: $($_.Exception.Message)"
}
