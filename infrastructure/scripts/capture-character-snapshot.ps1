[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_test',

    [string]$Label = 'snapshot'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$dbPassword = $null

try {
    Assert-L2MariaDbLocal

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $outputRoot = Join-Path $repositoryRoot 'server\runtime\logs'
    if (-not (Test-Path -LiteralPath $outputRoot)) {
        $null = New-Item -ItemType Directory -Path $outputRoot
    }

    $safeUser = $Username.Replace("'", "''")
    $credential = Get-L2DatabaseCredential
    $dbPassword = ConvertFrom-L2SecureString -SecureString $credential.Password

    $account = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT login, accessLevel, IFNULL(lastIP, ''), lastServer, lastactive FROM accounts WHERE login = '$safeUser';"

    $character = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT charId, char_name, level, classid, online, x, y, z, IFNULL(onlinetime, 0), lastAccess FROM characters WHERE account_name = '$safeUser';"

    $itemCount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM items i INNER JOIN characters c ON c.charId = i.owner_id WHERE c.account_name = '$safeUser';"

    $itemSample = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql @"
SELECT i.item_id, i.count, i.loc, i.enchant_level
FROM items i
INNER JOIN characters c ON c.charId = i.owner_id
WHERE c.account_name = '$safeUser'
ORDER BY i.object_id
LIMIT 20;
"@

    $dbPassword = $null

    if (-not $account) {
        throw "Account '$Username' was not found."
    }
    if (-not $character) {
        throw "No character found for '$Username'."
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $safeLabel = ($Label -replace '[^A-Za-z0-9_-]', '_')
    $outputPath = Join-Path $outputRoot ("character-$safeLabel-$stamp.json")

    $snapshot = [ordered]@{
        capturedAt = (Get-Date).ToString('o')
        username = $Username
        account = $account
        character = $character
        itemCount = [int]$itemCount
        itemSample = @($itemSample -split "`r?`n" | Where-Object { $_ })
        clientProcessCount = @(Get-Process -Name 'L2' -ErrorAction SilentlyContinue).Count
        loginConnections = @(Get-NetTCPConnection -State Established -LocalPort 2106 -ErrorAction SilentlyContinue).Count
        gameConnections = @(Get-NetTCPConnection -State Established -LocalPort 7777 -ErrorAction SilentlyContinue).Count
    }

    $snapshot | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $outputPath -Encoding UTF8
    Write-Host "Snapshot written: $outputPath"
    Write-Host "Account: $account"
    Write-Host "Character: $character"
    Write-Host "Items: $itemCount"
    Write-Host ("Client/L2 processes: {0}; loginConn={1}; gameConn={2}" -f `
        $snapshot.clientProcessCount, $snapshot.loginConnections, $snapshot.gameConnections)
    exit 0
}
catch {
    $dbPassword = $null
    Write-Error "Character snapshot failed: $($_.Exception.Message)"
    exit 1
}
