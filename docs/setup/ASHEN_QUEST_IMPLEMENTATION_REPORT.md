# Relatório — quests Ashen de transição (Sprint 16 + 20)

**Status:** implementadas em overlays (`data/scripts/quests/`, fora de `custom/`);
load validado (`ScriptManager` **344** quests — +1 vs 343 da Sprint 16).

## Entregue

| Artefato | Caminho |
|---|---|
| Quest Q900 | `.../scripts/quests/Q00900_AshenScaleOfTransition/` |
| Quest Q901 | `.../scripts/quests/Q00901_AshenEmberOfAscent/` |
| NPC 93002 | `.../stats/npcs/93000-93099.xml` (Ashen Chronicler) |
| Spawn | `.../spawns/Ashen/AshenQuest.xml` |
| Apply / verify | `apply-local-ashen-quest.ps1`, `verify-local-ashen-quest.ps1` |

## Fluxos

### Q900 — Ashen Scale of Transition (TT → Draconic)

1. Chronicler, level ≥ 76.
2. Entregar **15×** fragmento TT (`9399`).
3. Recompensa: **12×** fragmento Draconic (`9499`) + recipe peitoral Draconic (`9524`).

### Q901 — Ashen Ember of Ascent (Draconic → DK)

1. Chronicler, level ≥ 78 **e** Q900 concluída.
2. Entregar **20×** fragmento Draconic (`9499`).
3. Recompensa: **12×** fragmento DK (`9699`) + recipe peitoral DK (`9547`).

Ambas são únicas e **não** entregam set completo (ADR-007/008/009).

## Loader

Cada quest tem `main()` próprio. **Não** altera `QuestMasterHandler` nem o
submódulo. `custom/` continua excluído em `Scripts.xml`.

## Como aplicar / testar

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\apply-local-ashen-quest.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-ashen-quest.ps1
```

GM (Q901, após marcar Q900 concluída no personagem de teste):

```text
//teleport 71000 129200 -3720
//create_item 9499 20
```

## Limites

- Sem client-patch: nomes de quest dependem de `setCustom(true)`.
- Uma recipe de peitoral por ponte; demais recipes vêm de raid/craft.
