[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $dataRoot = Join-Path $context.DistributionRoot 'game\data'
    $approvedMultisells = @(
        '9301001.xml','9301002.xml','9301003.xml','9301004.xml','9301005.xml',
        '9301101.xml','9301102.xml','9301103.xml','9301104.xml','9301105.xml',
        '9301201.xml','9301202.xml','9301203.xml','9301204.xml','9301205.xml',
        '9301301.xml','9301302.xml','9301303.xml','9301304.xml','9301305.xml',
        '9301401.xml','9301402.xml','9301403.xml','9301404.xml','9301405.xml',
        '9301501.xml','9301502.xml','9301503.xml','9301504.xml','9301505.xml',
        '9302101.xml','9302102.xml','9302103.xml','9302104.xml','9302105.xml','9302106.xml'
    )

    $requiredFiles = @(
        'stats\npcs\93000-93099.xml',
        'spawns\Ashen\AshenHub.xml',
        'spawns\Giran\AshenHubNPCs.xml',
        'scripts\ai\others\AshenProgressionHub\AshenProgressionHub.java',
        'scripts\ai\others\AshenProgressionHub\93010.htm',
        'scripts\ai\others\AshenProgressionHub\93011.htm',
        'scripts\ai\others\AshenProgressionHub\93012.htm',
        'scripts\ai\others\AshenProgressionHub\93013.htm',
        'scripts\ai\others\AshenProgressionHub\93014.htm'
    )

    foreach ($relative in $requiredFiles) {
        $path = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required progression file missing: $path"
        }
    }

    $multisellDir = Join-Path $dataRoot 'multisell\ashen_progression'
    if (-not (Test-Path -LiteralPath $multisellDir -PathType Container)) {
        throw "Multisell folder missing: $multisellDir"
    }

    $multisells = @(Get-ChildItem -LiteralPath $multisellDir -Filter '*.xml' -File)
    if ($multisells.Count -ne $approvedMultisells.Count) {
        throw "Expected $($approvedMultisells.Count) progression multisells, found $($multisells.Count)."
    }

    $missingInFolder = @($approvedMultisells | Where-Object { -not (Test-Path -LiteralPath (Join-Path $multisellDir $_) -PathType Leaf) })
    if ($missingInFolder.Count -gt 0) {
        throw "Approved progression multisells missing in folder: $($missingInFolder -join ', ')"
    }

    $unexpectedInFolder = @($multisells | Where-Object { $approvedMultisells -notcontains $_.Name })
    if ($unexpectedInFolder.Count -gt 0) {
        throw "Unexpected progression multisells found: $($unexpectedInFolder.Name -join ', ')"
    }

    $rootLoaded = @(Get-ChildItem -LiteralPath (Join-Path $dataRoot 'multisell') -Filter '930*.xml' -File)
    if ($rootLoaded.Count -ne $approvedMultisells.Count) {
        throw "Expected $($approvedMultisells.Count) mirrored root multisells (930*.xml), found $($rootLoaded.Count)."
    }

    $missingInRoot = @($approvedMultisells | Where-Object { -not (Test-Path -LiteralPath (Join-Path (Join-Path $dataRoot 'multisell') $_) -PathType Leaf) })
    if ($missingInRoot.Count -gt 0) {
        throw "Approved root multisells missing: $($missingInRoot -join ', ')"
    }

    $unexpectedInRoot = @($rootLoaded | Where-Object { $approvedMultisells -notcontains $_.Name })
    if ($unexpectedInRoot.Count -gt 0) {
        throw "Unexpected root multisells found: $($unexpectedInRoot.Name -join ', ')"
    }

    Write-Host "Ashen progression verification passed ($($multisells.Count) multisells, $($rootLoaded.Count) root mirrors)."
    exit 0
}
catch {
    Write-Error "Ashen progression verification failed: $($_.Exception.Message)"
    exit 1
}
