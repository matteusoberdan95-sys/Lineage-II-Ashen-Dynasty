[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\database\scripts\database-common.ps1')

$plainTextPassword = $null

function Set-IniValue {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Value
    )

    $encoding = [Text.UTF8Encoding]::new($false)
    $content = [IO.File]::ReadAllText($Path, $encoding)
    $pattern = "(?m)^([ \t]*$([regex]::Escape($Key))[ \t]*=[ \t]*).*$"
    $regex = [regex]::new($pattern)
    $matches = $regex.Matches($content)
    if ($matches.Count -ne 1) {
        throw "Expected one '$Key' property in $Path, found $($matches.Count)."
    }

    $updated = $regex.Replace(
        $content,
        [Text.RegularExpressions.MatchEvaluator] {
            param($match)
            return $match.Groups[1].Value + $Value
        }
    )
    [IO.File]::WriteAllText($Path, $updated, $encoding)
}

try {
    Assert-L2MariaDbLocal

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $runtimeRoot = Join-Path $repositoryRoot 'server\runtime'
    $artifactPath = Join-Path $runtimeRoot 'local-build\L2J_Mobius_CT_0_Interlude.zip'
    $patchManifest = Join-Path $runtimeRoot 'local-build\local-security-patches.txt'
    $runtimePath = Join-Path $runtimeRoot 'interlude'
    $ipConfigTemplate = Join-Path $repositoryRoot 'infrastructure\configuration\game\ipconfig.xml'
    $scriptsTemplate = Join-Path $repositoryRoot 'infrastructure\configuration\game\Scripts.xml'

    foreach ($requiredPath in @($artifactPath, $patchManifest, $ipConfigTemplate, $scriptsTemplate)) {
        if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
            throw "Required file was not found: $requiredPath"
        }
    }
    if (Test-Path -LiteralPath $runtimePath) {
        throw "Runtime already exists. Refusing to overwrite logs, configuration or HexID: $runtimePath"
    }

    $credential = Get-L2DatabaseCredential
    $plainTextPassword = ConvertFrom-L2SecureString -SecureString $credential.Password

    Expand-Archive -LiteralPath $artifactPath -DestinationPath $runtimePath

    $loginPath = Join-Path $runtimePath 'login'
    $gamePath = Join-Path $runtimePath 'game'
    $loginServerConfig = Join-Path $loginPath 'config\Server.ini'
    $gameServerConfig = Join-Path $gamePath 'config\Server.ini'
    $loginDatabaseConfig = Join-Path $loginPath 'config\Database.ini'
    $gameDatabaseConfig = Join-Path $gamePath 'config\Database.ini'
    $loginInterfaceConfig = Join-Path $loginPath 'config\Interface.ini'
    $gameInterfaceConfig = Join-Path $gamePath 'config\Interface.ini'
    $gameGeneralConfig = Join-Path $gamePath 'config\General.ini'
    $publicHexIdPath = Join-Path $gamePath 'config\hexid.txt'

    foreach ($requiredPath in @(
        $loginServerConfig,
        $gameServerConfig,
        $loginDatabaseConfig,
        $gameDatabaseConfig,
        $loginInterfaceConfig,
        $gameInterfaceConfig,
        $gameGeneralConfig
    )) {
        if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
            throw "Extracted runtime file was not found: $requiredPath"
        }
    }

    Set-IniValue -Path $loginServerConfig -Key 'LoginserverHostname' -Value '127.0.0.1'
    Set-IniValue -Path $loginServerConfig -Key 'LoginserverPort' -Value '2106'
    Set-IniValue -Path $loginServerConfig -Key 'LoginHostname' -Value '127.0.0.1'
    Set-IniValue -Path $loginServerConfig -Key 'LoginPort' -Value '9014'
    Set-IniValue -Path $loginServerConfig -Key 'AcceptNewGameServer' -Value 'True'
    Set-IniValue -Path $loginServerConfig -Key 'AutoCreateAccounts' -Value 'False'
    Set-IniValue -Path $loginInterfaceConfig -Key 'EnableGUI' -Value 'False'

    Set-IniValue -Path $gameServerConfig -Key 'LoginHost' -Value '127.0.0.1'
    Set-IniValue -Path $gameServerConfig -Key 'LoginPort' -Value '9014'
    Set-IniValue -Path $gameServerConfig -Key 'GameserverHostname' -Value '127.0.0.1'
    Set-IniValue -Path $gameServerConfig -Key 'GameserverPort' -Value '7777'
    Set-IniValue -Path $gameServerConfig -Key 'PacketEncryption' -Value 'True'
    Set-IniValue -Path $gameServerConfig -Key 'RequestServerID' -Value '1'
    Set-IniValue -Path $gameServerConfig -Key 'AcceptAlternateID' -Value 'False'
    Set-IniValue -Path $gameInterfaceConfig -Key 'EnableGUI' -Value 'False'

    if (-not (Test-Path -LiteralPath $publicHexIdPath -PathType Leaf)) {
        throw 'Expected upstream public HexID was not found in the extracted runtime.'
    }
    Remove-Item -LiteralPath $publicHexIdPath -Force

    foreach ($key in @(
        'EverybodyHasAdminRights',
        'SkillCheckRemove',
        'CustomNpcData',
        'CustomTeleportTable',
        'CustomSkillsLoad',
        'CustomItemsLoad',
        'CustomMultisellLoad',
        'CustomBuyListLoad'
    )) {
        Set-IniValue -Path $gameGeneralConfig -Key $key -Value 'False'
    }
    Set-IniValue -Path $gameGeneralConfig -Key 'GMAudit' -Value 'True'

    $databaseUrl = 'jdbc:mysql://127.0.0.1:3306/l2jmobiusinterlude?useUnicode=true&characterEncoding=utf-8&allowPublicKeyRetrieval=true&useSSL=false&connectTimeout=10000&interactiveClient=true&sessionVariables=wait_timeout=600,interactive_timeout=600&autoReconnect=true'
    foreach ($databaseConfig in @($loginDatabaseConfig, $gameDatabaseConfig)) {
        Set-IniValue -Path $databaseConfig -Key 'URL' -Value $databaseUrl
        Set-IniValue -Path $databaseConfig -Key 'Login' -Value 'l2server'
        Set-IniValue -Path $databaseConfig -Key 'Password' -Value $plainTextPassword
        Set-IniValue -Path $databaseConfig -Key 'TestDatabaseConnections' -Value 'False'
        Set-IniValue -Path $databaseConfig -Key 'BackupDatabase' -Value 'False'
        Set-IniValue -Path $databaseConfig -Key 'MySqlBinLocation' -Value 'C:/Program Files/MariaDB 11.4/bin/'
    }

    Copy-Item -LiteralPath $ipConfigTemplate -Destination (Join-Path $gamePath 'config\ipconfig.xml')
    Copy-Item -LiteralPath $scriptsTemplate -Destination (Join-Path $gamePath 'config\Scripts.xml') -Force

    foreach ($directory in @(
        (Join-Path $runtimeRoot 'logs'),
        (Join-Path $runtimeRoot 'pids'),
        (Join-Path $loginPath 'log'),
        (Join-Path $gamePath 'log')
    )) {
        if (-not (Test-Path -LiteralPath $directory)) {
            $null = New-Item -ItemType Directory -Path $directory
        }
    }

    & (Join-Path $PSScriptRoot 'apply-local-product-customization.ps1')

    $artifactHash = (Get-FileHash -LiteralPath $artifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $runtimeMetadata = [ordered]@{
        sourceCommit = 'e4d1d8336ed28fc0916e7caad3ca752d06169eac'
        artifactSha256 = $artifactHash
        securityPatch = '0001-bind-gameserver-to-configured-host.patch'
        productCustomization = 'ADR-004 identity overlays'
        preparedAt = (Get-Date).ToString('o')
    }
    $runtimeMetadata | ConvertTo-Json | Set-Content `
        -LiteralPath (Join-Path $runtimePath 'local-runtime.json') `
        -Encoding UTF8
    Copy-Item -LiteralPath $patchManifest -Destination (Join-Path $runtimePath 'local-security-patches.txt')

    $plainTextPassword = $null
    Write-Host "Local runtime prepared: $runtimePath"
    Write-Host 'Login bind: 127.0.0.1:2106'
    Write-Host 'Game bind: 127.0.0.1:7777'
    Write-Host 'Game registration listener: 127.0.0.1:9014'
    Write-Host 'AutoCreateAccounts: False'
    Write-Host 'AcceptNewGameServer: True (temporary until first registration)'
    exit 0
}
catch {
    $plainTextPassword = $null
    Write-Error "Runtime preparation failed: $($_.Exception.Message)"
    exit 1
}
