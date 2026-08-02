[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    $required = @(
        'stats\items\09700-09799.xml',
        'stats\items\09570-09579.xml',
        'stats\armorsets\ashen_dynarty.xml',
        'stats\npcs\93300-93399.xml',
        'spawns\Ashen\AshenDynarty.xml',
        'EnchantItemData.xml',
        'EnchantItemGroups.xml'
    )

    foreach ($relative in $required) {
        $path = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required Dynarty runtime file missing: $path"
        }
    }

    $items = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\items\09700-09799.xml'))
    foreach ($id in @(9700, 9701, 9731, 9761, 9790, 9798, 9799)) {
        if ($items -notmatch "item id=`"$id`"") {
            throw "Dynarty item id $id was not found."
        }
    }

    $scrolls = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\items\09570-09579.xml'))
    if ($scrolls -notmatch 'item id="9570"' -or $scrolls -notmatch 'item id="9571"') {
        throw 'Dynarty enchant scrolls 9570/9571 were not found.'
    }

    $enchantData = [IO.File]::ReadAllText((Join-Path $dataRoot 'EnchantItemData.xml'))
    if ($enchantData -notmatch 'BEGIN ASHEN DYNASTY ENCHANT' -or $enchantData -notmatch 'maxEnchant="30"') {
        throw 'Dynarty +30 enchant entries were not merged into EnchantItemData.xml.'
    }
    if ($enchantData -notmatch 'item id="9790"' -or $enchantData -notmatch 'item id="9701"') {
        throw 'Dynarty item whitelist missing from EnchantItemData.xml.'
    }

    $enchantGroups = [IO.File]::ReadAllText((Join-Path $dataRoot 'EnchantItemGroups.xml'))
    if ($enchantGroups -notmatch 'DYNARTY_FIGHTER_WEAPON_GROUP' -or $enchantGroups -notmatch 'enchantScrollGroup id="1"') {
        throw 'Dynarty enchant groups were not merged into EnchantItemGroups.xml.'
    }

    $sets = [IO.File]::ReadAllText((Join-Path $dataRoot 'stats\armorsets\ashen_dynarty.xml'))
    if ($sets -notmatch 'set id="109"' -or $sets -notmatch 'set id="111"') {
        throw 'Dynarty armor sets 109-111 were not found.'
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

    Write-Host 'Ashen Dynarty content verification passed.'
    Write-Host 'Items/sets/raids/spawns + Dynarty-only +30 enchant merge present; submodule clean.'
}
catch {
    throw "Ashen Dynarty content verification failed: $($_.Exception.Message)"
}
