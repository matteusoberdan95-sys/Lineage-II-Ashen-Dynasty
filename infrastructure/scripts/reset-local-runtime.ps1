[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    foreach ($service in @('game', 'login')) {
        if (Get-L2ManagedProcess -Service $service) {
            throw "$service server is running. Stop the local stack before resetting runtime."
        }
    }

    $context = Get-L2RuntimeContext
    $hexIdPath = Join-Path $context.DistributionRoot 'game\config\hexid.txt'
    if (Test-Path -LiteralPath $hexIdPath -PathType Leaf) {
        throw 'A registered HexID exists. Refusing to orphan its database registration.'
    }

    $resolvedRuntime = (Resolve-Path -LiteralPath $context.RuntimeRoot).Path.TrimEnd('\') + '\'
    foreach ($path in @(
        $context.DistributionRoot,
        $context.LogsRoot,
        $context.PidsRoot
    )) {
        if (-not (Test-Path -LiteralPath $path)) {
            continue
        }

        $resolvedPath = (Resolve-Path -LiteralPath $path).Path
        $item = Get-Item -LiteralPath $resolvedPath -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Refusing to reset through a reparse point: $resolvedPath"
        }
        if (-not $resolvedPath.StartsWith($resolvedRuntime, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to reset a path outside server/runtime: $resolvedPath"
        }

        if ($PSCmdlet.ShouldProcess($resolvedPath, 'Delete generated local runtime data')) {
            Remove-Item -LiteralPath $resolvedPath -Recurse -Force
        }
    }

    Write-Host 'Generated local runtime data was reset. Local build artifacts were preserved.'
    exit 0
}
catch {
    Write-Error "Local runtime reset failed: $($_.Exception.Message)"
    exit 1
}
