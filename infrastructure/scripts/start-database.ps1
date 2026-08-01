[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

try {
    $service = Get-Service -Name 'MariaDB' -ErrorAction SilentlyContinue
    if (-not $service) {
        throw 'The MariaDB service was not found.'
    }

    if ($service.Status -ne 'Running') {
        if ($PSCmdlet.ShouldProcess('MariaDB', 'Start Windows service')) {
            Invoke-L2DatabaseServiceState -DesiredState 'Running'
        }
        else {
            Write-Host 'MariaDB start was not executed.'
            exit 0
        }
    }

    Assert-L2MariaDbLocal
    Write-Host "MariaDB is running on $script:L2DatabaseHost`:$script:L2DatabasePort."
    exit 0
}
catch {
    Write-Error "Unable to start MariaDB: $($_.Exception.Message)"
    exit 1
}
