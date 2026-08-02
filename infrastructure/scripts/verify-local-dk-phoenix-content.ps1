[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    $required = @(
        'stats\items\09600-09699.xml',
        'stats\armorsets\ashen_dk.xml',
        'stats\npcs\93200-93299.xml',
        'spawns\Ashen\AshenDkPhoenix.xml'
    )

    foreach ($relative in $required) {
        $path = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required DK/Phoenix runtime file missing: $path"
        }
    }

    $items = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\items\09600-09699.xml'))
    foreach ($id in @(9600, 9601, 9631, 9661, 9690, 9698, 9699)) {
        if ($items -notmatch "item id=`"$id`"") {
            throw "DK/Phoenix item id $id was not found in runtime items XML."
        }
    }

    $sets = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\armorsets\ashen_dk.xml'))
    if ($sets -notmatch 'set id="106"' -or $sets -notmatch 'set id="108"') {
        throw 'DK armor sets 106-108 were not found.'
    }

    $npcs = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\npcs\93200-93299.xml'))
    if ($npcs -notmatch 'npc id="93200"' -or $npcs -notmatch 'npc id="93201"') {
        throw 'DK/Phoenix raid NPCs 93200/93201 were not found.'
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

    Write-Host 'Ashen DK/Phoenix content verification passed.'
    Write-Host 'Runtime contains DK/Phoenix items/sets/NPCs/spawns; submodule clean.'
}
catch {
    throw "Ashen DK/Phoenix content verification failed: $($_.Exception.Message)"
}
