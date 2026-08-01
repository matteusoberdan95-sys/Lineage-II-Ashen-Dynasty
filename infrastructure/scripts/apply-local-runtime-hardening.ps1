[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    foreach ($service in @('game', 'login')) {
        if (Get-L2ManagedProcess -Service $service) {
            throw "$service server must be stopped before refreshing runtime hardening."
        }
    }

    $context = Get-L2RuntimeContext
    $configurationRoot = Join-Path $context.RepositoryRoot 'infrastructure\configuration\game'
    $targetRoot = Join-Path $context.DistributionRoot 'game\config'
    $templates = [ordered]@{
        'ipconfig.xml' = 'ipconfig.xml'
        'Scripts.xml' = 'Scripts.xml'
    }

    foreach ($entry in $templates.GetEnumerator()) {
        $source = Join-Path $configurationRoot $entry.Key
        $destination = Join-Path $targetRoot $entry.Value
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Hardening template was not found: $source"
        }
        if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
            throw "Runtime configuration directory was not found: $targetRoot"
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    Write-Host 'Local runtime hardening templates were refreshed.'
    Write-Host 'External IP discovery and custom script loading are disabled.'
    exit 0
}
catch {
    Write-Error "Runtime hardening refresh failed: $($_.Exception.Message)"
    exit 1
}
