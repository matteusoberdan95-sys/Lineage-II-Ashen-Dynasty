# Relatório — quest Ashen Scale of Transition (Sprint 16)

**Status:** implementada em overlays (`data/scripts/quests/`, fora de `custom/`);
load validado (`NpcData` 6524 NPCs, `ScriptManager` **343** quests — +1 vs 342).

## Entregue

| Artefato | Caminho |
|---|---|
| Quest Q900 | `infrastructure/customization/game/data/scripts/quests/Q00900_AshenScaleOfTransition/` |
| NPC 93002 | `.../stats/npcs/93000-93099.xml` (Ashen Chronicler) |
| Spawn | `.../spawns/Ashen/AshenQuest.xml` (Death Pass ~71000/129200) |
| Apply / verify | `apply-local-ashen-quest.ps1`, `verify-local-ashen-quest.ps1` |

## Fluxo

1. Falar com **Ashen Chronicler** (93002), level ≥ 76.
2. Entregar **15× Ashen TT Fragment** (`9399`).
3. Recompensa (única vez): **12× Ashen Draconic Fragment** (`9499`) +
   **Recipe: Ashen Draconic Breastplate** (`9524`).

Alinha ADR-007/008: ponte TT→Draconic, **não** entrega set completo.

## Loader

A quest tem `main()` próprio (como village_master). **Não** altera
`QuestMasterHandler` nem o submódulo. Continua excluído `custom/` em `Scripts.xml`.

## Como aplicar / testar

```powershell
# Game parado
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\apply-local-ashen-quest.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-ashen-quest.ps1
```

GM:

```text
//teleport 71000 129200 -3720
//create_item 9399 15
```

Falar com o Chronicler, aceitar, entregar fragmentos.

## Limites

- Sem client-patch: nome da quest no cliente depende de `setCustom(true)`.
- Uma única recompensa de recipe (peito); demais recipes vêm de raid/craft.
