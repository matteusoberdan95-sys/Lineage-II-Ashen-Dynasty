[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'

    $quest900 = Join-Path $dataRoot 'scripts\quests\Q00900_AshenScaleOfTransition\Q00900_AshenScaleOfTransition.java'
    $quest901 = Join-Path $dataRoot 'scripts\quests\Q00901_AshenEmberOfAscent\Q00901_AshenEmberOfAscent.java'
    $quest902 = Join-Path $dataRoot 'scripts\quests\Q00902_AshenCrownOfDynasty\Q00902_AshenCrownOfDynasty.java'
    $spawnPath = Join-Path $dataRoot 'spawns\Ashen\AshenQuest.xml'
    $npcPath = Join-Path $dataRoot 'stats\npcs\93000-93099.xml'
    foreach ($path in @($quest900, $quest901, $quest902, $spawnPath, $npcPath)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required Ashen quest runtime file missing: $path"
        }
    }

    $java900 = [IO.File]::ReadAllText($quest900)
    if ($java900 -notmatch 'super\(900,' -or $java900 -notmatch 'public static void main') {
        throw 'Quest 900 class must declare quest id 900 and a main() loader.'
    }

    $java901 = [IO.File]::ReadAllText($quest901)
    if ($java901 -notmatch 'super\(901,' -or $java901 -notmatch 'public static void main') {
        throw 'Quest 901 class must declare quest id 901 and a main() loader.'
    }
    if ($java901 -notmatch 'Q00900_AshenScaleOfTransition') {
        throw 'Quest 901 must require completion of Q900.'
    }

    $java902 = [IO.File]::ReadAllText($quest902)
    if ($java902 -notmatch 'super\(902,' -or $java902 -notmatch 'public static void main') {
        throw 'Quest 902 class must declare quest id 902 and a main() loader.'
    }
    if ($java902 -notmatch 'Q00901_AshenEmberOfAscent') {
        throw 'Quest 902 must require completion of Q901.'
    }
    if ($java902 -notmatch '9573') {
        throw 'Quest 902 must reward Recipe Dynarty Breastplate (9573).'
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
    Write-Host 'Q900/Q901/Q902 scripts/NPC/spawn present; custom scripts still excluded; submodule clean.'
}
catch {
    throw "Ashen quest verification failed: $($_.Exception.Message)"
}
