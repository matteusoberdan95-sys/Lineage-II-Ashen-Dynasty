[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    $required = @(
        'stats\items\09300-09399.xml',
        'stats\armorsets\ashen_tt.xml',
        'stats\npcs\93000-93099.xml',
        'spawns\Ashen\AshenTT.xml'
    )

    foreach ($relative in $required) {
        $path = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required TT runtime file missing: $path"
        }
    }

    $items = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\items\09300-09399.xml'))
    foreach ($id in @(9300, 9301, 9331, 9361, 9390, 9398, 9399)) {
        if ($items -notmatch "item id=`"$id`"") {
            throw "TT item id $id was not found in runtime items XML."
        }
    }

    $sets = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\armorsets\ashen_tt.xml'))
    if ($sets -notmatch 'set id="100"' -or $sets -notmatch 'set id="102"') {
        throw 'TT armor sets 100-102 were not found.'
    }

    $npcs = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\npcs\93000-93099.xml'))
    if ($npcs -notmatch 'npc id="93000"' -or $npcs -notmatch 'npc id="93001"') {
        throw 'TT raid NPCs 93000/93001 were not found.'
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

    Write-Host 'Ashen TT content verification passed.'
    Write-Host 'Runtime contains TT items/sets/NPCs/spawns; submodule clean.'
}
catch {
    throw "Ashen TT content verification failed: $($_.Exception.Message)"
}
