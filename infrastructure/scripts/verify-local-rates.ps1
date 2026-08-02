[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $ratesPath = Join-Path $context.DistributionRoot 'game\config\Rates.ini'
    $submoduleRoot = Join-Path $context.RepositoryRoot 'server\source\l2jmobius-upstream'
    if (-not (Test-Path -LiteralPath $ratesPath -PathType Leaf)) {
        throw "Rates.ini was not found: $ratesPath"
    }

    $content = [IO.File]::ReadAllText($ratesPath)
    $expected = [ordered]@{
        'RateXp' = '500'
        'RateSp' = '500'
        'RatePartyXp' = '500'
        'RatePartySp' = '500'
        'RateQuestRewardXP' = '500'
        'RateQuestRewardSP' = '500'
        'RateQuestRewardAdena' = '5'
        'DeathDropAmountMultiplier' = '1'
        'DeathDropChanceMultiplier' = '1'
        'SpoilDropChanceMultiplier' = '1'
        'DropAmountMultiplierByItemId' = '57,10;6656,1;6657,1;6658,1;6659,1;6660,1;6661,1;6662,1;8191,1'
    }

    foreach ($entry in $expected.GetEnumerator()) {
        $pattern = "(?m)^[ \t]*$([regex]::Escape($entry.Key))[ \t]*=[ \t]*$([regex]::Escape($entry.Value))[ \t]*$"
        if ($content -notmatch $pattern) {
            throw "Rate key '$($entry.Key)' is not set to '$($entry.Value)'."
        }
    }

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

    Write-Host 'Local rates verification passed (ADR-005).'
    Write-Host 'XP/SP: 500 | Drop chance/amount: 1 | Adena amount: 10'
    Write-Host 'Submodule: clean'
}
catch {
    throw "Local rates verification failed: $($_.Exception.Message)"
}
