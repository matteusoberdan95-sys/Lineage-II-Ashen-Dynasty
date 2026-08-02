# Relatório — craft Ashen TT/Draconic/DK/Dynarty (Sprint 15 + 19 + 23)

**Status:** implementado em overlays; merge de `Recipes.xml` no apply; load
esperado `RecipeData` **963** recipes (871 retail + 92 Ashen).

## Entregue

| Artefato | Caminho |
|---|---|
| Scrolls 9500–9594 (skip 9569–9571) | `infrastructure/customization/game/data/stats/items/09500-09599.xml` |
| Fragmento recipes | `.../Recipes.ashen.fragment.xml` (listIds 872–963) |
| Apply / verify | `apply-local-ashen-craft.ps1`, `verify-local-ashen-craft.ps1` |
| Gerador | `_generate_ashen_craft_overlays.py` |
| Mapa de IDs | `docs/design/ASHEN_CRAFT_IDS.md` |

Raids TT/Draconic/DK-Phoenix/Dynarty dropam scrolls de recipe (chance baixa por grupo).
Scrolls de craft **não** ocupam `9569–9571` (gap + enchant Dynarty `9570`/`9571`).

## Economia (sink)

| Produção | Fragmentos | Crystal S (`1462`) |
|---|---|---|
| TT peça menor | 8× `9399` | 20 |
| TT peitoral/pernas/robe | 15× `9399` | 40 |
| TT arma | 25× `9399` | 50 |
| Draconic peça menor | 10× `9499` + 5× `9399` | 30 |
| Draconic peitoral/etc. | 20× `9499` + 10× `9399` | 60 |
| Draconic arma | 30× `9499` + 15× `9399` | 80 |
| DK peça menor | 12× `9699` + 6× `9499` | 40 |
| DK peitoral/etc. | 25× `9699` + 12× `9499` | 80 |
| Phoenix arma | 35× `9699` + 18× `9499` | 100 |
| Dynarty peça menor | 15× `9799` + 8× `9699` | 50 |
| Dynarty peitoral/etc. | 30× `9799` + 15× `9699` | 100 |
| Dynarty arma | 40× `9799` + 20× `9699` | 120 |

Recipes são `type="common"`, `craftLevel="1"`, `successRate="100"` (acessível no
playtest local sem dwarf).

## Como aplicar

```powershell
# Game parado — reaplicar raids (drops de recipe) + craft
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-tt-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-draconic-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-dk-phoenix-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-dynarty-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-ashen-craft.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\verify-local-ashen-craft.ps1
```

O apply de craft faz merge **idempotente** em `Recipes.xml` (marcadores
`BEGIN/END ASHEN DYNASTY RECIPES`). Não altera o submódulo.

## Teste GM

```text
//create_item 9573 1
//create_item 9799 40
//create_item 9699 20
//create_item 1462 120
```

Usar o scroll (aprende recipe) e craftar via Create Item / recipe book.

## Limites

- Sem client-patch: nome do scroll pode aparecer genérico.
- Quests de transição: ver `ASHEN_QUEST_IMPLEMENTATION_REPORT.md`.
- Não há recipe para fragmentos (só consumo).
