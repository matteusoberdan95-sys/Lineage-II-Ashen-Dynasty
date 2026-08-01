[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$plainTextPassword = $null

try {
    Assert-L2MariaDbLocal

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $runtimeRoot = Join-Path $repositoryRoot 'server\runtime\interlude'
    $hexIdPath = Join-Path $runtimeRoot 'game\config\hexid.txt'
    $loginServerConfig = Join-Path $runtimeRoot 'login\config\Server.ini'
    foreach ($requiredPath in @($hexIdPath, $loginServerConfig)) {
        if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
            throw "Required registration file was not found: $requiredPath"
        }
    }

    $hexIdProperties = ConvertFrom-StringData (Get-Content -LiteralPath $hexIdPath -Raw)
    if ($hexIdProperties.ServerID -ne '1') {
        throw "Unexpected runtime ServerID: $($hexIdProperties.ServerID)"
    }
    if ([string]::IsNullOrWhiteSpace($hexIdProperties.HexID)) {
        throw 'Runtime HexID is empty.'
    }

    $credential = Get-L2DatabaseCredential
    $plainTextPassword = ConvertFrom-L2SecureString -SecureString $credential.Password
    $registeredCount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SELECT COUNT(*) FROM gameservers WHERE server_id = 1 AND CHAR_LENGTH(hexid) > 0;'
    if ([int]$registeredCount -ne 1) {
        throw 'Database does not contain the expected server ID 1 registration.'
    }

    $encoding = [Text.UTF8Encoding]::new($false)
    $content = [IO.File]::ReadAllText($loginServerConfig, $encoding)
    $regex = [regex]::new('(?m)^([ \t]*AcceptNewGameServer[ \t]*=[ \t]*).*$')
    if ($regex.Matches($content).Count -ne 1) {
        throw 'AcceptNewGameServer property was not found exactly once.'
    }
    $updated = $regex.Replace($content, '${1}False')
    [IO.File]::WriteAllText($loginServerConfig, $updated, $encoding)

    $plainTextPassword = $null
    Write-Host 'Game Server registration is persisted as server ID 1.'
    Write-Host 'AcceptNewGameServer is now False and applies after Login Server restart.'
    exit 0
}
catch {
    $plainTextPassword = $null
    Write-Error "Unable to lock Game Server registration: $($_.Exception.Message)"
    exit 1
}
