# QUARANTINE MANIFEST

Data: 2026-08-03
Escopo: l2-ashen-dynasty-rebuild

## Estrutura criada
- _disabled_custom_content/server-items
- _disabled_custom_content/client-files
- _disabled_custom_content/skills
- _disabled_custom_content/multisells
- _disabled_custom_content/npcs
- _disabled_custom_content/drops
- _disabled_custom_content/spawns
- _disabled_custom_content/teleporters
- _disabled_custom_content/shops
- _disabled_custom_content/weapons
- _disabled_custom_content/armors
- _disabled_custom_content/unknown

## Conteúdo quarentenado (resumo)
- overlays de items, npcs, armorsets, multisells, quests, spawns, html custom.
- fragments de enchant/recipes Ashen.
- multisells runtime 93xxxx que geravam erro XML.
- backup do EnchantItemGroups custom antes de restore oficial.

## Evidências
- docs/rebuild/raw/rebuild_quarantine_hashes.tsv
- docs/rebuild/raw/runtime_cleanup_actions.tsv

## Critério
- ação reversível, sem exclusão definitiva.
- itens/skills/NPCs oficiais não removidos.

## Status
- Quarentena: APROVADO
- Reversibilidade: APROVADO
