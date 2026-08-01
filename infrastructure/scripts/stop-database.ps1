[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

try {
    $service = Get-Service -Name 'MariaDB' -ErrorAction SilentlyContinue
    if (-not $service) {
        throw 'The MariaDB service was not found.'
    }

    if ($service.Status -eq 'Stopped') {
        Write-Host 'MariaDB is already stopped.'
        exit 0
    }

    if ($PSCmdlet.ShouldProcess('MariaDB', 'Stop Windows service')) {
        Invoke-L2DatabaseServiceState -DesiredState 'Stopped'
    }
    else {
        Write-Host 'MariaDB stop was not executed.'
        exit 0
    }

    $listener = Get-NetTCPConnection `
        -State Listen `
        -LocalPort $script:L2DatabasePort `
        -ErrorAction SilentlyContinue
    if ($listener) {
        throw "Port $script:L2DatabasePort is still listening after the service stop."
    }

    Write-Host 'MariaDB is stopped.'
    exit 0
}
catch {
    Write-Error "Unable to stop MariaDB: $($_.Exception.Message)"
    exit 1
}
