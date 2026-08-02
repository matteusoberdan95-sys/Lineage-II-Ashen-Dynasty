[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    $required = @(
        'stats\items\09400-09499.xml',
        'stats\armorsets\ashen_draconic.xml',
        'stats\npcs\93100-93199.xml',
        'spawns\Ashen\AshenDraconic.xml'
    )

    foreach ($relative in $required) {
        $path = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required Draconic runtime file missing: $path"
        }
    }

    $items = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\items\09400-09499.xml'))
    foreach ($id in @(9400, 9401, 9431, 9461, 9490, 9498, 9499)) {
        if ($items -notmatch "item id=`"$id`"") {
            throw "Draconic item id $id was not found in runtime items XML."
        }
    }

    $sets = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\armorsets\ashen_draconic.xml'))
    if ($sets -notmatch 'set id="103"' -or $sets -notmatch 'set id="105"') {
        throw 'Draconic armor sets 103-105 were not found.'
    }

    $npcs = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\npcs\93100-93199.xml'))
    if ($npcs -notmatch 'npc id="93100"' -or $npcs -notmatch 'npc id="93101"') {
        throw 'Draconic raid NPCs 93100/93101 were not found.'
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

    Write-Host 'Ashen Draconic content verification passed.'
    Write-Host 'Runtime contains Draconic items/sets/NPCs/spawns; submodule clean.'
}
catch {
    throw "Ashen Draconic content verification failed: $($_.Exception.Message)"
}
