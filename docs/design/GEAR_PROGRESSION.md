# Progressão de equipamento — Ashen Dynasty

Contrato resumido da [ADR-006](../adr/ADR-006-GEAR-PROGRESSION.md).

> Level rápido (500x). Gear lento. Dynarty só no topo, depois de meses.

## Escada

```text
T0 Fundação retail     NG → D → C
T1 Mid retail          B → A
T2 Alto retail         S Interlude
T3 Entrada endgame     Ashen TT             ← implementado (overlays)
T4 Posterior           Draconic custom      ← implementado (overlays)
T5 Avançado            DK + armas Fênix     ← implementado (overlays)
T6 Máximo              Dynarty (+30)        ← muitos meses
```

## O que o jogador faz agora

1. Sobe de nível com XP 500x.
2. Farma / crafta sets **retail Interlude** até S-grade (T2).
3. Farma raids Ashen TT ou crafta com fragmentos — ver
   [`TT_TIER.md`](TT_TIER.md) e [`ASHEN_CRAFT_IDS.md`](ASHEN_CRAFT_IDS.md).
4. Ponte Q900 (Chronicler) e farms Draconic — ver
   [`DRACONIC_TIER.md`](DRACONIC_TIER.md) e
   [`../setup/ASHEN_QUEST_IMPLEMENTATION_REPORT.md`](../setup/ASHEN_QUEST_IMPLEMENTATION_REPORT.md).
5. Farma raids DK/Phoenix (Dark Warden / Phoenix Ember) — ver
   [`DK_PHOENIX_TIER.md`](DK_PHOENIX_TIER.md) e [`DK_PHOENIX_ITEM_IDS.md`](DK_PHOENIX_ITEM_IDS.md).

## Exemplos retail úteis no playtest GM

| Fase | Exemplos (IDs Interlude) |
|---|---|
| Early | Long Sword `2`, Squire's Sword `2369` |
| Mid arma | Great Sword `78`, Sword of Damascus `79` |
| Mid armor | Avadon Breastplate `2376`, Avadon Gaiters `2379` |
| Alto | Tallum Blade `80`, Dark Legion's Edge `2500`, Majestic/Nightmare (IDs S do datapack) |

## Fora de escopo até implementação / ADR própria

- Dynarty, enchant +30  
- Quest T5 (craft T5: Sprint 19)  
- loja de set / doação de gear
