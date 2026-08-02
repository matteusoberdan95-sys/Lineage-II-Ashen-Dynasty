# Relatório — implementação Ashen TT (Sprint 13)

**Status:** implementado em overlays locais; load validado no Game Server
(`ItemData` highest id `9399`, `ArmorSetData` 54 sets, sem erro XSD em `ashen_tt.xml`).

## Entregue

| Artefato | Caminho versionado |
|---|---|
| Itens 9300–9399 | `infrastructure/customization/game/data/stats/items/09300-09399.xml` |
| Sets 100–102 | `.../armorsets/ashen_tt.xml` |
| Raids 93000–93001 | `.../npcs/93000-93099.xml` |
| Spawns | `.../spawns/Ashen/AshenTT.xml` |
| Apply / verify | `apply-local-tt-content.ps1`, `verify-local-tt-content.ps1` |
| Gerador | `infrastructure/scripts/_generate_tt_overlays.py` |

## Conteúdo

- Heavy / Light / Robe TT (~+12% vs S-grade Imperial/Draconic/Arcana)
- 9 armas TT + fragmento `9399`
- **Guardian of Ashen TT** (93000) — armor + fragments, respawn 24h
- **Ashen Warden** (93001) — armas + fragments, respawn 12h
- Spawn próximo a Death Pass (`70000/130000` e `72000/128500`)

## Como aplicar / testar

```powershell
# Game parado
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\apply-local-tt-content.ps1

# Após subir o Game
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-tt-content.ps1
```

No GM:

```text
//create_item 9301 1
//create_item 9390 1
//spawn 93000
```

## Limites

- Sem client-patch: nomes/ícones podem aparecer genéricos no Interlude.
- `CustomItemsLoad` permanece `False` — arquivos estão no datapack principal via overlay.
- Craft com fragmento: ver Sprint 15 (`ASHEN_CRAFT_IMPLEMENTATION_REPORT.md`).
- Quest de transição ainda não criada (raid é a fonte principal).

## Economia

Drops de peça em chance baixa por grupo; fragmento sempre dropa para sink/craft futuro.
Não há loja.
