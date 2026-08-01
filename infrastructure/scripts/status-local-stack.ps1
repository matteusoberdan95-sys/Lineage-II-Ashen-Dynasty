[CmdletBinding()]
param(
    [switch]$RequireRunning
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $databaseService = Get-Service -Name 'MariaDB' -ErrorAction SilentlyContinue
    $loginProcess = Get-L2ManagedProcess -Service 'login'
    $gameProcess = Get-L2ManagedProcess -Service 'game'
    $ports = @(Get-NetTCPConnection -State Listen -LocalPort 2106,7777,9014,3306 -ErrorAction SilentlyContinue)

    $status = @(
        [pscustomobject]@{
            Component = 'MariaDB'
            State = if ($databaseService) { $databaseService.Status } else { 'Missing' }
            PID = ($ports | Where-Object LocalPort -eq 3306 | Select-Object -ExpandProperty OwningProcess -First 1)
            Listener = ($ports | Where-Object LocalPort -eq 3306 | ForEach-Object { "$($_.LocalAddress):$($_.LocalPort)" }) -join ', '
        },
        [pscustomobject]@{
            Component = 'Login Server'
            State = if ($loginProcess) { 'Running' } else { 'Stopped' }
            PID = if ($loginProcess) { $loginProcess.ProcessId } else { $null }
            Listener = ($ports | Where-Object LocalPort -in @(2106, 9014) | ForEach-Object { "$($_.LocalAddress):$($_.LocalPort)" }) -join ', '
        },
        [pscustomobject]@{
            Component = 'Game Server'
            State = if ($gameProcess) { 'Running' } else { 'Stopped' }
            PID = if ($gameProcess) { $gameProcess.ProcessId } else { $null }
            Listener = ($ports | Where-Object LocalPort -eq 7777 | ForEach-Object { "$($_.LocalAddress):$($_.LocalPort)" }) -join ', '
        }
    )
    $status | Format-Table -AutoSize

    $unsafeListeners = @($ports | Where-Object LocalAddress -ne '127.0.0.1')
    if ($unsafeListeners.Count -gt 0) {
        throw "Non-local listeners detected: $($unsafeListeners | Format-Table | Out-String)"
    }

    $serverProcessIds = @(
        if ($loginProcess) { $loginProcess.ProcessId }
        if ($gameProcess) { $gameProcess.ProcessId }
    )
    if ($serverProcessIds.Count -gt 0) {
        $connections = @(Get-NetTCPConnection -ErrorAction SilentlyContinue |
            Where-Object OwningProcess -in $serverProcessIds)
        $unexpectedConnections = @(
            $connections |
                Where-Object {
                    ($_.State -ne 'Listen') -and
                    ($_.RemoteAddress -notin @('127.0.0.1', '0.0.0.0', '::', '::1'))
                }
        )
        if ($unexpectedConnections.Count -gt 0) {
            throw "Unexpected server network connections detected: $($unexpectedConnections | Format-Table | Out-String)"
        }
    }

    if ($RequireRunning) {
        if (-not $databaseService -or $databaseService.Status -ne 'Running') {
            throw 'MariaDB is not running.'
        }
        if (-not $loginProcess -or -not $gameProcess) {
            throw 'Login Server and Game Server are not both running.'
        }
        foreach ($port in @(2106, 7777, 9014, 3306)) {
            if (-not ($ports | Where-Object LocalPort -eq $port)) {
                throw "Required port is not listening: $port"
            }
        }
    }

    Write-Host 'Local stack status validation passed.'
    exit 0
}
catch {
    Write-Error "Local stack status failed: $($_.Exception.Message)"
    exit 1
}
