# Tier T3 — Ashen TT

Resumo da [ADR-007](../adr/ADR-007-TT-TIER.md).

## Em uma frase

**TT** é o primeiro set custom depois do S-grade Interlude: entrada do endgame,
antes de Draconic / DK-Fênix / Dynarty.

## Estado

| Item | Valor |
|---|---|
| Design | aceito (ADR-007) |
| No datapack runtime | **sim** (overlays Sprint 13) |
| Client-patch de ícones | pendente |

## O que compõe “estar de TT”

- Armor completa (5 peças) da linha Heavy **ou** Light **ou** Robe
- + 1 arma TT da família da classe

## De onde vem (quando existir)

1. Raid principal → armor  
2. Mini-boss → armas  
3. Quest de transição / craft com token → apoio, não set inteiro  
4. **Nunca** loja/doação como fonte principal  

## Tempo alvo

4–8 semanas de play dedicado após estar estável em S-grade.

## IDs reservados

`9300–9399` (não usar até a sprint de implementação).

## Como testar (GM)

```text
//create_item 9301 1
//create_item 9390 1
//spawn 93000
```

IDs: [`TT_ITEM_IDS.md`](TT_ITEM_IDS.md). Relatório: [`../setup/TT_IMPLEMENTATION_REPORT.md`](../setup/TT_IMPLEMENTATION_REPORT.md).
