[CmdletBinding()]
param(
    [string]$ClientRoot = 'D:\L2-ASHEN-DYNASTY'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'server-runtime-common.ps1')

try {
    & (Join-Path $PSScriptRoot 'ensure-l2encdec.ps1')
    if ($LASTEXITCODE -ne 0) {
        throw "ensure-l2encdec.ps1 failed with exit code $LASTEXITCODE"
    }

    $context = Get-L2RuntimeContext
    $repoRoot = $context.RepositoryRoot
    $toolPath = Join-Path $repoRoot 'server\runtime\tools\l2encdec\l2encdec_win.exe'
    $python = Get-Command python -ErrorAction Stop
    $manifest = Join-Path $repoRoot 'infrastructure\customization\ashen_client\ashen_client_manifest.csv'
    $systemPath = Join-Path $ClientRoot 'system'
    $verifyDir = Join-Path $ClientRoot '.ashen-local\client-patch-verify'

    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        throw "Manifest missing: $manifest"
    }
    if (-not (Test-Path -LiteralPath $verifyDir)) {
        $null = New-Item -ItemType Directory -Path $verifyDir -Force
    }

    $checks = @(
        @{ Dat = 'itemname-e.dat'; Bin = 'itemname-e.bin'; Kind = 'itemname'; SampleIds = @(9300, 9701, 9573, 9799) },
        @{ Dat = 'npcname-e.dat'; Bin = 'npcname-e.bin'; Kind = 'npcname'; SampleIds = @(93002, 93300) },
        @{ Dat = 'armorgrp.dat'; Bin = 'armorgrp.bin'; Kind = 'armorgrp'; SampleIds = @(9301, 9701) },
        @{ Dat = 'weapongrp.dat'; Bin = 'weapongrp.bin'; Kind = 'weapongrp'; SampleIds = @(9390, 9790) },
        @{ Dat = 'etcitemgrp.dat'; Bin = 'etcitemgrp.bin'; Kind = 'etcitemgrp'; SampleIds = @(9399, 9570, 9573) },
        @{ Dat = 'npcgrp.dat'; Bin = 'npcgrp.bin'; Kind = 'npcgrp'; SampleIds = @(93002, 93300) }
    )

    $lib = Join-Path $PSScriptRoot 'lib_l2_client_dat.py'
    foreach ($entry in $checks) {
        $datPath = Join-Path $systemPath $entry.Dat
        if (-not (Test-Path -LiteralPath $datPath -PathType Leaf)) {
            throw "Required client DAT missing: $datPath"
        }
        $binPath = Join-Path $verifyDir $entry.Bin
        & $toolPath -c decode -p 413 -o $binPath $datPath
        if ($LASTEXITCODE -ne 0) {
            throw "Decode failed for $($entry.Dat)"
        }

        $ids = ($entry.SampleIds -join ',')
        $code = @"
import sys
sys.path.insert(0, r'$PSScriptRoot')
from lib_l2_client_dat import PARSERS
from pathlib import Path
recs, _ = PARSERS['$($entry.Kind)'](Path(r'$binPath').read_bytes())
missing = [int(x) for x in '$ids'.split(',') if int(x) not in recs]
if missing:
    raise SystemExit('missing ids in $($entry.Kind): ' + ','.join(map(str, missing)))
print('$($entry.Kind) ok:', len(recs), 'records')
"@
        & $python.Source -c $code
        if ($LASTEXITCODE -ne 0) {
            throw "Verification failed for $($entry.Kind)"
        }
    }

    # Spot-check names
    $itemBin = Join-Path $verifyDir 'itemname-e.bin'
    $nameCode = @"
import sys
sys.path.insert(0, r'$PSScriptRoot')
from lib_l2_client_dat import parse_itemname, read_unicode
from pathlib import Path
import struct
data = Path(r'$itemBin').read_bytes()
recs, _ = parse_itemname(data)
raw = recs[9701]
# id uint + unicode name
off = 4
n = struct.unpack_from('<I', raw, off)[0]; off += 4
name = raw[off:off+n].decode('utf-16-le')
if name != 'Ashen Dynarty Breastplate':
    raise SystemExit('unexpected name for 9701: ' + name)
print('itemname sample ok:', name)
"@
    & $python.Source -c $nameCode
    if ($LASTEXITCODE -ne 0) {
        throw 'Item name spot-check failed.'
    }

    Write-Host 'Ashen client patch verification passed.'
    Write-Host 'Sample Ashen item/NPC/grp IDs present in local client DATs.'
}
catch {
    throw "Ashen client patch verification failed: $($_.Exception.Message)"
}
