# Relatório — implementação Ashen DK / Phoenix (Sprint 18)

**Status:** implementado em overlays locais; load validado no Game Server
(`ItemData` highest id `9699`, `ArmorSetData` 60 sets, `NpcData` 6526 NPCs).

## Entregue

| Artefato | Caminho versionado |
|---|---|
| Itens 9600–9699 | `infrastructure/customization/game/data/stats/items/09600-09699.xml` |
| Sets 106–108 | `.../armorsets/ashen_dk.xml` |
| Raids 93200–93201 | `.../npcs/93200-93299.xml` |
| Spawns | `.../spawns/Ashen/AshenDkPhoenix.xml` |
| Apply / verify | `apply-local-dk-phoenix-content.ps1`, `verify-local-dk-phoenix-content.ps1` |
| Gerador | `infrastructure/scripts/_generate_dk_phoenix_overlays.py` |

## Conteúdo

- Heavy / Light / Robe Ashen DK (~+15% vs Draconic)
- 9 armas Ashen Phoenix + fragmento `9699`
- **Ashen Dark Warden** (93200) — armor + fragments (+ chance fragmento Draconic), respawn 48h
- **Phoenix Ember** (93201) — armas Phoenix + fragments, respawn 24h
- Spawn próximo a Death Pass (`66500/132200` e `67500/130800`)

## Como aplicar / testar

```powershell
# Game parado
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\apply-local-dk-phoenix-content.ps1

# Após subir o Game
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-dk-phoenix-content.ps1
```

No GM:

```text
//create_item 9601 1
//create_item 9690 1
//spawn 93200
```

## Limites

- Sem client-patch: nomes/ícones podem aparecer genéricos no Interlude.
- Craft com fragmentos DK (`9699`) + Draconic fica para sprint futura.
- Quest de transição pós-Draconic ainda não criada (raid é a fonte principal).
