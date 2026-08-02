[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptsRoot = $PSScriptRoot

try {
    & (Join-Path $scriptsRoot 'verify-local-servers.ps1')
    & (Join-Path $scriptsRoot 'verify-local-product-customization.ps1')
    & (Join-Path $scriptsRoot 'verify-local-rates.ps1')
    & (Join-Path $scriptsRoot 'verify-local-admin.ps1')
    & (Join-Path $scriptsRoot 'verify-world-checklist.ps1') -ExpectedOnlineState Any

    Write-Host ''
    Write-Host 'Automated regression verification passed.'
    Write-Host 'Complete the manual checklist in docs/setup/REGRESSION_ROTEIRO.md'
    Write-Host 'and docs/setup/GM_PLAYTEST_CHECKLIST.md, then record the result in'
    Write-Host 'docs/setup/SPRINT10_MANUAL_VALIDATION.md'
}
catch {
    throw "Local regression verification failed: $($_.Exception.Message)"
}
