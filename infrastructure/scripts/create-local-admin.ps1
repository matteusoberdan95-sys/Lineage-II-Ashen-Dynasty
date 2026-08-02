[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_admin',

    [ValidatePattern('^[A-Za-z0-9]{1,16}$')]
    [string]$CharacterName = 'ASHENADM',

    [ValidateRange(100, 100)]
    [int]$AccessLevel = 100,

    [switch]$RotatePassword
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')
. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

$plainTextPassword = $null
$dbPassword = $null

function Escape-L2SqlLiteral {
    param([Parameter(Mandatory)][string]$Value)
    return $Value.Replace("'", "''")
}

try {
    Assert-L2MariaDbLocal

    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before creating or rebuilding the local admin character (IdManager).'
    }

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $secretsRoot = Join-Path $repositoryRoot 'secrets'
    $credentialPath = Join-Path $secretsRoot 'local-admin-account.clixml'
    if (-not (Test-Path -LiteralPath $secretsRoot)) {
        $null = New-Item -ItemType Directory -Path $secretsRoot
    }

    $dbCredential = Get-L2DatabaseCredential
    $dbPassword = ConvertFrom-L2SecureString -SecureString $dbCredential.Password

    $safeUser = Escape-L2SqlLiteral $Username
    $safeChar = Escape-L2SqlLiteral $CharacterName

    $accountExists = [int](Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM accounts WHERE login = '$safeUser';")

    $characterRow = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT charId, account_name, accesslevel, online FROM characters WHERE char_name = '$safeChar';"

    $characterExists = -not [string]::IsNullOrWhiteSpace($characterRow)
    if ($characterExists) {
        $parts = $characterRow -split "`t"
        if ($parts.Count -lt 4) {
            throw "Unexpected character row for '$CharacterName'."
        }
        if ($parts[1] -ne $Username) {
            throw "Character '$CharacterName' already belongs to account '$($parts[1])'."
        }
        if ([int]$parts[3] -ne 0) {
            throw "Character '$CharacterName' is online. Log out before refreshing admin privileges."
        }
    }

    $nameConflict = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT account_name FROM characters WHERE char_name = '$safeChar' AND account_name <> '$safeUser';"
    if (-not [string]::IsNullOrWhiteSpace($nameConflict)) {
        throw "Character name '$CharacterName' is already used by account '$nameConflict'."
    }

    $needPassword = ($accountExists -eq 0) -or $RotatePassword
    $securePassword = $null
    if ($needPassword) {
        $plainTextPassword = -join (
            (48..57) + (65..90) + (97..122) |
                Get-Random -Count 16 |
                ForEach-Object { [char]$_ }
        )
        $securePassword = ConvertTo-SecureString -String $plainTextPassword -AsPlainText -Force
        $sha1 = [Security.Cryptography.SHA1]::Create()
        try {
            $hashBytes = $sha1.ComputeHash([Text.Encoding]::UTF8.GetBytes($plainTextPassword))
        }
        finally {
            $sha1.Dispose()
        }
        $hashBase64 = [Convert]::ToBase64String($hashBytes)
        if ($hashBase64.Length -gt 45) {
            throw 'Generated password hash exceeds the accounts.password column size.'
        }
    }
    elseif (Test-Path -LiteralPath $credentialPath -PathType Leaf) {
        $existingCredential = Import-Clixml -Path $credentialPath
        if ($existingCredential.Username -ne $Username) {
            throw "Credential file belongs to '$($existingCredential.Username)'. Use -RotatePassword or remove secrets/local-admin-account.clixml."
        }
        $securePassword = $existingCredential.Password
    }
    else {
        throw 'Admin account exists but credential file is missing. Re-run with -RotatePassword.'
    }

    $action = if ($characterExists) {
        'Refresh local Master admin account and character'
    }
    else {
        'Create local Master admin account and character'
    }
    if (-not $PSCmdlet.ShouldProcess("$Username / $CharacterName", $action)) {
        $plainTextPassword = $null
        $dbPassword = $null
        return
    }

    if ($accountExists -eq 0) {
        $null = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $dbPassword `
            -Database $script:L2DatabaseName `
            -SensitiveValues @($hashBase64) `
            -Sql @"
INSERT INTO accounts (login, password, accessLevel)
VALUES ('$safeUser', '$hashBase64', $AccessLevel);
"@
    }
    elseif ($RotatePassword) {
        $null = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $dbPassword `
            -Database $script:L2DatabaseName `
            -SensitiveValues @($hashBase64) `
            -Sql @"
UPDATE accounts
SET password = '$hashBase64',
    accessLevel = $AccessLevel
WHERE login = '$safeUser';
"@
    }
    else {
        $null = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $dbPassword `
            -Database $script:L2DatabaseName `
            -Sql @"
UPDATE accounts
SET accessLevel = $AccessLevel
WHERE login = '$safeUser';
"@
    }

    if (-not $characterExists) {
        $idSeedRaw = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $dbPassword `
            -Database $script:L2DatabaseName `
            -Sql "SELECT GREATEST(IFNULL((SELECT MAX(charId) FROM characters), 268435456), IFNULL((SELECT MAX(object_id) FROM items), 268435456));"
        $idSeedText = ([string]$idSeedRaw).Trim()
        if ($idSeedText -notmatch '^\d+$') {
            throw "Unable to allocate object ids. Seed was: $idSeedText"
        }
        $charId = [int]$idSeedText + 1
        $itemWeapon = $charId + 1
        $itemDag = $charId + 2
        $itemBoot = $charId + 3
        $itemGlove = $charId + 4
        $itemGuide = $charId + 5
        $itemAdena = $charId + 6

        $null = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $dbPassword `
            -Database $script:L2DatabaseName `
            -Sql @"
START TRANSACTION;

INSERT INTO characters (
    account_name, charId, char_name, level, maxHp, curHp, maxCp, curCp, maxMp, curMp,
    face, hairStyle, hairColor, sex, heading, x, y, z, exp, sp, karma, fame,
    pvpkills, pkkills, clanid, race, classid, base_class, deletetime, cancraft,
    title, title_color, accesslevel, online, onlinetime, char_slot, newbie,
    lastAccess, clan_privs, wantspeace, isin7sdungeon, power_grade, nobless,
    createDate, last_recom_date
) VALUES (
    '$safeUser', $charId, '$safeChar', 1, 126, 126, 50, 50, 40, 40,
    0, 0, 0, 0, 0, -71467, 258378, -3104, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    'Owner', 52479, $AccessLevel, 0, 0, 0, 1,
    0, 0, 0, 0, 0, 0,
    CURDATE(), 0
);

INSERT INTO items (owner_id, object_id, item_id, count, enchant_level, loc, loc_data, time_of_use, custom_type1, custom_type2, mana_left, time) VALUES
($charId, $itemWeapon, 2369, 1, 0, 'PAPERDOLL', 7, NULL, 0, 0, -1, -1),
($charId, $itemDag, 10, 1, 0, 'INVENTORY', 0, NULL, 0, 0, -1, -1),
($charId, $itemBoot, 1146, 1, 0, 'PAPERDOLL', 10, NULL, 0, 0, -1, -1),
($charId, $itemGlove, 1147, 1, 0, 'PAPERDOLL', 11, NULL, 0, 0, -1, -1),
($charId, $itemGuide, 5588, 1, 0, 'INVENTORY', 0, NULL, 0, 0, -1, -1),
($charId, $itemAdena, 57, 100000, 0, 'INVENTORY', 0, NULL, 0, 0, -1, -1);

INSERT INTO character_skills (charId, skill_id, skill_level, class_index) VALUES
($charId, 194, 1, 0),
($charId, 1322, 1, 0);

INSERT INTO character_shortcuts (charId, slot, page, type, shortcut_id, level, class_index) VALUES
($charId, 0, 0, 3, 2, '0', 0),
($charId, 3, 0, 3, 5, '0', 0),
($charId, 10, 0, 3, 0, '0', 0),
($charId, 11, 0, 1, $itemGuide, '0', 0);

INSERT INTO character_quests (charId, name, var, value) VALUES
($charId, 'Q00255_Tutorial', '<state>', 'Started'),
($charId, 'Q00255_Tutorial', 'Adena', '1'),
($charId, 'Q00255_Tutorial', 'Die', '1'),
($charId, 'Q00255_Tutorial', 'Ex', '2'),
($charId, 'Q00255_Tutorial', 'HP', '1'),
($charId, 'Q00255_Tutorial', 'ucMemo', '0'),
($charId, 'Q00999_T0Tutorial', '<state>', 'Started'),
($charId, 'Q00999_T0Tutorial', 'step', '1');

COMMIT;
"@
    }
    else {
        $null = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $dbPassword `
            -Database $script:L2DatabaseName `
            -Sql @"
UPDATE characters
SET accesslevel = $AccessLevel,
    title = 'Owner',
    title_color = 52479
WHERE char_name = '$safeChar' AND account_name = '$safeUser';
"@
    }

    $verifyAccount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT login, accessLevel FROM accounts WHERE login = '$safeUser';"
    if ($verifyAccount -notmatch "^$Username`t$AccessLevel$") {
        throw "Admin account verification failed: $verifyAccount"
    }

    $verifyCharacter = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT char_name, account_name, accesslevel, online, level FROM characters WHERE char_name = '$safeChar';"
    if ($verifyCharacter -notmatch "^$CharacterName`t$Username`t$AccessLevel`t0`t") {
        throw "Admin character verification failed: $verifyCharacter"
    }

    [pscustomobject]@{
        Username = $Username
        Password = $securePassword
        CharacterName = $CharacterName
        AccessLevel = $AccessLevel
        AccessName = 'Master'
        CreatedAt = (Get-Date).ToString('o')
        Purpose = 'Local Interlude server-owner GM only'
    } | Export-Clixml -Path $credentialPath

    $plainTextPassword = $null
    $dbPassword = $null
    Write-Host "Local Master admin ready: $Username / $CharacterName"
    Write-Host "Access level: $AccessLevel (Master, isGM=true)"
    Write-Host 'Password stored with DPAPI at secrets/local-admin-account.clixml'
    Write-Host 'Retrieve it with show-local-admin-account.ps1 when typing into the client.'
    Write-Host 'In-game: //admin  |  item create  |  teleport panels'
}
catch {
    $plainTextPassword = $null
    $dbPassword = $null
    throw "Local admin creation failed: $($_.Exception.Message)`n$($_.ScriptStackTrace)"
}
