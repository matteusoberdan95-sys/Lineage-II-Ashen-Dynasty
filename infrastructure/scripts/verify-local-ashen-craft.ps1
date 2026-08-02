[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'

    $itemsPath = Join-Path $dataRoot 'stats\items\09500-09599.xml'
    $recipesPath = Join-Path $dataRoot 'Recipes.xml'
    if (-not (Test-Path -LiteralPath $itemsPath -PathType Leaf)) {
        throw "Required Ashen craft items missing: $itemsPath"
    }
    if (-not (Test-Path -LiteralPath $recipesPath -PathType Leaf)) {
        throw "Required Recipes.xml missing: $recipesPath"
    }

    $items = [IO.File]::ReadAllText($itemsPath)
    foreach ($id in @(9500, 9501, 9523, 9545, 9546, 9547, 9568)) {
        if ($items -notmatch "item id=`"$id`"") {
            throw "Ashen craft scroll id $id was not found."
        }
    }

    $recipes = [IO.File]::ReadAllText($recipesPath)
    if ($recipes -notmatch 'BEGIN ASHEN DYNASTY RECIPES') {
        throw 'Ashen recipes marker was not found in Recipes.xml.'
    }
    foreach ($id in @(872, 873, 895, 917, 918, 940)) {
        if ($recipes -notmatch "item id=`"$id`" recipeId=") {
            throw "Ashen recipe list id $id was not found in Recipes.xml."
        }
    }
    if ($recipes -notmatch 'ingredient id="9399"' -or $recipes -notmatch 'ingredient id="9499"' -or $recipes -notmatch 'ingredient id="9699"') {
        throw 'Ashen fragment ingredients 9399/9499/9699 were not found in recipes.'
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

    Write-Host 'Ashen craft verification passed.'
    Write-Host 'Scrolls 9500-9568 and Recipes.xml merge present; submodule clean.'
}
catch {
    throw "Ashen craft verification failed: $($_.Exception.Message)"
}
