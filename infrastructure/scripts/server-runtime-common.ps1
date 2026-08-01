Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-L2RuntimeContext {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $runtimeRoot = Join-Path $repositoryRoot 'server\runtime'
    return [pscustomobject]@{
        RepositoryRoot = $repositoryRoot
        RuntimeRoot = $runtimeRoot
        DistributionRoot = Join-Path $runtimeRoot 'interlude'
        LogsRoot = Join-Path $runtimeRoot 'logs'
        PidsRoot = Join-Path $runtimeRoot 'pids'
    }
}

function Add-L2JavaEnvironment {
    if (-not $env:JAVA_HOME) {
        $env:JAVA_HOME = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'Machine')
    }
    if ($env:JAVA_HOME) {
        $env:Path = (@((Join-Path $env:JAVA_HOME 'bin'), $env:Path) -join ';')
    }
    $java = Get-Command 'java' -ErrorAction SilentlyContinue
    if (-not $java) {
        throw 'Java was not found.'
    }
    return $java.Source
}

function Get-L2ManagedProcess {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('login', 'game')]
        [string]$Service
    )

    $context = Get-L2RuntimeContext
    $pidPath = Join-Path $context.PidsRoot "$Service.pid"
    if (-not (Test-Path -LiteralPath $pidPath -PathType Leaf)) {
        return $null
    }

    $processId = [int](Get-Content -LiteralPath $pidPath -Raw)
    $process = Get-CimInstance Win32_Process -Filter "ProcessId = $processId" -ErrorAction SilentlyContinue
    if (-not $process) {
        Remove-Item -LiteralPath $pidPath -Force
        return $null
    }

    $expectedJar = if ($Service -eq 'login') { 'LoginServer.jar' } else { 'GameServer.jar' }
    if (($process.Name -notmatch '^java(w)?\.exe$') -or ($process.CommandLine -notlike "*$expectedJar*")) {
        throw "PID file for $Service points to an unmanaged process: $processId"
    }

    return $process
}

function Start-L2ManagedProcess {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('login', 'game')]
        [string]$Service
    )

    if (Get-L2ManagedProcess -Service $Service) {
        throw "$Service server is already running."
    }

    $context = Get-L2RuntimeContext
    $javaPath = Add-L2JavaEnvironment
    $workingDirectory = Join-Path $context.DistributionRoot $Service
    $javaConfigPath = Join-Path $workingDirectory 'java.cfg'
    $jarName = if ($Service -eq 'login') { 'LoginServer.jar' } else { 'GameServer.jar' }
    $jarPath = Join-Path $context.DistributionRoot "libs\$jarName"
    foreach ($requiredPath in @($workingDirectory, $javaConfigPath, $jarPath)) {
        if (-not (Test-Path -LiteralPath $requiredPath)) {
            throw "Runtime path was not found: $requiredPath"
        }
    }

    foreach ($directory in @($context.LogsRoot, $context.PidsRoot)) {
        if (-not (Test-Path -LiteralPath $directory)) {
            $null = New-Item -ItemType Directory -Path $directory
        }
    }

    $javaParameters = (Get-Content -LiteralPath $javaConfigPath -Raw).Trim() -split '\s+'
    $arguments = @($javaParameters + '-jar' + "../libs/$jarName")
    $stdoutPath = Join-Path $context.LogsRoot "$Service.stdout.log"
    $stderrPath = Join-Path $context.LogsRoot "$Service.stderr.log"

    $process = Start-Process `
        -FilePath $javaPath `
        -ArgumentList $arguments `
        -WorkingDirectory $workingDirectory `
        -RedirectStandardOutput $stdoutPath `
        -RedirectStandardError $stderrPath `
        -PassThru
    $process.Id | Set-Content -LiteralPath (Join-Path $context.PidsRoot "$Service.pid") -Encoding ASCII

    return $process
}

function Wait-L2LocalPort {
    param(
        [Parameter(Mandatory)]
        [int]$Port,

        [Parameter(Mandatory)]
        [ValidateSet('login', 'game')]
        [string]$Service,

        [int]$TimeoutSeconds = 180
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $process = Get-L2ManagedProcess -Service $Service
        if (-not $process) {
            throw "$Service server exited before opening port $Port."
        }

        $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue)
        if ($listeners.Count -gt 0) {
            $unsafe = @($listeners | Where-Object LocalAddress -ne '127.0.0.1')
            if ($unsafe.Count -gt 0) {
                throw "$Service server opened port $Port outside localhost."
            }
            return
        }

        Start-Sleep -Milliseconds 500
    }

    throw "Timed out waiting for $Service server on 127.0.0.1:$Port."
}

function Stop-L2ManagedProcess {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('login', 'game')]
        [string]$Service
    )

    $context = Get-L2RuntimeContext
    $process = Get-L2ManagedProcess -Service $Service
    if (-not $process) {
        Write-Host "$Service server is already stopped."
        return
    }

    Stop-Process -Id $process.ProcessId -Force
    $deadline = (Get-Date).AddSeconds(20)
    do {
        Start-Sleep -Milliseconds 250
        $stillRunning = Get-Process -Id $process.ProcessId -ErrorAction SilentlyContinue
    } while ($stillRunning -and ((Get-Date) -lt $deadline))

    if ($stillRunning) {
        throw "Unable to stop $Service server process $($process.ProcessId)."
    }

    $pidPath = Join-Path $context.PidsRoot "$Service.pid"
    if (Test-Path -LiteralPath $pidPath) {
        Remove-Item -LiteralPath $pidPath -Force
    }
    Write-Host "$Service server stopped."
}
