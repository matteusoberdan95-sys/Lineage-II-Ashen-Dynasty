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
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying local rates.'
    }

    $context = Get-L2RuntimeContext
    $ratesPath = Join-Path $context.DistributionRoot 'game\config\Rates.ini'
    if (-not (Test-Path -LiteralPath $ratesPath -PathType Leaf)) {
        throw "Rates.ini was not found: $ratesPath"
    }

    $values = [ordered]@{
        'RateXp' = '500'
        'RateSp' = '500'
        'RatePartyXp' = '500'
        'RatePartySp' = '500'
        'RateQuestRewardXP' = '500'
        'RateQuestRewardSP' = '500'
        'RateQuestRewardAdena' = '5'
        'RateQuestReward' = '1'
        'DeathDropAmountMultiplier' = '1'
        'SpoilDropAmountMultiplier' = '1'
        'RaidDropAmountMultiplier' = '1'
        'DeathDropChanceMultiplier' = '1'
        'SpoilDropChanceMultiplier' = '1'
        'RaidDropChanceMultiplier' = '1'
        'DropAmountMultiplierByItemId' = '57,10;6656,1;6657,1;6658,1;6659,1;6660,1;6661,1;6662,1;8191,1'
        'DropChanceMultiplierByItemId' = '57,1'
    }

    foreach ($entry in $values.GetEnumerator()) {
        Set-IniValue -Path $ratesPath -Key $entry.Key -Value $entry.Value
    }

    Write-Host 'Local rates applied (ADR-005).'
    Write-Host 'XP/SP/Party/Quest XP-SP: 500'
    Write-Host 'Drop/Spoil/Raid: 1 (gear lento)'
    Write-Host 'Adena amount multiplier: 10'
}
catch {
    throw "Local rates apply failed: $($_.Exception.Message)"
}
