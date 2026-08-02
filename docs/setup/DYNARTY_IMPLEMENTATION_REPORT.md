# Relatório — implementação Ashen Dynarty (Sprint 22)

**Status:** implementado em overlays; enchant +30 Dynarty-only via merge; load
validado (`ItemData` highest `9799`, `ArmorSetData` 63 sets, `NpcData` 6528,
`EnchantItemData` 32 scrolls, max weapon/armor enchant **30**).

## Entregue

| Artefato | Caminho |
|---|---|
| Itens 9700–9799 | `.../stats/items/09700-09799.xml` |
| Scrolls 9570/9571 | `.../stats/items/09570-09579.xml` |
| Sets 109–111 | `.../armorsets/ashen_dynarty.xml` |
| Raids 93300/93301 | `.../npcs/93300-93399.xml` |
| Spawns | `.../spawns/Ashen/AshenDynarty.xml` |
| Enchant merge | `EnchantItemData.ashen.fragment.xml`, `EnchantItemGroups.ashen.fragment.xml` |
| Apply / verify | `apply-local-dynarty-content.ps1`, `verify-local-dynarty-content.ps1` |

## Enchant +30 (política ADR-010)

- Scrolls **9570** (arma) e **9571** (armor) listam só IDs Dynarty e
  `maxEnchant="30"`.
- Listar os IDs **bloqueia** scrolls S retail (959/960/…) em peças Dynarty
  (`EnchantScroll.isValid`).
- Retail S permanece `maxEnchant="16"`.
- Grupos `DYNARTY_*` sobem o teto de `OverEnchantProtection` para **30**
  (limitação Mobius: o max é global). Enchant normal de retail continua
  limitado pelos scrolls.

## Teste GM

```text
//create_item 9701 1
//create_item 9790 1
//create_item 9570 20
//create_item 9571 20
//spawn 93300
```

Enchantar só com 9570/9571 nas peças Dynarty.

## Limites

- Sem client-patch de nomes/ícones.
- Craft/quest Dynarty ainda não criados.
- Sem venda de +30.
