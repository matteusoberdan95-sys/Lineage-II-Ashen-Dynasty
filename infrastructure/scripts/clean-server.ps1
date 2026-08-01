[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $runtimeRoot = Join-Path $repositoryRoot 'server\runtime'
    $buildOutput = Join-Path $runtimeRoot 'build'

    if (-not (Test-Path -LiteralPath $buildOutput)) {
        Write-Host "Build output is already clean: $buildOutput"
        exit 0
    }

    $resolvedRuntime = (Resolve-Path -LiteralPath $runtimeRoot).Path
    $resolvedBuild = (Resolve-Path -LiteralPath $buildOutput).Path
    $expectedPrefix = $resolvedRuntime.TrimEnd('\') + '\'
    $runtimeItem = Get-Item -LiteralPath $resolvedRuntime -Force
    $buildItem = Get-Item -LiteralPath $resolvedBuild -Force

    if (($runtimeItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -or
        ($buildItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
        throw 'Refusing to remove build output through a symbolic link or junction.'
    }

    if (-not $resolvedBuild.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove a path outside server/runtime: $resolvedBuild"
    }

    if ($PSCmdlet.ShouldProcess($resolvedBuild, 'Remove generated server build output')) {
        Remove-Item -LiteralPath $resolvedBuild -Recurse -Force
        Write-Host "Removed generated build output: $resolvedBuild"
    }

    exit 0
}
catch {
    Write-Error "Clean failed: $($_.Exception.Message)"
    exit 1
}
