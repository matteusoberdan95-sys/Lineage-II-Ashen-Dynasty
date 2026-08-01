[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $credentialPath = Join-Path $repositoryRoot 'secrets\local-test-account.clixml'
    if (-not (Test-Path -LiteralPath $credentialPath -PathType Leaf)) {
        throw 'Local test account credential was not found. Run create-local-account.ps1 first.'
    }

    $credential = Import-Clixml -Path $credentialPath
    $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
    )
    try {
        Write-Host "Username: $($credential.Username)"
        Write-Host "Password: $password"
        Write-Host 'Use these values only on the local client against 127.0.0.1.'
    }
    finally {
        $password = $null
    }
    exit 0
}
catch {
    Write-Error "Unable to show local account: $($_.Exception.Message)"
    exit 1
}
