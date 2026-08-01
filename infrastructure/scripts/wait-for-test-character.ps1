[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_test',

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
        $l2Count = @(Get-Process -Name 'L2' -ErrorAction SilentlyContinue).Count
        $loginConnections = @(Get-NetTCPConnection -State Established -LocalPort 2106 -ErrorAction SilentlyContinue).Count
        $gameConnections = @(Get-NetTCPConnection -State Established -LocalPort 7777 -ErrorAction SilentlyContinue).Count

        $credential = Get-L2DatabaseCredential
        $dbPassword = ConvertFrom-L2SecureString -SecureString $credential.Password
        try {
            $characterCount = Invoke-L2MariaDbSql `
                -User $script:L2DatabaseUser `
                -PlainTextPassword $dbPassword `
                -Database $script:L2DatabaseName `
                -Sql "SELECT COUNT(*) FROM characters WHERE account_name = '$safeUser';"
            $account = Invoke-L2MariaDbSql `
                -User $script:L2DatabaseUser `
                -PlainTextPassword $dbPassword `
                -Database $script:L2DatabaseName `
                -Sql "SELECT login, IFNULL(lastIP, ''), lastactive FROM accounts WHERE login = '$safeUser';"
        }
        finally {
            $dbPassword = $null
        }

        Write-Host ("{0:HH:mm:ss} client={1} loginConn={2} gameConn={3} chars={4} account={5}" -f `
            (Get-Date), $l2Count, $loginConnections, $gameConnections, $characterCount, ($account -replace '\s+', ' '))

        if ([int]$characterCount -ge 1) {
            Write-Host 'CHARACTER_PERSISTED'
            exit 0
        }

        Start-Sleep -Seconds 15
    }

    Write-Error "Timed out waiting for a character on account '$Username'."
    exit 2
}
catch {
    $dbPassword = $null
    Write-Error "Wait for test character failed: $($_.Exception.Message)"
    exit 1
}
