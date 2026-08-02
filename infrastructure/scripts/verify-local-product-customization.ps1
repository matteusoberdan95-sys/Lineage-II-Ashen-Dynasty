[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    $context = Get-L2RuntimeContext
    $distributionRoot = $context.DistributionRoot
    $serverNamePath = Join-Path $distributionRoot 'login\data\servername.xml'
    $newsPath = Join-Path $distributionRoot 'game\data\html\servnews.htm'
    $generalConfig = Join-Path $distributionRoot 'game\config\General.ini'
    $submoduleRoot = Join-Path $context.RepositoryRoot 'server\source\l2jmobius-upstream'

    foreach ($path in @($serverNamePath, $newsPath, $generalConfig)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Required runtime file was not found: $path"
        }
    }

    $serverName = [IO.File]::ReadAllText($serverNamePath)
    if ($serverName -notmatch '<server id="1" name="Ashen Dynasty" />') {
        throw 'Runtime server ID 1 is not named Ashen Dynasty.'
    }

    $news = [IO.File]::ReadAllText($newsPath)
    if ($news -notmatch 'Ashen Dynasty' -or $news -notmatch 'Forje seu legado') {
        throw 'Runtime servnews.htm does not contain the Ashen Dynasty identity text.'
    }

    $general = [IO.File]::ReadAllText($generalConfig)
    if ($general -notmatch '(?m)^[ \t]*ShowServerNews[ \t]*=[ \t]*True[ \t]*$') {
        throw 'ShowServerNews is not True in General.ini.'
    }

    Push-Location $submoduleRoot
    try {
        $submoduleStatus = (& git status --short) | Out-String
    }
    finally {
        Pop-Location
    }
    if (-not [string]::IsNullOrWhiteSpace($submoduleStatus)) {
        throw "Submodule is dirty:`n$submoduleStatus"
    }

    Write-Host 'Product customization verification passed.'
    Write-Host 'Server ID 1: Ashen Dynasty'
    Write-Host 'ShowServerNews: True'
    Write-Host 'servnews.htm: Ashen Dynasty identity present'
    Write-Host 'Submodule: clean'
    exit 0
}
catch {
    Write-Error "Product customization verification failed: $($_.Exception.Message)"
    exit 1
}
