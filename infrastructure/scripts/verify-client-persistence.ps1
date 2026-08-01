[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_test'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')
. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

$dbPassword = $null

try {
    Assert-L2MariaDbLocal

    $loginProcess = Get-L2ManagedProcess -Service 'login'
    $gameProcess = Get-L2ManagedProcess -Service 'game'
    if (-not $loginProcess -or -not $gameProcess) {
        throw 'Login Server and Game Server must both be running.'
    }

    $dbCredential = Get-L2DatabaseCredential
    $dbPassword = ConvertFrom-L2SecureString -SecureString $dbCredential.Password
    $safeUser = $Username.Replace("'", "''")

    $account = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT login, accessLevel, IFNULL(lastIP,''), lastServer FROM accounts WHERE login = '$safeUser';"
    if (-not $account) {
        throw "Account '$Username' was not found."
    }

    $characters = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql @"
SELECT char_name, level, classid, online, x, y, z
FROM characters
WHERE account_name = '$safeUser'
ORDER BY charId;
"@

    $characterCount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM characters WHERE account_name = '$safeUser';"

    $dbPassword = $null

    Write-Host "Account: $account"
    if ([int]$characterCount -lt 1) {
        throw "No characters found for '$Username'. Create one in the local client and rerun this script."
    }

    Write-Host "Characters ($characterCount):"
    Write-Host $characters
    Write-Host 'Persistence verification passed.'
    exit 0
}
catch {
    $dbPassword = $null
    Write-Error "Client persistence verification failed: $($_.Exception.Message)"
    exit 1
}
