# Relatório — craft Ashen TT/Draconic (Sprint 15)

**Status:** implementado em overlays; merge de `Recipes.xml` no apply; load a
validar (`RecipeData` esperado: retail 871 + 46 Ashen = **917**).

## Entregue

| Artefato | Caminho |
|---|---|
| Scrolls 9500–9545 | `infrastructure/customization/game/data/stats/items/09500-09599.xml` |
| Fragmento recipes | `.../Recipes.ashen.fragment.xml` (listIds 872–917) |
| Apply / verify | `apply-local-ashen-craft.ps1`, `verify-local-ashen-craft.ps1` |
| Gerador | `_generate_ashen_craft_overlays.py` |
| Mapa de IDs | `docs/design/ASHEN_CRAFT_IDS.md` |

Raids TT/Draconic passam a dropar scrolls de recipe (chance baixa por grupo).

## Economia (sink)

| Produção | Fragmentos | Crystal S (`1462`) |
|---|---|---|
| TT peça menor | 8× `9399` | 20 |
| TT peitoral/pernas/robe | 15× `9399` | 40 |
| TT arma | 25× `9399` | 50 |
| Draconic peça menor | 10× `9499` + 5× `9399` | 30 |
| Draconic peitoral/etc. | 20× `9499` + 10× `9399` | 60 |
| Draconic arma | 30× `9499` + 15× `9399` | 80 |

Recipes são `type="common"`, `craftLevel="1"`, `successRate="100"` (acessível no
playtest local sem dwarf).

## Como aplicar

```powershell
# Game parado — reaplicar raids (drops de recipe) + craft
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-tt-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-draconic-content.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\apply-local-ashen-craft.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\infrastructure\scripts\verify-local-ashen-craft.ps1
```

O apply de craft faz merge **idempotente** em `Recipes.xml` (marcadores
`BEGIN/END ASHEN DYNASTY RECIPES`). Não altera o submódulo.

## Teste GM

```text
//create_item 9501 1
//create_item 9399 20
//create_item 1462 50
```

Usar o scroll (aprende recipe) e craftar via Create Item / recipe book.

## Limites

- Sem client-patch: nome do scroll pode aparecer genérico.
- Quest de transição ainda não criada.
- Não há recipe para fragmentos (só consumo).
