# ADR-008 — Tier T4 (Draconic custom)

- **Status:** Aceita (implementada na Sprint 14)
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

O T3 Ashen TT foi implementado em overlays (Sprint 13). O próximo degrau da
ADR-006 é o **Draconic custom** — acima do TT, abaixo de DK/Fênix e Dynarty.

Esta ADR fixa o envelope de design; a implementação em overlays está na Sprint 14.

## Decisão

### Nome e papel

- **Nome:** Ashen Draconic (abreviado **Draconic custom**).
- **Papel:** segundo tier custom; power creep controlado após TT.
- **Posição:** T4, superior ao TT, inferior a DK/Fênix (T5).

### Famílias

Mesma estrutura do TT para consistência:

| Linha | Peças |
|---|---|
| Draconic Heavy | Helmet, Breastplate, Gaiters, Gauntlets, Boots, Shield |
| Draconic Light | Helmet, Onepiece (ou chest+legs), Gloves, Boots |
| Draconic Robe | Circlet, Robe, Gloves, Shoes |

Armas: mesmas 9 famílias do TT (sword, 2H, dual, dagger, bow, blunt, pole, fist, staff).

### Poder relativo

| Comparado a | Política |
|---|---|
| Ashen TT (T3) | claramente superior (~12–18% ofensivo/defensivo sobre TT) |
| DK / Fênix (T5) | claramente inferior |
| Enchant | ainda teto retail; sem +30 |

### Obtenção

| Fonte | Papel |
|---|---|
| Raid “Elder of Ashen Scale” (nome final depois) | armor principal |
| Mini-boss dracônico | armas |
| Craft com fragmentos Draconic + fragmentos TT | sink econômico |
| Evento | no máximo token auxiliar |

Tempo alvo após estar estável em TT: **6–12 semanas** dedicadas.

### IDs reservados

Faixa **9400–9499**:

| Subfaixa | Uso |
|---|---|
| 9400–9429 | Heavy |
| 9430–9459 | Light |
| 9460–9489 | Robe |
| 9490–9499 | Armas e tokens |

NPCs futuros sugeridos: `93100` (raid), `93101` (warden de armas).

### Implementação (Sprint 14)

1. Overlays em `infrastructure/customization/` (não no submódulo).
2. Stats ~15% acima do TT.
3. Spawns/raids + relatório `docs/setup/DRACONIC_IMPLEMENTATION_REPORT.md`.
4. Client-patch ainda pendente se necessário para ícones/nomes.

## Alternativas rejeitadas

- **Reusar IDs retail Draconic Leather (6379+)** com stats alterados: corrompe baseline.
- **Pular T4 e ir a Dynarty:** quebra a escada.
- **Implementar já sem TT estabilizado em playtest:** risco de retune em cascata.

## Consequências

- T5/T6 continuam só na visão até ADRs próprias.
- Teto de conteúdo custom implementado sobe para **Draconic (T4)**; TT permanece o degrau anterior.
