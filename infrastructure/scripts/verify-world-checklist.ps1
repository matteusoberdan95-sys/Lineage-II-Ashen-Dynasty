[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_test',

    [ValidateSet('Any', 'Online', 'Offline')]
    [string]$ExpectedOnlineState = 'Any'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')
. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

$dbPassword = $null

try {
    Assert-L2MariaDbLocal

    if (-not (Get-L2ManagedProcess -Service 'login') -or -not (Get-L2ManagedProcess -Service 'game')) {
        throw 'Login Server and Game Server must both be running.'
    }

    foreach ($port in @(2106, 7777, 9014, 3306)) {
        $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
        if (($listeners.Count -lt 1) -or @($listeners | Where-Object LocalAddress -ne '127.0.0.1').Count) {
            throw "Required local listener missing or unsafe on port $port."
        }
    }

    $safeUser = $Username.Replace("'", "''")
    $credential = Get-L2DatabaseCredential
    $dbPassword = ConvertFrom-L2SecureString -SecureString $credential.Password

    $accountRow = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT login, accessLevel, IFNULL(lastIP, ''), lastServer FROM accounts WHERE login = '$safeUser';"
    if ($accountRow -notmatch "^$Username`t0`t127\.0\.0\.1`t1$") {
        throw "Account checklist failed: $accountRow"
    }

    $characterRow = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT char_name, level, classid, online, x, y, z FROM characters WHERE account_name = '$safeUser';"
    if (-not $characterRow) {
        throw "Character checklist failed: no character for '$Username'."
    }

    $parts = $characterRow -split "`t"
    $charName = $parts[0]
    $level = [int]$parts[1]
    $classId = [int]$parts[2]
    $online = [int]$parts[3]
    $x = [int]$parts[4]
    $y = [int]$parts[5]
    $z = [int]$parts[6]

    if ($charName -ne 'NEIDE157') {
        throw "Unexpected character name: $charName"
    }
    if ($level -lt 1) {
        throw "Character level is invalid: $level"
    }
    if ($classId -lt 0) {
        throw "Character class is invalid: $classId"
    }
    if (($x -eq 0) -and ($y -eq 0) -and ($z -eq 0)) {
        throw 'Character coordinates look unset (0,0,0).'
    }
    if (($ExpectedOnlineState -eq 'Online') -and ($online -ne 1)) {
        throw "Expected character online=1, found $online."
    }
    if (($ExpectedOnlineState -eq 'Offline') -and ($online -ne 0)) {
        throw "Expected character online=0, found $online."
    }

    $itemCount = [int](Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM items i INNER JOIN characters c ON c.charId = i.owner_id WHERE c.account_name = '$safeUser';")
    if ($itemCount -lt 1) {
        throw 'Character has no persisted items.'
    }

    $tableCount = [int](Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$script:L2DatabaseName';")
    if ($tableCount -ne 100) {
        throw "Expected 100 tables, found $tableCount."
    }

    $dbPassword = $null

    Write-Host 'World checklist passed.'
    Write-Host "Account: $accountRow"
    Write-Host "Character: $characterRow"
    Write-Host "Items: $itemCount"
    Write-Host "Online state check: $ExpectedOnlineState (actual=$online)"
    Write-Host 'Listeners: 127.0.0.1 only for 2106/7777/9014/3306'
    exit 0
}
catch {
    $dbPassword = $null
    Write-Error "World checklist failed: $($_.Exception.Message)"
    exit 1
}
