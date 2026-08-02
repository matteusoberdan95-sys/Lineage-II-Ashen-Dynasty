# Relatório — client-patch local Ashen (Sprint 24)

**Status:** aplicado em `D:\L2-ASHEN-DYNASTY`; manifesto e scripts versionados;
verify local passou (IDs Ashen presentes nos DATs).

## Entregue

| Artefato | Caminho |
|---|---|
| Manifesto | `infrastructure/customization/ashen_client/ashen_client_manifest.csv` |
| Parser/apply Python | `lib_l2_client_dat.py`, `apply_ashen_client_patch.py` |
| Gerador | `_generate_ashen_client_manifest.py` |
| Apply / verify | `apply-local-client-patch.ps1`, `verify-local-client-patch.ps1` |
| ADR | `docs/adr/ADR-011-CLIENT-NAME-ICON-PATCH.md` |

## Escopo

- Nomes de itens Ashen (gear, fragmentos, recipes, scrolls de enchant).
- Clones de `armorgrp` / `weapongrp` / `etcitemgrp` a partir de IDs retail S.
- Nomes + `npcgrp` dos NPCs Ashen (`93002`, raids `93000–93301`).
- **Fora:** `QuestName-e.dat`, texturas novas, client-patch “completo” de arte.

## Como aplicar

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\apply-local-client-patch.ps1" -Confirm:$false'
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-client-patch.ps1
```

Reinicie o cliente (`system\L2.exe` como admin). Backup automático em
`D:\L2-ASHEN-DYNASTY\.ashen-local\client-patch-backup-*`.

## Validação executada

- Decode/encode Ver413 com `open-l2encdec` 1.3.9.
- Verify: samples `9701` nome `Ashen Dynarty Breastplate`; grp/NPC IDs presentes.
- Contagens após patch (aprox.): ItemName 9398, ArmorGrp 1066, WeaponGrp 1353,
  EtcItemGrp 6979, NpcName/NpcGrp 6528.

## Limites

- Nenhum `.dat` entra no Git.
- Visual = clone retail (não arte Ashen original).
- Quests Q900–Q902 continuam com nome via `setCustom(true)`.
