[CmdletBinding()]
param(
    [string]$ReportDirectory = "docs/setup/playtest-reports",

    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$WorldChecklistUser = 'ashen_test',

    [ValidateSet('Any', 'Online', 'Offline')]
    [string]$ExpectedOnlineState = 'Any'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$scriptsRoot = Join-Path $repoRoot 'infrastructure\scripts'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportRoot = Join-Path $repoRoot $ReportDirectory
$reportPath = Join-Path $reportRoot ("content-playtest-" + $timestamp + ".md")

$checks = @(
    @{ Name = 'Local servers'; Script = 'verify-local-servers.ps1'; Args = @() },
    @{ Name = 'Product customization'; Script = 'verify-local-product-customization.ps1'; Args = @() },
    @{ Name = 'Rates ADR-005'; Script = 'verify-local-rates.ps1'; Args = @() },
    @{ Name = 'GM admin account'; Script = 'verify-local-admin.ps1'; Args = @() },
    @{ Name = 'World checklist'; Script = 'verify-world-checklist.ps1'; Args = @('-Username', $WorldChecklistUser, '-ExpectedOnlineState', $ExpectedOnlineState) },
    @{ Name = 'TT content'; Script = 'verify-local-tt-content.ps1'; Args = @() },
    @{ Name = 'Draconic content'; Script = 'verify-local-draconic-content.ps1'; Args = @() },
    @{ Name = 'DK/Phoenix content'; Script = 'verify-local-dk-phoenix-content.ps1'; Args = @() },
    @{ Name = 'Dynarty content'; Script = 'verify-local-dynarty-content.ps1'; Args = @() },
    @{ Name = 'Ashen craft'; Script = 'verify-local-ashen-craft.ps1'; Args = @() },
    @{ Name = 'Ashen quest'; Script = 'verify-local-ashen-quest.ps1'; Args = @() },
    @{ Name = 'Ashen progression hub'; Script = 'verify-local-ashen-progression.ps1'; Args = @() }
)

function Invoke-Check {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Check
    )

    $scriptPath = Join-Path $scriptsRoot $Check.Script
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        return [PSCustomObject]@{
            Name = $Check.Name
            Script = $Check.Script
            Status = 'SKIP'
            ExitCode = -1
            Output = 'Script not found.'
        }
    }

    $arguments = @(
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        $scriptPath
    ) + $Check.Args

    $output = & powershell.exe @arguments 2>&1
    $exitCode = $LASTEXITCODE
    $status = if ($exitCode -eq 0) { 'PASS' } else { 'FAIL' }

    return [PSCustomObject]@{
        Name = $Check.Name
        Script = $Check.Script
        Status = $status
        ExitCode = $exitCode
        Output = (($output | ForEach-Object { $_.ToString() }) -join "`n").Trim()
    }
}

try {
    if (-not (Test-Path -LiteralPath $reportRoot -PathType Container)) {
        $null = New-Item -ItemType Directory -Path $reportRoot -Force
    }

    $results = @()
    foreach ($check in $checks) {
        $results += Invoke-Check -Check $check
    }

    $passCount = @($results | Where-Object Status -eq 'PASS').Count
    $failCount = @($results | Where-Object Status -eq 'FAIL').Count
    $skipCount = @($results | Where-Object Status -eq 'SKIP').Count

    $reportLines = @()
    $reportLines += '# Content Playtest Report'
    $reportLines += ''
    $reportLines += ('Date: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
    $reportLines += ('User: ' + $env:USERNAME)
    $reportLines += ('Repo: ' + $repoRoot)
    $reportLines += ''
    $reportLines += '## Automated checks'
    $reportLines += ''
    $reportLines += '| Check | Script | Status | Exit code |'
    $reportLines += '|---|---|---|---|'

    foreach ($result in $results) {
        $reportLines += ('| ' + $result.Name + ' | ' + $result.Script + ' | ' + $result.Status + ' | ' + $result.ExitCode + ' |')
    }

    $reportLines += ''
    $reportLines += ('Summary: PASS=' + $passCount + ' FAIL=' + $failCount + ' SKIP=' + $skipCount)
    $reportLines += ''
    $reportLines += '## Manual in-game checklist'
    $reportLines += ''
    $reportLines += '- [ ] Login with `ashen_test` and enter world without error.'
    $reportLines += '- [ ] Kill 2-3 mobs and confirm XP/SP pace (500x feel) and non-inflated drops.'
    $reportLines += '- [ ] Open Ashen GM Shop and buy one item from each grade block (NG, D, C, B, A, S).'
    $reportLines += '- [ ] Equip one TT set/weapon (T3) and relog.'
    $reportLines += '- [ ] Equip one Draconic set/weapon (T4) and relog.'
    $reportLines += '- [ ] Equip one DK/Phoenix set/weapon (T5) and relog.'
    $reportLines += '- [ ] Equip one Dynarty set/weapon (T6) and relog.'
    $reportLines += '- [ ] Run Q900 -> Q901 -> Q902 bridge flow and confirm rewards.'
    $reportLines += '- [ ] Validate one craft recipe from TT/Draconic/DK/Dynarty tiers.'
    $reportLines += '- [ ] Confirm only one GM Shop NPC is present in hub.'
    $reportLines += ''
    $reportLines += '## Raw outputs'
    $reportLines += ''

    foreach ($result in $results) {
        $reportLines += ('### ' + $result.Name)
        $reportLines += ''
        $reportLines += '```text'
        $reportLines += (($result.Output -replace "`r", '') -split "`n")
        $reportLines += '```'
        $reportLines += ''
    }

    Set-Content -LiteralPath $reportPath -Value $reportLines -Encoding UTF8

    Write-Host ('Report generated: ' + $reportPath)
    Write-Host ('Summary: PASS=' + $passCount + ' FAIL=' + $failCount + ' SKIP=' + $skipCount)

    if ($failCount -gt 0) {
        exit 1
    }

    exit 0
}
catch {
    Write-Error ('Content playtest runner failed: ' + $_.Exception.Message)
    exit 1
}
