[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'database-common.ps1')

$rootPassword = $null
$applicationPassword = $null

try {
    Assert-L2MariaDbLocal

    $repositoryRoot = Get-L2RepositoryRoot
    $sourceSqlRoot = Join-Path $repositoryRoot 'server\source\l2jmobius-upstream\L2J_Mobius_CT_0_Interlude\dist\db_installer\sql'
    $databaseTemplate = Join-Path $PSScriptRoot 'create-local-databases.sql'
    $userTemplate = Join-Path $PSScriptRoot 'create-local-user.sql'
    $credentialPath = Get-L2DatabaseCredentialPath

    foreach ($requiredPath in @($sourceSqlRoot, $databaseTemplate, $userTemplate)) {
        if (-not (Test-Path -LiteralPath $requiredPath)) {
            throw "Required path was not found: $requiredPath"
        }
    }

    $loginFiles = @(Get-ChildItem -LiteralPath (Join-Path $sourceSqlRoot 'login') -Filter '*.sql' -File | Sort-Object Name)
    $gameFiles = @(Get-ChildItem -LiteralPath (Join-Path $sourceSqlRoot 'game') -Filter '*.sql' -File | Sort-Object Name)
    $sqlFiles = @($loginFiles + $gameFiles)

    if ($loginFiles.Count -ne 4) {
        throw "Expected 4 login SQL files, found $($loginFiles.Count)."
    }
    if ($gameFiles.Count -ne 96) {
        throw "Expected 96 game SQL files, found $($gameFiles.Count)."
    }

    $expectedTables = foreach ($sqlFile in $sqlFiles) {
        $content = Get-Content -LiteralPath $sqlFile.FullName -Raw -Encoding UTF8
        $match = [regex]::Match(
            $content,
            '(?im)^\s*CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?`?([A-Za-z0-9_]+)`?'
        )
        if (-not $match.Success) {
            throw "Unable to identify the table created by: $($sqlFile.FullName)"
        }
        $match.Groups[1].Value
    }
    $expectedTables = @($expectedTables | Sort-Object -Unique)

    if ($expectedTables.Count -ne 100) {
        throw "Expected 100 unique tables, found $($expectedTables.Count)."
    }

    Write-Host 'Administrative authentication is required once.'
    Write-Host 'Enter the local MariaDB root password in the Windows credential dialog.'
    $rootCredential = Get-Credential -UserName 'root' -Message 'Ashen Dynasty local MariaDB bootstrap'
    if (-not $rootCredential) {
        throw 'Administrative authentication was cancelled.'
    }
    $rootPassword = ConvertFrom-L2SecureString -SecureString $rootCredential.Password

    $existingTableCount = Invoke-L2MariaDbSql `
        -User 'root' `
        -PlainTextPassword $rootPassword `
        -Sql "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$script:L2DatabaseName';"

    if ([int]$existingTableCount -gt 0) {
        throw "Database '$script:L2DatabaseName' already contains $existingTableCount tables. Refusing destructive re-import."
    }

    $databaseSql = Get-Content -LiteralPath $databaseTemplate -Raw -Encoding UTF8
    $null = Invoke-L2MariaDbSql `
        -User 'root' `
        -PlainTextPassword $rootPassword `
        -Sql $databaseSql

    $applicationPassword = New-L2DatabasePassword
    $escapedPassword = $applicationPassword.Replace('\', '\\').Replace("'", "''")
    $userTemplateContent = Get-Content -LiteralPath $userTemplate -Raw -Encoding UTF8
    $userSql = $userTemplateContent.Replace('__L2SERVER_PASSWORD__', $escapedPassword)
    $null = Invoke-L2MariaDbSql `
        -User 'root' `
        -PlainTextPassword $rootPassword `
        -Sql $userSql `
        -SensitiveValues @($applicationPassword, $escapedPassword)

    $credentialDirectory = Split-Path $credentialPath -Parent
    if (-not (Test-Path -LiteralPath $credentialDirectory)) {
        $null = New-Item -ItemType Directory -Path $credentialDirectory
    }
    $secureApplicationPassword = ConvertTo-SecureString $applicationPassword -AsPlainText -Force
    $applicationCredential = [Management.Automation.PSCredential]::new(
        $script:L2DatabaseUser,
        $secureApplicationPassword
    )
    $applicationCredential | Export-Clixml -LiteralPath $credentialPath -Force

    Write-Host "Importing $($loginFiles.Count) login SQL files and $($gameFiles.Count) game SQL files."
    $completed = 0
    foreach ($sqlFile in $sqlFiles) {
        $completed++
        Write-Progress `
            -Activity 'Importing L2JMobius Interlude schema' `
            -Status "$completed of $($sqlFiles.Count): $($sqlFile.Name)" `
            -PercentComplete (($completed / $sqlFiles.Count) * 100)

        $sql = Get-Content -LiteralPath $sqlFile.FullName -Raw -Encoding UTF8
        try {
            $null = Invoke-L2MariaDbSql `
                -User $script:L2DatabaseUser `
                -PlainTextPassword $applicationPassword `
                -Database $script:L2DatabaseName `
                -Sql $sql
        }
        catch {
            throw "Import failed in '$($sqlFile.Name)': $($_.Exception.Message)"
        }
    }
    Write-Progress -Activity 'Importing L2JMobius Interlude schema' -Completed

    $actualTableOutput = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $applicationPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = '$script:L2DatabaseName' AND TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME;"
    $actualTables = @($actualTableOutput -split "\r?\n" | Where-Object { $_ } | Sort-Object -Unique)
    $tableDifference = @(Compare-Object -ReferenceObject $expectedTables -DifferenceObject $actualTables)
    if ($tableDifference.Count -gt 0) {
        throw "Imported table set differs from the 100 audited SQL files: $($tableDifference | Out-String)"
    }

    $authenticatedAccount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $applicationPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SELECT CURRENT_USER();'
    if ($authenticatedAccount -ne "$script:L2DatabaseUser@$script:L2DatabaseHost") {
        throw "Unexpected authenticated account: $authenticatedAccount"
    }

    $grants = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $applicationPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SHOW GRANTS FOR CURRENT_USER;'
    if ($grants -match '(?i)ALL\s+PRIVILEGES\s+ON\s+\*\.\*') {
        throw 'Application user has global ALL PRIVILEGES.'
    }
    if ($grants -notmatch '(?i)l2jmobiusinterlude.*\.\*') {
        throw 'Application user does not have the expected schema grant.'
    }

    $applicationPassword = $null
    $rootPassword = $null

    Write-Host 'Database bootstrap completed.'
    Write-Host "Schema: $script:L2DatabaseName"
    Write-Host "Tables: $($actualTables.Count)"
    Write-Host "Application account: $authenticatedAccount"
    Write-Host 'Credential: DPAPI-protected local file (path intentionally not printed).'
    exit 0
}
catch {
    Write-Progress -Activity 'Importing L2JMobius Interlude schema' -Completed
    $applicationPassword = $null
    $rootPassword = $null
    Write-Error "Database bootstrap failed: $($_.Exception.Message)"
    exit 1
}
