[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $credentialPath = Join-Path $repositoryRoot 'secrets\local-admin-account.clixml'
    if (-not (Test-Path -LiteralPath $credentialPath -PathType Leaf)) {
        throw 'Local admin credential was not found. Run create-local-admin.ps1 first.'
    }

    $credential = Import-Clixml -Path $credentialPath
    $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
    )
    try {
        Write-Host "Username: $($credential.Username)"
        Write-Host "Password: $password"
        Write-Host "Character: $($credential.CharacterName)"
        Write-Host "AccessLevel: $($credential.AccessLevel) ($($credential.AccessName))"
        Write-Host 'Use only on the local client against 127.0.0.1. Never reuse outside this machine.'
    }
    finally {
        $password = $null
    }
}
catch {
    throw "Unable to show local admin account: $($_.Exception.Message)"
}
