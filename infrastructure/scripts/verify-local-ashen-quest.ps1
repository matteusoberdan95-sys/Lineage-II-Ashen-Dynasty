[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'

    $questJava = Join-Path $dataRoot 'scripts\quests\Q00900_AshenScaleOfTransition\Q00900_AshenScaleOfTransition.java'
    $spawnPath = Join-Path $dataRoot 'spawns\Ashen\AshenQuest.xml'
    $npcPath = Join-Path $dataRoot 'stats\npcs\93000-93099.xml'
    foreach ($path in @($questJava, $spawnPath, $npcPath)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required Ashen quest runtime file missing: $path"
        }
    }

    $java = [IO.File]::ReadAllText($questJava)
    if ($java -notmatch 'super\(900,' -or $java -notmatch 'public static void main') {
        throw 'Quest 900 class must declare quest id 900 and a main() loader.'
    }

    $npc = [IO.File]::ReadAllText($npcPath)
    if ($npc -notmatch 'npc id="93002"') {
        throw 'Quest NPC 93002 was not found in runtime NPC XML.'
    }

    $spawn = [IO.File]::ReadAllText($spawnPath)
    if ($spawn -notmatch 'npc id="93002"') {
        throw 'Quest spawn for NPC 93002 was not found.'
    }

    $scriptsConfig = Join-Path $context.DistributionRoot 'game\config\Scripts.xml'
    [xml]$scripts = Get-Content -LiteralPath $scriptsConfig -Raw
    if (-not @($scripts.list.exclude | Where-Object file -eq 'custom')) {
        throw 'Custom script directory must remain excluded.'
    }

    $submoduleRoot = Join-Path $context.RepositoryRoot 'server\source\l2jmobius-upstream'
    Push-Location $submoduleRoot
    try {
        $submoduleStatus = (& git status --short) | Out-String
    }
    finally {
        Pop-Location
    }
    if (-not [string]::IsNullOrWhiteSpace($submoduleStatus)) {
        throw "Submodule is dirty:`n$submoduleStatus"
    }

    Write-Host 'Ashen quest verification passed.'
    Write-Host 'Q900 scripts/NPC/spawn present; custom scripts still excluded; submodule clean.'
}
catch {
    throw "Ashen quest verification failed: $($_.Exception.Message)"
}
