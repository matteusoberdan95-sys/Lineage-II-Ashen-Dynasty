[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

function Set-IniValue {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Value
    )

    $encoding = [Text.UTF8Encoding]::new($false)
    $content = [IO.File]::ReadAllText($Path, $encoding)
    $pattern = "(?m)^([ \t]*$([regex]::Escape($Key))[ \t]*=[ \t]*).*$"
    $regex = [regex]::new($pattern)
    $matches = $regex.Matches($content)
    if ($matches.Count -ne 1) {
        throw "Expected one '$Key' property in $Path, found $($matches.Count)."
    }

    $updated = $regex.Replace(
        $content,
        [Text.RegularExpressions.MatchEvaluator] {
            param($match)
            return $match.Groups[1].Value + $Value
        }
    )
    [IO.File]::WriteAllText($Path, $updated, $encoding)
}

try {
    foreach ($service in @('game', 'login')) {
        if (Get-L2ManagedProcess -Service $service) {
            throw "$service server must be stopped before applying product customization."
        }
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization'
    $distributionRoot = $context.DistributionRoot

    if (-not (Test-Path -LiteralPath $overlayRoot -PathType Container)) {
        throw "Product customization overlay root was not found: $overlayRoot"
    }
    if (-not (Test-Path -LiteralPath $distributionRoot -PathType Container)) {
        throw "Runtime distribution was not found: $distributionRoot"
    }

    $overlays = @(
        @{
            Source = Join-Path $overlayRoot 'login\data\servername.xml'
            Destination = Join-Path $distributionRoot 'login\data\servername.xml'
            Marker = 'name="Ashen Dynasty"'
        },
        @{
            Source = Join-Path $overlayRoot 'game\data\html\servnews.htm'
            Destination = Join-Path $distributionRoot 'game\data\html\servnews.htm'
            Marker = 'Ashen Dynasty'
        }
    )

    foreach ($overlay in $overlays) {
        if (-not (Test-Path -LiteralPath $overlay.Source -PathType Leaf)) {
            throw "Customization overlay was not found: $($overlay.Source)"
        }

        $destinationDirectory = Split-Path -Parent $overlay.Destination
        if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
            throw "Runtime destination directory was not found: $destinationDirectory"
        }

        $sourceText = [IO.File]::ReadAllText($overlay.Source)
        if ($sourceText -notlike "*$($overlay.Marker)*") {
            throw "Overlay marker '$($overlay.Marker)' was not found in $($overlay.Source)"
        }

        Copy-Item -LiteralPath $overlay.Source -Destination $overlay.Destination -Force
    }

    $generalConfig = Join-Path $distributionRoot 'game\config\General.ini'
    if (-not (Test-Path -LiteralPath $generalConfig -PathType Leaf)) {
        throw "General.ini was not found: $generalConfig"
    }
    Set-IniValue -Path $generalConfig -Key 'ShowServerNews' -Value 'True'

    Write-Host 'Local product customization overlays were applied.'
    Write-Host 'Server ID 1 display name: Ashen Dynasty'
    Write-Host 'ShowServerNews: True'
}
catch {
    throw "Product customization apply failed: $($_.Exception.Message)"
}
