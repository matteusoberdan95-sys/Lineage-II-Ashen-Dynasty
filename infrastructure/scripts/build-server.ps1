[CmdletBinding()]
param(
    [switch]$NoClean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Import-ToolEnvironment {
    if (-not $env:JAVA_HOME) {
        $env:JAVA_HOME = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
    }
    if (-not $env:JAVA_HOME) {
        $env:JAVA_HOME = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User')
    }
    if (-not $env:ANT_HOME) {
        $env:ANT_HOME = [Environment]::GetEnvironmentVariable('ANT_HOME', 'User')
    }
    if (-not $env:ANT_HOME) {
        $env:ANT_HOME = [Environment]::GetEnvironmentVariable('ANT_HOME', 'Machine')
    }

    $toolDirectories = @()
    if ($env:JAVA_HOME) {
        $toolDirectories += Join-Path $env:JAVA_HOME 'bin'
    }
    if ($env:ANT_HOME) {
        $toolDirectories += Join-Path $env:ANT_HOME 'bin'
    }

    if ($toolDirectories.Count -gt 0) {
        $env:Path = (($toolDirectories + $env:Path) -join ';')
    }
}

function Get-RequiredCommand {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $command) {
        throw "Required command was not found: $Name"
    }

    return $command
}

try {
    Import-ToolEnvironment

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $sourceRoot = Join-Path $repositoryRoot 'server\source\l2jmobius-upstream'
    $moduleRoot = Join-Path $sourceRoot 'L2J_Mobius_CT_0_Interlude'
    $buildFile = Join-Path $moduleRoot 'build.xml'
    $buildOutput = Join-Path $repositoryRoot 'server\runtime\build'
    $artifact = Join-Path $buildOutput 'L2J_Mobius_CT_0_Interlude.zip'
    $cleanScript = Join-Path $PSScriptRoot 'clean-server.ps1'
    $expectedSourceCommit = 'e4d1d8336ed28fc0916e7caad3ca752d06169eac'

    foreach ($requiredPath in @($sourceRoot, $moduleRoot, $buildFile, $cleanScript)) {
        if (-not (Test-Path -LiteralPath $requiredPath)) {
            throw "Required path was not found: $requiredPath"
        }
    }

    $null = Get-RequiredCommand -Name 'git'
    $javaCommand = Get-RequiredCommand -Name 'java'
    $javacCommand = Get-RequiredCommand -Name 'javac'
    $antCommand = Get-RequiredCommand -Name 'ant'

    $javaVersion = (& $javaCommand.Source --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "java --version failed with exit code $LASTEXITCODE"
    }
    if ($javaVersion -notmatch '(?m)^(openjdk|java) 25\.') {
        throw "JDK 25 is required. Detected:`n$javaVersion"
    }

    $javacVersion = (& $javacCommand.Source --version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "javac --version failed with exit code $LASTEXITCODE"
    }
    if ($javacVersion -notmatch '^javac 25\.') {
        throw "JDK 25 compiler is required. Detected: $javacVersion"
    }

    $antVersion = (& $antCommand.Source -version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "ant -version failed with exit code $LASTEXITCODE"
    }
    if ($antVersion -notmatch 'version 1\.10\.17\b') {
        throw "Apache Ant 1.10.17 is required for the reproducible baseline. Detected: $antVersion"
    }

    $sourceChanges = (& git -C $sourceRoot status --porcelain --untracked-files=no 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to inspect the source submodule: $sourceChanges"
    }
    if ($sourceChanges) {
        throw "The source submodule has tracked changes. Build aborted:`n$sourceChanges"
    }

    $sourceCommit = (& git -C $sourceRoot rev-parse HEAD 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read the source commit: $sourceCommit"
    }
    if ($sourceCommit -ne $expectedSourceCommit) {
        throw "Unexpected source commit. Expected $expectedSourceCommit, detected $sourceCommit"
    }

    if (-not $NoClean) {
        & $cleanScript -Confirm:$false
        if ($LASTEXITCODE -ne 0) {
            throw "Clean script failed with exit code $LASTEXITCODE"
        }
    }

    Write-Host "Java:`n$javaVersion"
    Write-Host "Compiler: $javacVersion"
    Write-Host "Build tool: $antVersion"
    Write-Host "Module: $moduleRoot"
    Write-Host "Output: $buildOutput"

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    & $antCommand.Source -f $buildFile "-Dbuild=$buildOutput" cleanup
    $antExitCode = $LASTEXITCODE
    $stopwatch.Stop()

    if ($antExitCode -ne 0) {
        throw "Ant build failed with exit code $antExitCode"
    }
    if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) {
        throw "Expected artifact was not generated: $artifact"
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($artifact)
    try {
        $entries = @($archive.Entries | ForEach-Object { $_.FullName })
    }
    finally {
        $archive.Dispose()
    }

    $requiredEntries = @(
        'libs/LoginServer.jar',
        'libs/GameServer.jar',
        'db_installer/DatabaseInstaller.jar'
    )
    foreach ($entry in $requiredEntries) {
        if ($entries -notcontains $entry) {
            throw "Expected archive entry was not generated: $entry"
        }
    }

    $artifactHash = (Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash.ToLowerInvariant()
    $artifactSize = (Get-Item -LiteralPath $artifact).Length

    Write-Host "Build completed in $($stopwatch.Elapsed)."
    Write-Host "Artifact: $artifact"
    Write-Host "Size: $artifactSize bytes"
    Write-Host "SHA-256: $artifactHash"
    exit 0
}
catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}
