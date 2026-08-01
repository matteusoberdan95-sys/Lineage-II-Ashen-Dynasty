[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')
. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

$startedProcess = $null

try {
    Assert-L2MariaDbLocal

    foreach ($port in @(2106, 9014)) {
        if (Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue) {
            throw "Port $port is already in use."
        }
    }

    $startedProcess = Start-L2ManagedProcess -Service 'login'
    Wait-L2LocalPort -Port 2106 -Service 'login' -TimeoutSeconds 60
    Wait-L2LocalPort -Port 9014 -Service 'login' -TimeoutSeconds 60

    Write-Host "Login Server started with PID $($startedProcess.Id)."
    Write-Host 'Client listener: 127.0.0.1:2106'
    Write-Host 'Game Server listener: 127.0.0.1:9014'
    exit 0
}
catch {
    if ($startedProcess) {
        try {
            Stop-L2ManagedProcess -Service 'login'
        }
        catch {
            Write-Warning $_.Exception.Message
        }
    }
    Write-Error "Login Server start failed: $($_.Exception.Message)"
    exit 1
}
