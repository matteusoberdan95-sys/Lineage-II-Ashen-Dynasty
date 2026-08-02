[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_test',

    [Parameter(Mandatory)]
    [ValidateSet(0, 1)]
    [int]$ExpectedOnline,

    [int]$TimeoutMinutes = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$dbPassword = $null
$deadline = (Get-Date).AddMinutes($TimeoutMinutes)

try {
    Assert-L2MariaDbLocal
    $safeUser = $Username.Replace("'", "''")

    while ((Get-Date) -lt $deadline) {
        $credential = Get-L2DatabaseCredential
        $dbPassword = ConvertFrom-L2SecureString -SecureString $credential.Password
        try {
            $row = Invoke-L2MariaDbSql `
                -User $script:L2DatabaseUser `
                -PlainTextPassword $dbPassword `
                -Database $script:L2DatabaseName `
                -Sql "SELECT char_name, online, x, y, z FROM characters WHERE account_name = '$safeUser';"
        }
        finally {
            $dbPassword = $null
        }

        if (-not $row) {
            throw "Character for '$Username' was not found."
        }

        $parts = $row -split "`t"
        $online = [int]$parts[1]
        $clientCount = @(Get-Process -Name 'L2' -ErrorAction SilentlyContinue).Count
        $gameConnections = @(Get-NetTCPConnection -State Established -LocalPort 7777 -ErrorAction SilentlyContinue).Count

        Write-Host ("{0:HH:mm:ss} character={1} online={2} expected={3} client={4} gameConn={5} pos={6},{7},{8}" -f `
            (Get-Date), $parts[0], $online, $ExpectedOnline, $clientCount, $gameConnections, $parts[2], $parts[3], $parts[4])

        if ($online -eq $ExpectedOnline) {
            Write-Host "ONLINE_STATE_MATCH=$ExpectedOnline"
            exit 0
        }

        Start-Sleep -Seconds 5
    }

    throw "Timed out waiting for online=$ExpectedOnline on account '$Username'."
}
catch {
    $dbPassword = $null
    Write-Error "Wait for online state failed: $($_.Exception.Message)"
    exit 1
}
