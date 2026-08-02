[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_admin',

    [ValidatePattern('^[A-Za-z0-9]{1,16}$')]
    [string]$CharacterName = 'ASHENADM',

    [ValidateRange(100, 100)]
    [int]$AccessLevel = 100
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$dbPassword = $null

try {
    Assert-L2MariaDbLocal

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $credentialPath = Join-Path $repositoryRoot 'secrets\local-admin-account.clixml'
    $accessLevelsPath = Join-Path $repositoryRoot 'server\runtime\interlude\game\config\AccessLevels.xml'
    if (-not (Test-Path -LiteralPath $credentialPath -PathType Leaf)) {
        throw 'secrets/local-admin-account.clixml was not found.'
    }
    if (-not (Test-Path -LiteralPath $accessLevelsPath -PathType Leaf)) {
        throw "Runtime AccessLevels.xml was not found: $accessLevelsPath"
    }

    $credential = Import-Clixml -Path $credentialPath
    if ($credential.Username -ne $Username -or $credential.CharacterName -ne $CharacterName) {
        throw "Credential file does not match expected admin identity ($Username / $CharacterName)."
    }
    if ([int]$credential.AccessLevel -ne $AccessLevel) {
        throw "Credential AccessLevel is $($credential.AccessLevel), expected $AccessLevel."
    }

    $dbCredential = Get-L2DatabaseCredential
    $dbPassword = ConvertFrom-L2SecureString -SecureString $dbCredential.Password
    $safeUser = $Username.Replace("'", "''")
    $safeChar = $CharacterName.Replace("'", "''")

    $account = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT login, accessLevel FROM accounts WHERE login = '$safeUser';"
    if ($account -notmatch "^$Username`t$AccessLevel$") {
        throw "Account access verification failed: $account"
    }

    $character = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT char_name, account_name, accesslevel, online FROM characters WHERE char_name = '$safeChar';"
    if ($character -notmatch "^$CharacterName`t$Username`t$AccessLevel`t") {
        throw "Character access verification failed: $character"
    }

    $itemCount = [int](Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM items WHERE owner_id = (SELECT charId FROM characters WHERE char_name = '$safeChar');")
    if ($itemCount -lt 6) {
        throw "Admin character has fewer than 6 starting items: $itemCount"
    }

    $playtest = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT login, accessLevel FROM accounts WHERE login = 'ashen_test'; SELECT char_name, accesslevel FROM characters WHERE char_name = 'NEIDE157';"
    if ($playtest -notmatch 'ashen_test\t0' -or $playtest -notmatch 'NEIDE157\t0') {
        throw "Playtest account/character must remain accessLevel 0. Got: $playtest"
    }

    $accessXml = [IO.File]::ReadAllText($accessLevelsPath)
    if ($accessXml -notmatch 'access level="100" name="Master"[^>]*isGM="true"') {
        throw 'Runtime AccessLevels.xml does not define Master level 100 as GM.'
    }

    Write-Host 'Local admin verification passed.'
    Write-Host "Account: $Username accessLevel=$AccessLevel"
    Write-Host "Character: $CharacterName accesslevel=$AccessLevel (Master)"
    Write-Host 'Playtest ashen_test / NEIDE157 remain non-GM.'
}
catch {
    throw "Local admin verification failed: $($_.Exception.Message)"
}
finally {
    $dbPassword = $null
}
