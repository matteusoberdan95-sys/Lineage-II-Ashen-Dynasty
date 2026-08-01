[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [switch]$IncludeDatabase
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    if ($PSCmdlet.ShouldProcess('local Java server processes', 'Stop Game Server and Login Server')) {
        Stop-L2ManagedProcess -Service 'game'
        Stop-L2ManagedProcess -Service 'login'
    }
    else {
        Write-Host 'Java server stop was not executed.'
        exit 0
    }

    foreach ($port in @(2106, 7777, 9014)) {
        if (Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue) {
            throw "Port $port is still listening after the Java stack stop."
        }
    }

    if ($IncludeDatabase) {
        & (Join-Path $PSScriptRoot 'stop-database.ps1') -Confirm:$false
        if ($LASTEXITCODE -ne 0) {
            throw "Database stop failed with exit code $LASTEXITCODE"
        }
    }

    Write-Host 'Local Java stack is stopped.'
    exit 0
}
catch {
    Write-Error "Unable to stop local stack: $($_.Exception.Message)"
    exit 1
}
