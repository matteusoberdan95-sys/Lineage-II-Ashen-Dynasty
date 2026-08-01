[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    if (-not $env:ANT_HOME) {
        $env:ANT_HOME = [Environment]::GetEnvironmentVariable('ANT_HOME', 'User')
    }
    if (-not $env:ANT_HOME) {
        $env:ANT_HOME = [Environment]::GetEnvironmentVariable('ANT_HOME', 'Machine')
    }
    if ($env:ANT_HOME) {
        $env:Path = (@((Join-Path $env:ANT_HOME 'bin'), $env:Path) -join ';')
    }

    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $moduleRoot = Join-Path $repositoryRoot 'server\source\l2jmobius-upstream\L2J_Mobius_CT_0_Interlude'
    $buildFile = Join-Path $moduleRoot 'build.xml'

    if (-not (Test-Path -LiteralPath $buildFile -PathType Leaf)) {
        throw "Build file was not found: $buildFile"
    }

    [xml]$buildProject = Get-Content -LiteralPath $buildFile -Raw -Encoding UTF8
    $targetNames = @($buildProject.project.target | ForEach-Object { [string]$_.name })
    $testTargets = @($targetNames | Where-Object { $_ -match '^(test|tests|check)$' })

    $testFrameworkPatterns = @(
        'org\.junit',
        'junit-jupiter',
        'org\.testng',
        '@Test\b'
    )
    $javaFiles = Get-ChildItem -LiteralPath (Join-Path $moduleRoot 'java') -Filter '*.java' -Recurse -File
    $frameworkMatches = @(
        $javaFiles |
            Select-String -Pattern $testFrameworkPatterns -CaseSensitive:$false |
            Select-Object -First 1
    )

    if (($testTargets.Count -eq 0) -and ($frameworkMatches.Count -eq 0)) {
        Write-Warning 'No automated test target or JUnit/TestNG usage exists in the audited module.'
        Write-Output 'NO_AUTOMATED_TESTS_AVAILABLE'
        exit 0
    }

    if ($testTargets.Count -eq 0) {
        throw 'Test framework references were found, but build.xml exposes no automated test target.'
    }

    $antCommand = Get-Command 'ant' -ErrorAction SilentlyContinue
    if (-not $antCommand) {
        throw 'Required command was not found: ant'
    }

    foreach ($target in $testTargets) {
        Write-Host "Running Ant test target: $target"
        & $antCommand.Source -f $buildFile $target
        if ($LASTEXITCODE -ne 0) {
            throw "Ant test target '$target' failed with exit code $LASTEXITCODE"
        }
    }

    Write-Output 'AUTOMATED_TESTS_PASSED'
    exit 0
}
catch {
    Write-Error "Test execution failed: $($_.Exception.Message)"
    exit 1
}
