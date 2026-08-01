[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'database-common.ps1')

$plainTextPassword = $null

try {
    Assert-L2MariaDbLocal

    $credential = Get-L2DatabaseCredential
    $plainTextPassword = ConvertFrom-L2SecureString -SecureString $credential.Password

    $version = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SELECT VERSION();'
    if ($version -notmatch '^11\.4\.') {
        throw "MariaDB 11.4 was expected. Detected: $version"
    }

    $account = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SELECT CURRENT_USER();'
    if ($account -ne "$script:L2DatabaseUser@$script:L2DatabaseHost") {
        throw "Unexpected authenticated account: $account"
    }

    $schemaInfo = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT CONCAT(DEFAULT_CHARACTER_SET_NAME, '/', DEFAULT_COLLATION_NAME) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = '$script:L2DatabaseName';"
    if ($schemaInfo -notmatch '^utf8(mb3)?/utf8(mb3)?_unicode_ci$') {
        throw "Unexpected schema charset/collation: $schemaInfo"
    }

    $tableCount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$script:L2DatabaseName' AND TABLE_TYPE = 'BASE TABLE';"
    if ([int]$tableCount -ne 100) {
        throw "Expected 100 tables, found $tableCount."
    }

    $loginTableCount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$script:L2DatabaseName' AND TABLE_NAME IN ('account_data','accounts','accounts_ipauth','gameservers');"
    if ([int]$loginTableCount -ne 4) {
        throw "Expected 4 login tables, found $loginTableCount."
    }

    $sourceSqlRoot = Join-Path (Get-L2RepositoryRoot) 'server\source\l2jmobius-upstream\L2J_Mobius_CT_0_Interlude\dist\db_installer\sql'
    $expectedIndexes = @()
    foreach ($sqlFile in Get-ChildItem -LiteralPath $sourceSqlRoot -Filter '*.sql' -File -Recurse) {
        $content = Get-Content -LiteralPath $sqlFile.FullName -Raw -Encoding UTF8
        $indexMatches = [regex]::Matches(
            $content,
            '(?im)^\s*CREATE\s+(?:UNIQUE\s+)?INDEX\s+`?([A-Za-z0-9_]+)`?\s+ON\s+`?([A-Za-z0-9_]+)`?'
        )
        foreach ($indexMatch in $indexMatches) {
            $expectedIndexes += "$($indexMatch.Groups[2].Value).$($indexMatch.Groups[1].Value)"
        }
    }
    $expectedIndexes = @($expectedIndexes | Sort-Object -Unique)
    if ($expectedIndexes.Count -eq 0) {
        throw 'No standalone indexes were identified in the audited SQL files.'
    }

    $actualIndexOutput = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT CONCAT(TABLE_NAME, '.', INDEX_NAME) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = '$script:L2DatabaseName' AND INDEX_NAME <> 'PRIMARY' GROUP BY TABLE_NAME, INDEX_NAME ORDER BY TABLE_NAME, INDEX_NAME;"
    $actualIndexes = @($actualIndexOutput -split "\r?\n" | Where-Object { $_ } | Sort-Object -Unique)
    $missingIndexes = @(
        Compare-Object -ReferenceObject $expectedIndexes -DifferenceObject $actualIndexes |
            Where-Object SideIndicator -eq '<='
    )
    if ($missingIndexes.Count -gt 0) {
        throw "Expected standalone indexes are missing: $($missingIndexes.InputObject -join ', ')"
    }

    $grants = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SHOW GRANTS FOR CURRENT_USER;'
    if ($grants -match '(?i)ALL\s+PRIVILEGES\s+ON\s+\*\.\*') {
        throw 'Application user has global ALL PRIVILEGES.'
    }
    if ($grants -notmatch '(?i)l2jmobiusinterlude.*\.\*') {
        throw 'Expected schema grant was not found.'
    }

    $systemSchemaAccessDenied = $false
    try {
        $null = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $plainTextPassword `
            -Sql 'SELECT COUNT(*) FROM mysql.user;'
    }
    catch {
        if ($_.Exception.Message -match '(?i)(denied|command denied)') {
            $systemSchemaAccessDenied = $true
        }
        else {
            throw
        }
    }
    if (-not $systemSchemaAccessDenied) {
        throw 'Application user unexpectedly read mysql.user.'
    }

    Write-Host 'Database verification passed.'
    Write-Host "Version: $version"
    Write-Host "Account: $account"
    Write-Host "Schema: $script:L2DatabaseName"
    Write-Host "Charset/collation: $schemaInfo"
    Write-Host "Tables: $tableCount"
    Write-Host "Login tables: $loginTableCount"
    Write-Host "Audited standalone indexes: $($expectedIndexes.Count)"
    Write-Host 'System schema access: denied as expected'

    $plainTextPassword = $null
    exit 0
}
catch {
    $plainTextPassword = $null
    Write-Error "Database verification failed: $($_.Exception.Message)"
    exit 1
}
