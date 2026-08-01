[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$plainTextPassword = $null

try {
    Assert-L2MariaDbLocal

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $hexIdPath = Join-Path $repositoryRoot 'server\runtime\interlude\game\config\hexid.txt'
    if (Test-Path -LiteralPath $hexIdPath) {
        throw 'Runtime already has a HexID. Refusing to reset registration.'
    }

    $credential = Get-L2DatabaseCredential
    $plainTextPassword = ConvertFrom-L2SecureString -SecureString $credential.Password
    $registrationMetadata = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SELECT server_id, CHAR_LENGTH(hexid), CHAR_LENGTH(host) FROM gameservers ORDER BY server_id;'

    if (-not $registrationMetadata) {
        Write-Host 'Game server registration table is already empty.'
        $plainTextPassword = $null
        exit 0
    }

    $rows = @($registrationMetadata -split "\r?\n" | Where-Object { $_ })
    if (($rows.Count -ne 1) -or ($rows[0] -ne "2`t33`t0")) {
        throw 'Unexpected game server registration exists. Refusing destructive cleanup.'
    }

    if ($PSCmdlet.ShouldProcess('gameservers seed row 2', 'Remove public upstream registration before local enrollment')) {
        $null = Invoke-L2MariaDbSql `
            -User $script:L2DatabaseUser `
            -PlainTextPassword $plainTextPassword `
            -Database $script:L2DatabaseName `
            -Sql "DELETE FROM gameservers WHERE server_id = 2 AND CHAR_LENGTH(hexid) = 33 AND host = '';"
    }
    else {
        Write-Host 'Registration seed removal was not executed.'
        $plainTextPassword = $null
        exit 0
    }

    $remaining = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SELECT COUNT(*) FROM gameservers;'
    if ([int]$remaining -ne 0) {
        throw "Expected an empty registration table, found $remaining rows."
    }

    $plainTextPassword = $null
    Write-Host 'Public upstream Game Server registration removed.'
    Write-Host 'The first local Game Server start may enroll server ID 1.'
    exit 0
}
catch {
    $plainTextPassword = $null
    Write-Error "Game Server registration initialization failed: $($_.Exception.Message)"
    exit 1
}
