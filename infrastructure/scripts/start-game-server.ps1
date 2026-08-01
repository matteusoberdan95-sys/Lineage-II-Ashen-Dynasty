[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')
. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

$startedProcess = $null

try {
    Assert-L2MariaDbLocal

    if (-not (Get-L2ManagedProcess -Service 'login')) {
        throw 'Login Server must be running before Game Server.'
    }
    foreach ($port in @(2106, 9014)) {
        $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
        if (($listeners.Count -eq 0) -or @($listeners | Where-Object LocalAddress -ne '127.0.0.1').Count) {
            throw "Login Server listener is not safely available on 127.0.0.1:$port."
        }
    }
    if (Get-NetTCPConnection -State Listen -LocalPort 7777 -ErrorAction SilentlyContinue) {
        throw 'Port 7777 is already in use.'
    }

    $startedProcess = Start-L2ManagedProcess -Service 'game'
    Wait-L2LocalPort -Port 7777 -Service 'game' -TimeoutSeconds 240

    $context = Get-L2RuntimeContext
    $logPaths = @(
        (Join-Path $context.LogsRoot 'game.stdout.log'),
        (Join-Path $context.LogsRoot 'game.stderr.log')
    )
    $deadline = (Get-Date).AddSeconds(120)
    $registered = $false
    while ((Get-Date) -lt $deadline) {
        if (-not (Get-L2ManagedProcess -Service 'game')) {
            throw 'Game Server exited while waiting for Login Server registration.'
        }
        foreach ($logPath in $logPaths) {
            if (Test-Path -LiteralPath $logPath) {
                $logContent = Get-Content -LiteralPath $logPath -Raw -ErrorAction SilentlyContinue
                if ($logContent -match 'Registered on login as Server\s+1:') {
                    $registered = $true
                    break
                }
                if ($logContent -match '(?i)Registration failed:') {
                    throw 'Game Server registration was rejected. Review game process logs.'
                }
            }
        }
        if ($registered) {
            break
        }
        Start-Sleep -Milliseconds 500
    }
    if (-not $registered) {
        throw 'Timed out waiting for Game Server registration.'
    }

    $hexIdPath = Join-Path $context.DistributionRoot 'game\config\hexid.txt'
    if (-not (Test-Path -LiteralPath $hexIdPath -PathType Leaf)) {
        throw 'Game Server registered but did not persist config/hexid.txt.'
    }

    Write-Host "Game Server started with PID $($startedProcess.Id)."
    Write-Host 'Game listener: 127.0.0.1:7777'
    Write-Host 'Login registration: server ID 1'
    exit 0
}
catch {
    if ($startedProcess) {
        try {
            Stop-L2ManagedProcess -Service 'game'
        }
        catch {
            Write-Warning $_.Exception.Message
        }
    }
    Write-Error "Game Server start failed: $($_.Exception.Message)"
    exit 1
}
