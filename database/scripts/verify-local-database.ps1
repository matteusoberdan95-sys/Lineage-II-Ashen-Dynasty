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
    Write-Host 'System schema access: denied as expected'

    $plainTextPassword = $null
    exit 0
}
catch {
    $plainTextPassword = $null
    Write-Error "Database verification failed: $($_.Exception.Message)"
    exit 1
}
