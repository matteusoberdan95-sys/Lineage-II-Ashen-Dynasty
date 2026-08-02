[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [ValidatePattern('^[A-Za-z0-9_]{4,14}$')]
    [string]$Username = 'ashen_test',

    # Interlude login box is painful for long random passwords; keep 4-16 chars.
    [ValidatePattern('^[A-Za-z0-9!@#\$%\*_=\?\+\-]{4,16}$')]
    [string]$Password,

    [switch]$RotatePassword
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$plainTextPassword = $null
$dbPassword = $null

try {
    Assert-L2MariaDbLocal

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $secretsRoot = Join-Path $repositoryRoot 'secrets'
    $credentialPath = Join-Path $secretsRoot 'local-test-account.clixml'
    if (-not (Test-Path -LiteralPath $secretsRoot)) {
        $null = New-Item -ItemType Directory -Path $secretsRoot
    }

    $dbCredential = Get-L2DatabaseCredential
    $dbPassword = ConvertFrom-L2SecureString -SecureString $dbCredential.Password

    $existing = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql ("SELECT COUNT(*) FROM accounts WHERE login = '{0}';" -f $Username.Replace("'", "''"))

    if ($Password -and (-not $RotatePassword) -and ([int]$existing -gt 0)) {
        $RotatePassword = $true
    }

    if (([int]$existing -gt 0) -and (-not $RotatePassword)) {
        Write-Host "Account '$Username' already exists. Use -Password or -RotatePassword to replace the password."
        $dbPassword = $null
        exit 0
    }

    if ((Test-Path -LiteralPath $credentialPath) -and (-not $RotatePassword) -and ([int]$existing -eq 0)) {
        throw "Credential file exists for a missing account. Remove secrets/local-test-account.clixml or use -RotatePassword."
    }

    if ($Password) {
        $plainTextPassword = $Password
    }
    else {
        # Short local-only password: Interlude login rarely supports paste.
        $plainTextPassword = -join (
            ((97..122) + (48..57) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
        )
    }
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

    $action = if ([int]$existing -gt 0) { 'Update local test account password' } else { 'Create local test account' }
    if (-not $PSCmdlet.ShouldProcess($Username, $action)) {
        $plainTextPassword = $null
        $dbPassword = $null
        exit 0
    }

    if ([int]$existing -gt 0) {
        $sql = @"
UPDATE accounts
SET password = '$hashBase64',
    accessLevel = 0
WHERE login = '$Username';
"@
    }
    else {
        $sql = @"
INSERT INTO accounts (login, password, accessLevel)
VALUES ('$Username', '$hashBase64', 0);
"@
    }

    $null = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql $sql

    $verify = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $dbPassword `
        -Database $script:L2DatabaseName `
        -Sql ("SELECT login, accessLevel, CHAR_LENGTH(password) FROM accounts WHERE login = '{0}';" -f $Username.Replace("'", "''"))
    if ($verify -notmatch "^$Username`t0`t28$") {
        throw "Account verification failed for '$Username'."
    }

    [pscustomobject]@{
        Username = $Username
        Password = $securePassword
        CreatedAt = (Get-Date).ToString('o')
        Purpose = 'Local Interlude playtest only'
    } | Export-Clixml -Path $credentialPath

    $plainTextPassword = $null
    $dbPassword = $null
    Write-Host "Local test account ready: $Username"
    Write-Host "Password stored with DPAPI at secrets/local-test-account.clixml"
    Write-Host 'Retrieve it with show-local-account.ps1 when typing into the client.'
    exit 0
}
catch {
    $plainTextPassword = $null
    $dbPassword = $null
    Write-Error "Local account creation failed: $($_.Exception.Message)"
    exit 1
}
