# ADR-009 — Tier T5 (DK + armas Fênix)

- **Status:** Aceita (implementada na Sprint 18)
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

TT (T3), Draconic (T4), craft por fragmentos e a quest ponte Q900 já estão no
runtime. O próximo degrau da ADR-006 é o **T5 avançado**: armor estilo DK +
armas Fênix — acima do Draconic, abaixo de Dynarty (T6).

Esta ADR fixa o envelope de design; a implementação em overlays está na Sprint 18.

## Decisão

### Nome e papel

- **Armor:** Ashen DK (linhas Heavy / Light / Robe).
- **Armas:** Ashen Phoenix (abreviado **Fênix**).
- **Nome de produto do tier:** Ashen DK / Phoenix (T5).
- **Papel:** terceiro degrau custom; power creep controlado após Draconic.
- **Posição:** superior ao Draconic (T4), inferior a Dynarty (T6).

### Famílias

Mesma estrutura dos tiers custom anteriores:

| Linha | Peças |
|---|---|
| Ashen DK Heavy | Helmet, Breastplate, Gaiters, Gauntlets, Boots, Shield |
| Ashen DK Light | Helmet, Onepiece (ou chest+legs), Gloves, Boots |
| Ashen DK Robe | Circlet, Robe, Gloves, Shoes |

Armas Phoenix: mesmas 9 famílias (sword, 2H, dual, dagger, bow, blunt, pole, fist, staff).

### Poder relativo

| Comparado a | Política |
|---|---|
| Ashen Draconic (T4) | claramente superior (~12–18% ofensivo/defensivo sobre Draconic) |
| Dynarty (T6) | claramente inferior |
| Enchant | ainda teto retail; **sem +30** no T5 |

### Obtenção

| Fonte | Papel |
|---|---|
| Raid “Ashen Dark Warden” (nome final depois) | armor DK principal |
| Mini-boss “Phoenix Ember” (nome final depois) | armas Fênix |
| Craft com fragmentos DK + fragmentos Draconic | sink econômico |
| Quest de transição (pós-Draconic) | token / 1 recipe — não set completo |
| Evento | no máximo token auxiliar |

Tempo alvo após set Draconic completo: **8–16 semanas** dedicadas.

### IDs reservados

Faixa de itens **9600–9699** (evita colisão com scrolls de craft **9500–9545** e
reserva **9550–9599** para tokens/recipes futuros):

| Subfaixa | Uso |
|---|---|
| 9600–9629 | DK Heavy |
| 9630–9659 | DK Light |
| 9660–9689 | DK Robe |
| 9690–9699 | Armas Phoenix e tokens (ex.: fragmento `9699`) |

NPCs sugeridos: `93200` (raid armor), `93201` (warden / phoenix de armas).  
Sets sugeridos: `106–108` (após Draconic `103–105`).

### Implementação (Sprint 18)

1. Overlays em `infrastructure/customization/` (não no submódulo).
2. Stats ~15% acima do Draconic.
3. Spawns/raids + relatório `docs/setup/DK_PHOENIX_IMPLEMENTATION_REPORT.md`.
4. Craft com fragmentos DK e client-patch ainda pendentes.

## Alternativas rejeitadas

- **Reusar IDs retail Imperial/Draconic/Majestic** com stats alterados: corrompe baseline.
- **Pular T5 e ir a Dynarty:** quebra a escada e a retenção de médio prazo.
- **Misturar +30 no T5:** +30 fica exclusivo do T6 (ADR futura).
- **Usar faixa 9500–9599 para itens T5:** conflita com scrolls de craft Sprint 15.

## Consequências

- T6 (Dynarty / +30) continua só na visão até ADR própria.
- Teto de conteúdo custom implementado sobe para **DK/Phoenix (T5)**; Draconic permanece o degrau anterior.
- Playtest T3–T4 (raids, craft, Q900) segue válido; T5 adiciona raids/itens próprios.
