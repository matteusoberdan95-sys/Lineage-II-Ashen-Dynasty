# Relatório — craft Ashen TT/Draconic/DK (Sprint 15 + 19)

**Status:** implementado em overlays; merge de `Recipes.xml` no apply; load
Sprint 15 validado (917 recipes); Sprint 19 espera **940** recipes (871 + 69).

## Entregue

| Artefato | Caminho |
|---|---|
| Scrolls 9500–9568 | `infrastructure/customization/game/data/stats/items/09500-09599.xml` |
| Fragmento recipes | `.../Recipes.ashen.fragment.xml` (listIds 872–940) |
| Apply / verify | `apply-local-ashen-craft.ps1`, `verify-local-ashen-craft.ps1` |
| Gerador | `_generate_ashen_craft_overlays.py` |
| Mapa de IDs | `docs/design/ASHEN_CRAFT_IDS.md` |

Raids TT/Draconic/DK-Phoenix dropam scrolls de recipe (chance baixa por grupo).

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

Recipes são `type="common"`, `craftLevel="1"`, `successRate="100"` (acessível no
playtest local sem dwarf).

## Como aplicar

```powershell
# Game parado — reaplicar raids (drops de recipe) + craft
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-tt-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-draconic-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-dk-phoenix-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-ashen-craft.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\verify-local-ashen-craft.ps1
```

O apply de craft faz merge **idempotente** em `Recipes.xml` (marcadores
`BEGIN/END ASHEN DYNASTY RECIPES`). Não altera o submódulo.

## Teste GM

```text
//create_item 9547 1
//create_item 9699 30
//create_item 9499 15
//create_item 1462 100
```

Usar o scroll (aprende recipe) e craftar via Create Item / recipe book.

## Limites

- Sem client-patch: nome do scroll pode aparecer genérico.
- Quest de transição pós-Draconic → DK ainda não criada.
- Não há recipe para fragmentos (só consumo).
