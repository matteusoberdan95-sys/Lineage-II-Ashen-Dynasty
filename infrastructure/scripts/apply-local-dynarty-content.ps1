[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

function Merge-AshenXmlFragment {
    param(
        [Parameter(Mandatory)][string]$TargetPath,
        [Parameter(Mandatory)][string]$FragmentPath,
        [Parameter(Mandatory)][string]$BeginMarker,
        [Parameter(Mandatory)][string]$EndMarker
    )

    $encoding = [Text.UTF8Encoding]::new($false)
    $target = [IO.File]::ReadAllText($TargetPath, $encoding)
    if ($target.Contains($BeginMarker) -and $target.Contains($EndMarker)) {
        $pattern = '(?s)[ \t]*' + [regex]::Escape($BeginMarker) + '.*?' + [regex]::Escape($EndMarker) + '\r?\n?'
        $target = [regex]::Replace($target, $pattern, '')
    }

    $fragment = [IO.File]::ReadAllText($FragmentPath, $encoding).TrimEnd("`r", "`n") + "`n"
    if ($target -notmatch '</list>\s*$') {
        throw "$TargetPath does not end with </list>; refusing merge."
    }

    $withoutClose = [regex]::Replace($target, '</list>\s*$', '')
    $merged = $withoutClose + $fragment + '</list>' + "`n"
    [IO.File]::WriteAllText($TargetPath, $merged, $encoding)
}

try {
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying Ashen Dynarty content.'
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization\game\data'
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'

    $files = @(
        'stats\items\09700-09799.xml',
        'stats\items\09570-09579.xml',
        'stats\armorsets\ashen_dynarty.xml',
        'stats\npcs\93300-93399.xml',
        'spawns\Ashen\AshenDynarty.xml'
    )

    foreach ($relative in $files) {
        $source = Join-Path $overlayRoot $relative
        $destination = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Dynarty overlay missing: $source"
        }
        $destinationDirectory = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $destinationDirectory -Force
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    $enchantData = Join-Path $dataRoot 'EnchantItemData.xml'
    $enchantGroups = Join-Path $dataRoot 'EnchantItemGroups.xml'
    Merge-AshenXmlFragment -TargetPath $enchantData `
        -FragmentPath (Join-Path $overlayRoot 'EnchantItemData.ashen.fragment.xml') `
        -BeginMarker '<!-- BEGIN ASHEN DYNASTY ENCHANT -->' `
        -EndMarker '<!-- END ASHEN DYNASTY ENCHANT -->'
    Merge-AshenXmlFragment -TargetPath $enchantGroups `
        -FragmentPath (Join-Path $overlayRoot 'EnchantItemGroups.ashen.fragment.xml') `
        -BeginMarker '<!-- BEGIN ASHEN DYNASTY ENCHANT GROUPS -->' `
        -EndMarker '<!-- END ASHEN DYNASTY ENCHANT GROUPS -->'

    Write-Host 'Ashen Dynarty content overlays applied (ADR-010 implementation).'
    Write-Host 'Items 9700-9799, scrolls 9570/9571, sets 109-111, +30 Dynarty-only enchant merge.'
}
catch {
    throw "Ashen Dynarty content apply failed: $($_.Exception.Message)"
}
