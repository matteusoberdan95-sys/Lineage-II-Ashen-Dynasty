# Progressão de equipamento — Ashen Dynasty

Contrato resumido da [ADR-006](../adr/ADR-006-GEAR-PROGRESSION.md).

> Level rápido (500x). Gear lento. Dynarty só no topo, depois de meses.

## Escada

```text
T0 Fundação retail     NG → D → C
T1 Mid retail          B → A
T2 Alto retail         S Interlude          ← teto atual jogável
T3 Entrada endgame     Ashen TT             ← design ADR-007; não no datapack
T4 Posterior           Draconic custom
T5 Avançado            DK + armas Fênix
T6 Máximo              Dynarty (+30)        ← muitos meses
```

## O que o jogador faz agora

1. Sobe de nível com XP 500x.
2. Farma / crafta sets **retail Interlude** até S-grade (T2).
3. TT/Draconic/Dynarty ainda **não** existem no datapack — ver
   [`TT_TIER.md`](TT_TIER.md).

## Exemplos retail úteis no playtest GM

| Fase | Exemplos (IDs Interlude) |
|---|---|
| Early | Long Sword `2`, Squire's Sword `2369` |
| Mid arma | Great Sword `78`, Sword of Damascus `79` |
| Mid armor | Avadon Breastplate `2376`, Avadon Gaiters `2379` |
| Alto | Tallum Blade `80`, Dark Legion's Edge `2500`, Majestic/Nightmare (IDs S do datapack) |

## Fora de escopo até implementação / ADR própria

- TT: design pronto (ADR-007), implementação pendente  
- Draconic custom, DK, Fênix, Dynarty, enchant +30  
- loja de set / doação de gear
