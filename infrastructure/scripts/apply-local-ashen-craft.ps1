[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying Ashen craft content.'
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization\game\data'
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'

    $itemsSource = Join-Path $overlayRoot 'stats\items\09500-09599.xml'
    $fragmentSource = Join-Path $overlayRoot 'Recipes.ashen.fragment.xml'
    if (-not (Test-Path -LiteralPath $itemsSource -PathType Leaf)) {
        throw "Ashen craft items overlay missing: $itemsSource"
    }
    if (-not (Test-Path -LiteralPath $fragmentSource -PathType Leaf)) {
        throw "Ashen craft recipes fragment missing: $fragmentSource"
    }

    $itemsDestination = Join-Path $dataRoot 'stats\items\09500-09599.xml'
    $itemsDirectory = Split-Path -Parent $itemsDestination
    if (-not (Test-Path -LiteralPath $itemsDirectory -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $itemsDirectory -Force
    }
    Copy-Item -LiteralPath $itemsSource -Destination $itemsDestination -Force

    $recipesPath = Join-Path $dataRoot 'Recipes.xml'
    if (-not (Test-Path -LiteralPath $recipesPath -PathType Leaf)) {
        throw "Runtime Recipes.xml was not found: $recipesPath"
    }

    $encoding = [Text.UTF8Encoding]::new($false)
    $recipes = [IO.File]::ReadAllText($recipesPath, $encoding)
    $begin = '<!-- BEGIN ASHEN DYNASTY RECIPES -->'
    $end = '<!-- END ASHEN DYNASTY RECIPES -->'
    if ($recipes.Contains($begin) -and $recipes.Contains($end)) {
        $pattern = '(?s)[ \t]*' + [regex]::Escape($begin) + '.*?' + [regex]::Escape($end) + '\r?\n?'
        $recipes = [regex]::Replace($recipes, $pattern, '')
    }

    $fragment = [IO.File]::ReadAllText($fragmentSource, $encoding).TrimEnd("`r", "`n") + "`n"
    if ($recipes -notmatch '</list>\s*$') {
        throw 'Recipes.xml does not end with </list>; refusing to merge Ashen recipes.'
    }

    $withoutClose = [regex]::Replace($recipes, '</list>\s*$', '')
    $merged = $withoutClose + $fragment + '</list>' + "`n"
    [IO.File]::WriteAllText($recipesPath, $merged, $encoding)

    Write-Host 'Ashen craft overlays applied (Sprint 15).'
    Write-Host 'Recipe scrolls 9500+, Recipes.xml merged with fragment sink entries.'
}
catch {
    throw "Ashen craft apply failed: $($_.Exception.Message)"
}
