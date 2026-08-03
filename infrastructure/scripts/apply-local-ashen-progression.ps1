[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    if (Get-L2ManagedProcess -Service 'game') {
        throw 'Game Server must be stopped before applying Ashen progression hub content.'
    }

    $context = Get-L2RuntimeContext
    $overlayRoot = Join-Path $context.RepositoryRoot 'infrastructure\customization\game\data'
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

    $singleFiles = @(
        'stats\npcs\93000-93099.xml',
        'spawns\Ashen\AshenHub.xml',
        'spawns\Giran\AshenHubNPCs.xml'
    )

    foreach ($relative in $singleFiles) {
        $source = Join-Path $overlayRoot $relative
        $destination = Join-Path $dataRoot $relative
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
            throw "Ashen progression overlay missing: $source"
        }
        $destinationDirectory = Split-Path -Parent $destination
        if (-not (Test-Path -LiteralPath $destinationDirectory -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $destinationDirectory -Force
        }
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }

    $folderCopies = @(
        @{ Source = 'scripts\ai\others\AshenProgressionHub'; Destination = 'scripts\ai\others\AshenProgressionHub' }
    )

    foreach ($copy in $folderCopies) {
        $sourceDir = Join-Path $overlayRoot $copy.Source
        $destinationDir = Join-Path $dataRoot $copy.Destination
        if (-not (Test-Path -LiteralPath $sourceDir -PathType Container)) {
            throw "Ashen progression overlay folder missing: $sourceDir"
        }
        if (Test-Path -LiteralPath $destinationDir -PathType Container) {
            Remove-Item -LiteralPath $destinationDir -Recurse -Force
        }
        $null = New-Item -ItemType Directory -Path $destinationDir -Force
        Get-ChildItem -LiteralPath $sourceDir -Force | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $destinationDir -Recurse -Force
        }
    }

    $multisellSource = Join-Path $overlayRoot 'multisell\ashen_progression'
    $multisellDestination = Join-Path $dataRoot 'multisell\ashen_progression'
    if (-not (Test-Path -LiteralPath $multisellSource -PathType Container)) {
        throw "Ashen progression overlay folder missing: $multisellSource"
    }
    if (Test-Path -LiteralPath $multisellDestination -PathType Container) {
        Remove-Item -LiteralPath $multisellDestination -Recurse -Force
    }
    $null = New-Item -ItemType Directory -Path $multisellDestination -Force
    foreach ($fileName in $approvedMultisells) {
        $sourceFile = Join-Path $multisellSource $fileName
        if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
            throw "Approved multisell missing: $sourceFile"
        }
        Copy-Item -LiteralPath $sourceFile -Destination (Join-Path $multisellDestination $fileName) -Force
    }

    # MultisellData loader in this runtime reads numeric list files from the multisell root.
    # Mirror only approved files into root to avoid legacy custom lists.
    $multisellRoot = Join-Path $dataRoot 'multisell'
    Get-ChildItem -LiteralPath $multisellRoot -Filter '930*.xml' -File -ErrorAction SilentlyContinue | ForEach-Object {
        if ($approvedMultisells -notcontains $_.Name) {
            Remove-Item -LiteralPath $_.FullName -Force
        }
    }
    foreach ($fileName in $approvedMultisells) {
        Copy-Item -LiteralPath (Join-Path $multisellSource $fileName) -Destination (Join-Path $multisellRoot $fileName) -Force
    }

    Write-Host 'Ashen progression hub overlays applied (official minimum + TEST_ONLY services).'
}
catch {
    throw "Ashen progression overlay apply failed: $($_.Exception.Message)"
}
