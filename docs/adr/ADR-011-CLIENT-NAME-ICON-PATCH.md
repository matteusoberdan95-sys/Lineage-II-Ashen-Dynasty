# ADR-011 — Patch local de nomes/ícones Ashen (cliente Interlude)

- **Status:** Aceita (implementada na Sprint 24)
- **Data:** 2026-08-01

## Contexto

Os IDs Ashen (TT→Dynarty, recipes, scrolls, NPCs) existem no datapack do
servidor, mas o cliente Interlude limpo não conhece esses IDs. Sem entradas em
`ItemName` / `*grp` / `NpcName`, o jogador vê nomes genéricos e ícones vazios.

A visão do projeto proíbe versionar cliente, `.dat`, texturas ou assets
proprietários. O patch precisa ser **local**, reproduzível e baseado só em
metadados redistribuíveis (nossos nomes + IDs clone de retail).

## Decisão

1. Versionar apenas o manifesto CSV e scripts em
   `infrastructure/customization/ashen_client/` + `infrastructure/scripts/`.
2. Aplicar o patch só em `D:\L2-ASHEN-DYNASTY` via decode/encode Ver413
   (`open-l2encdec`, já usado no projeto).
3. Clonar visualmente peças retail S-grade (Imperial Crusader / Draconic Leather /
   Major Arcana / armas S) e renomear no `ItemName`.
4. Não versionar `.dat` gerados; backup local em `.ashen-local/`.
5. Quest names ficam com `setCustom(true)` no servidor (sem `QuestName-e.dat`
   nesta sprint).

## Arquivos tocados no cliente (local)

| Arquivo | Uso |
|---|---|
| `itemname-e.dat` | nomes Ashen |
| `armorgrp.dat` / `weapongrp.dat` / `etcitemgrp.dat` | ícone/mesh (clone) |
| `npcname-e.dat` / `npcgrp.dat` | nomes/visual NPCs Ashen |

## Consequências

- Playtest visual dos itens/NPCs Ashen fica utilizável no cliente limpo.
- Reaplicar o patch após restaurar o cliente ou atualizar o manifesto.
- Ícones/meshes ainda são retail clonados (sem arte custom nova).
