[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-ToolEnvironment {
    if (-not $env:JAVA_HOME) {
        $env:JAVA_HOME = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
    }
    if (-not $env:ANT_HOME) {
        $env:ANT_HOME = [Environment]::GetEnvironmentVariable('ANT_HOME', 'User')
    }
    if ($env:JAVA_HOME) {
        $env:Path = (@((Join-Path $env:JAVA_HOME 'bin'), $env:Path) -join ';')
    }
    if ($env:ANT_HOME) {
        $env:Path = (@((Join-Path $env:ANT_HOME 'bin'), $env:Path) -join ';')
    }
}

function Remove-GeneratedDirectory {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$RuntimeRoot
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    $resolvedRuntime = (Resolve-Path -LiteralPath $RuntimeRoot).Path.TrimEnd('\') + '\'
    $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
    $item = Get-Item -LiteralPath $resolvedPath -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Refusing to remove a generated directory through a reparse point: $resolvedPath"
    }
    if (-not $resolvedPath.StartsWith($resolvedRuntime, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a path outside server/runtime: $resolvedPath"
    }

    Remove-Item -LiteralPath $resolvedPath -Recurse -Force
}

try {
    Add-ToolEnvironment

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $runtimeRoot = Join-Path $repositoryRoot 'server\runtime'
    $sourceRoot = Join-Path $repositoryRoot 'server\source\l2jmobius-upstream'
    $sourceModule = Join-Path $sourceRoot 'L2J_Mobius_CT_0_Interlude'
    $workingModule = Join-Path $runtimeRoot 'local-build-source'
    $buildOutput = Join-Path $runtimeRoot 'local-build'
    $patchPath = Join-Path $repositoryRoot 'server\patches\0001-bind-gameserver-to-configured-host.patch'
    $artifactPath = Join-Path $buildOutput 'L2J_Mobius_CT_0_Interlude.zip'
    $expectedCommit = 'e4d1d8336ed28fc0916e7caad3ca752d06169eac'

    foreach ($requiredPath in @($sourceModule, $patchPath)) {
        if (-not (Test-Path -LiteralPath $requiredPath)) {
            throw "Required path was not found: $requiredPath"
        }
    }

    foreach ($commandName in @('git', 'java', 'javac', 'ant')) {
        if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
            throw "Required command was not found: $commandName"
        }
    }

    $sourceStatus = (& git -C $sourceRoot status --porcelain --untracked-files=no 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $sourceStatus) {
        throw "Source submodule is not clean: $sourceStatus"
    }
    $sourceCommit = (& git -C $sourceRoot rev-parse HEAD 2>&1 | Out-String).Trim()
    if ($sourceCommit -ne $expectedCommit) {
        throw "Unexpected source commit: $sourceCommit"
    }

    if (-not (Test-Path -LiteralPath $runtimeRoot)) {
        $null = New-Item -ItemType Directory -Path $runtimeRoot
    }
    Remove-GeneratedDirectory -Path $workingModule -RuntimeRoot $runtimeRoot
    Remove-GeneratedDirectory -Path $buildOutput -RuntimeRoot $runtimeRoot

    Write-Host 'Copying the audited module to disposable runtime storage.'
    Copy-Item -LiteralPath $sourceModule -Destination $workingModule -Recurse

    $patchedGameServer = Join-Path $workingModule 'java\org\l2jmobius\gameserver\GameServer.java'
    $patchedContent = Get-Content -LiteralPath $patchedGameServer -Raw -Encoding UTF8
    $originalBind = 'new InetSocketAddress(ServerConfig.PORT_GAME)'
    $expectedBind = 'new InetSocketAddress(ServerConfig.GAMESERVER_HOSTNAME, ServerConfig.PORT_GAME)'
    $patchContent = Get-Content -LiteralPath $patchPath -Raw -Encoding UTF8
    if (($patchContent -notlike "*-$([char]9)$([char]9)*$originalBind*") -or
        ($patchContent -notlike "*+$([char]9)$([char]9)*$expectedBind*")) {
        throw 'Versioned security patch does not describe the expected bind replacement.'
    }
    if ([regex]::Matches($patchedContent, [regex]::Escape($originalBind)).Count -ne 1) {
        throw 'Original GameServer bind was not found exactly once.'
    }
    $patchedContent = $patchedContent.Replace($originalBind, $expectedBind)
    [IO.File]::WriteAllText($patchedGameServer, $patchedContent, [Text.UTF8Encoding]::new($false))
    if ([regex]::Matches($patchedContent, [regex]::Escape($expectedBind)).Count -ne 1) {
        throw 'Localhost security bind was not applied exactly once.'
    }

    $stopwatch = [Diagnostics.Stopwatch]::StartNew()
    & ant -f (Join-Path $workingModule 'build.xml') "-Dbuild=$buildOutput" cleanup
    $antExitCode = $LASTEXITCODE
    $stopwatch.Stop()
    if ($antExitCode -ne 0) {
        throw "Patched Ant build failed with exit code $antExitCode"
    }
    if (-not (Test-Path -LiteralPath $artifactPath -PathType Leaf)) {
        throw "Expected patched artifact was not generated: $artifactPath"
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead($artifactPath)
    try {
        $entries = @($archive.Entries.FullName)
    }
    finally {
        $archive.Dispose()
    }
    foreach ($requiredEntry in @('libs/LoginServer.jar', 'libs/GameServer.jar')) {
        if ($entries -notcontains $requiredEntry) {
            throw "Patched artifact is missing: $requiredEntry"
        }
    }

    $artifactHash = (Get-FileHash -LiteralPath $artifactPath -Algorithm SHA256).Hash.ToLowerInvariant()
    @(
        "sourceCommit=$expectedCommit",
        'patch=0001-bind-gameserver-to-configured-host.patch',
        "artifactSha256=$artifactHash"
    ) | Set-Content -LiteralPath (Join-Path $buildOutput 'local-security-patches.txt') -Encoding ASCII

    Remove-GeneratedDirectory -Path $workingModule -RuntimeRoot $runtimeRoot

    Write-Host "Local security build completed in $($stopwatch.Elapsed)."
    Write-Host "Artifact: $artifactPath"
    Write-Host "SHA-256: $artifactHash"
    exit 0
}
catch {
    Write-Error "Local security build failed: $($_.Exception.Message)"
    exit 1
}
