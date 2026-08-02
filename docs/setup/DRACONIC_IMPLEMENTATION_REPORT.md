# Relatório — implementação Ashen Draconic (Sprint 14)

**Status:** implementado em overlays locais; load validado no Game Server
(`ItemData` highest id `9499`, `ArmorSetData` 57 sets, sem erro em `ashen_draconic.xml`).

## Entregue

| Artefato | Caminho versionado |
|---|---|
| Itens 9400–9499 | `infrastructure/customization/game/data/stats/items/09400-09499.xml` |
| Sets 103–105 | `.../armorsets/ashen_draconic.xml` |
| Raids 93100–93101 | `.../npcs/93100-93199.xml` |
| Spawns | `.../spawns/Ashen/AshenDraconic.xml` |
| Apply / verify | `apply-local-draconic-content.ps1`, `verify-local-draconic-content.ps1` |
| Gerador | `infrastructure/scripts/_generate_draconic_overlays.py` |

## Conteúdo

- Heavy / Light / Robe Draconic (~+15% vs Ashen TT)
- 9 armas Draconic + fragmento `9499`
- **Elder of Ashen Scale** (93100) — armor + fragments (+ chance fragmento TT), respawn 36h
- **Ashen Scale Warden** (93101) — armas + fragments, respawn 18h
- Spawn próximo a Death Pass (`68000/131500` e `69500/129800`)

## Como aplicar / testar

```powershell
# Game parado
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\apply-local-draconic-content.ps1

# Após subir o Game
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-draconic-content.ps1
```

No GM:

```text
//create_item 9401 1
//create_item 9490 1
//spawn 93100
```

## Limites

- Sem client-patch: nomes/ícones podem aparecer genéricos no Interlude.
- Craft com fragmentos Draconic + TT: ver Sprint 15 (`ASHEN_CRAFT_IMPLEMENTATION_REPORT.md`).
- Quest de transição TT→Draconic: ver Sprint 16 (`ASHEN_QUEST_IMPLEMENTATION_REPORT.md`).

## Economia

Peças em chance baixa por grupo; fragmento Draconic sempre dropa; Elder também
pode dropar fragmento TT (`9399`) como ponte de sink.
