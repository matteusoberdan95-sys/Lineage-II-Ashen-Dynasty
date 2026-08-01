[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')
. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

$plainTextPassword = $null

try {
    Assert-L2MariaDbLocal

    $context = Get-L2RuntimeContext
    $loginProcess = Get-L2ManagedProcess -Service 'login'
    $gameProcess = Get-L2ManagedProcess -Service 'game'
    if (-not $loginProcess -or -not $gameProcess) {
        throw 'Login Server and Game Server must both be running.'
    }

    $expectedListeners = [ordered]@{
        2106 = [int]$loginProcess.ProcessId
        9014 = [int]$loginProcess.ProcessId
        7777 = [int]$gameProcess.ProcessId
    }
    foreach ($entry in $expectedListeners.GetEnumerator()) {
        $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $entry.Key -ErrorAction SilentlyContinue)
        if (($listeners.Count -ne 1) -or
            ($listeners[0].LocalAddress -ne '127.0.0.1') -or
            ($listeners[0].OwningProcess -ne $entry.Value)) {
            throw "Unsafe or unexpected listener on port $($entry.Key)."
        }
    }

    $connections = @(Get-NetTCPConnection -ErrorAction SilentlyContinue |
        Where-Object OwningProcess -in @([int]$loginProcess.ProcessId, [int]$gameProcess.ProcessId))
    $externalConnections = @(
        $connections |
            Where-Object {
                ($_.State -ne 'Listen') -and
                ($_.RemoteAddress -notin @('127.0.0.1', '0.0.0.0', '::', '::1'))
            }
    )
    if ($externalConnections.Count -gt 0) {
        throw 'Unexpected external connection belongs to a Java server process.'
    }

    $loginLog = Get-Content -LiteralPath (Join-Path $context.LogsRoot 'login.stderr.log') -Raw
    $gameLog = Get-Content -LiteralPath (Join-Path $context.LogsRoot 'game.stderr.log') -Raw
    foreach ($pattern in @(
        'Database: Initialized with a valid connection\.',
        'Game server listener is listening on 127\.0\.0\.1:9014\.',
        'LoginServer: Login client listener started on 127\.0\.0\.1:2106\.'
    )) {
        if ($loginLog -notmatch $pattern) {
            throw "Login Server success evidence is missing: $pattern"
        }
    }
    foreach ($pattern in @(
        'Network Config: ipconfig\.xml exists, using manual configuration',
        'Database: Initialized with a valid connection\.',
        'SkillData: Loaded \d+ Skill templates',
        'ItemData: Loaded \d+ items in total\.',
        'NpcData: Loaded \d+ NPCs\.',
        'SpawnData: \d+ spawns have been initialized!',
        'GameServer: Server loaded in \d+ seconds\.',
        'LoginServerThread: Registered on login as Server 1:'
    )) {
        if ($gameLog -notmatch $pattern) {
            throw "Game Server success evidence is missing: $pattern"
        }
    }
    if (($loginLog + $gameLog) -match '(?im)\b(SEVERE|FATAL|Exception)\b') {
        throw 'A severe, fatal or exception marker exists in the current process logs.'
    }

    $loginConfig = Get-Content -LiteralPath (Join-Path $context.DistributionRoot 'login\config\Server.ini') -Raw
    foreach ($pattern in @(
        '(?m)^AcceptNewGameServer\s*=\s*False\s*$',
        '(?m)^AutoCreateAccounts\s*=\s*False\s*$',
        '(?m)^LoginserverHostname\s*=\s*127\.0\.0\.1\s*$',
        '(?m)^LoginHostname\s*=\s*127\.0\.0\.1\s*$'
    )) {
        if ($loginConfig -notmatch $pattern) {
            throw "Login Server hardening is missing: $pattern"
        }
    }

    [xml]$scriptsConfig = Get-Content -LiteralPath (Join-Path $context.DistributionRoot 'game\config\Scripts.xml') -Raw
    if (-not @($scriptsConfig.list.exclude | Where-Object file -eq 'custom')) {
        throw 'Custom script directory is not excluded.'
    }
    $hexIdPath = Join-Path $context.DistributionRoot 'game\config\hexid.txt'
    if (-not (Test-Path -LiteralPath $hexIdPath -PathType Leaf)) {
        throw 'Runtime HexID was not persisted.'
    }

    $credential = Get-L2DatabaseCredential
    $plainTextPassword = ConvertFrom-L2SecureString -SecureString $credential.Password
    $registrationCount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql 'SELECT COUNT(*) FROM gameservers WHERE server_id = 1 AND CHAR_LENGTH(hexid) > 0;'
    $tableCount = Invoke-L2MariaDbSql `
        -User $script:L2DatabaseUser `
        -PlainTextPassword $plainTextPassword `
        -Database $script:L2DatabaseName `
        -Sql "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$script:L2DatabaseName';"
    if ([int]$registrationCount -ne 1) {
        throw 'Expected Game Server registration was not found.'
    }
    if ([int]$tableCount -ne 100) {
        throw "Expected 100 database tables, found $tableCount."
    }

    $plainTextPassword = $null
    Write-Host 'Local server verification passed.'
    Write-Host 'Listeners: 127.0.0.1:2106, 127.0.0.1:9014, 127.0.0.1:7777'
    Write-Host 'Database: valid l2server connection, 100 tables'
    Write-Host 'Registration: server ID 1, enrollment locked'
    Write-Host 'External Java connections: none'
    Write-Host 'Custom script directory: excluded'
    exit 0
}
catch {
    $plainTextPassword = $null
    Write-Error "Local server verification failed: $($_.Exception.Message)"
    exit 1
}
