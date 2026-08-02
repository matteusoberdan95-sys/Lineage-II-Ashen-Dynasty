# ADR-010 — Tier T6 (Dynarty + enchant +30)

- **Status:** Aceita (design)
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

A escada T3–T5 (TT → Draconic → DK/Phoenix), craft por fragmentos e as quests
ponte Q900/Q901 já estão no runtime. O degrau final da ADR-006 é o **T6
máximo**: set **Ashen Dynarty** e a única faixa autorizada a usar enchant
**até +30**.

Esta ADR **não implementa** itens, nem altera o teto de enchant no servidor.
Só fixa o envelope de design e as restrições econômicas.

## Decisão

### Nome e papel

- **Nome:** Ashen Dynarty (abreviado **Dynarty**).
- **Papel:** teto de gear custom do projeto; retenção de longo prazo.
- **Posição:** acima de DK/Phoenix (T5); sem tier custom acima nesta visão.

### Famílias

Mesma estrutura dos tiers custom anteriores:

| Linha | Peças |
|---|---|
| Dynarty Heavy | Helmet, Breastplate, Gaiters, Gauntlets, Boots, Shield |
| Dynarty Light | Helmet, Onepiece (ou chest+legs), Gloves, Boots |
| Dynarty Robe | Circlet, Robe, Gloves, Shoes |

Armas Dynarty: mesmas 9 famílias (sword, 2H, dual, dagger, bow, blunt, pole,
fist, staff).

### Poder relativo (itens base, sem enchant)

| Comparado a | Política |
|---|---|
| Ashen DK / Phoenix (T5) | claramente superior (~12–18% ofensivo/defensivo sobre T5) |
| Enchant | **somente peças Dynarty** podem ir além do teto retail, até **+30** |
| Venda / doação | **proibida** nesta fase do projeto |

Stats exatos e curva +16…+30 ficam para a sprint de implementação + ADR/config
de enchant.

### Enchant +30 (política)

1. **Escopo:** apenas itens Ashen Dynarty (IDs desta ADR). Retail e T3–T5
   permanecem no teto Interlude retail.
2. **Não** autoriza loja de +30, scroll pago ou GM shop público.
3. Implementação futura exigirá overlay de config/datapack de enchant (e
   validação de risco) — **fora desta ADR**.
4. Scrolls/blessed/life stone custom, se necessários, usam IDs na faixa
   reservada de tokens (não misturar com peças).

### Obtenção

| Fonte | Papel |
|---|---|
| Raid “Ashen Dynasty Lord” (nome final depois) | armor Dynarty principal |
| Mini-boss “Ashen Dynasty Blade” (nome final depois) | armas Dynarty |
| Craft com fragmentos Dynarty + fragmentos DK | sink econômico pesado |
| Quest de transição (pós-DK) | token / 1 recipe — não set completo |
| Evento | no máximo token auxiliar cosmético |

Tempo alvo após set DK/Phoenix completo: **muitos meses** (ordem de grandeza
ADR-006: retenção longa; não é sprint de conteúdo imediata).

### IDs reservados

Faixa de itens **9700–9799** (após T5 `9600–9699`; scrolls de craft atuais
terminam em `9568`):

| Subfaixa | Uso |
|---|---|
| 9700–9729 | Dynarty Heavy |
| 9730–9759 | Dynarty Light |
| 9760–9789 | Dynarty Robe |
| 9790–9799 | Armas Dynarty e tokens (ex.: fragmento `9799`) |

NPCs sugeridos: `93300` (raid armor), `93301` (warden de armas).  
Sets sugeridos: `109–111` (após DK `106–108`).

Faixa `9570–9599` permanece reserva para scrolls/tokens de craft/enchant
futuros (não usar para peças Dynarty).

### Implementação futura (fora desta ADR)

1. Overlays de item/set/NPC/spawn em `infrastructure/customization/`.
2. Stats ~15% acima do DK live + planilha de enchant +16…+30.
3. Overlay/config de enchant limitado a IDs Dynarty.
4. Craft + quest ponte + relatório econômico.
5. Client-patch se necessário para ícones/nomes.

## Alternativas rejeitadas

- **+30 em qualquer S-grade / TT / Draconic / DK:** destrói a escada e a
  economia de farm T3–T5.
- **Vender Dynarty ou +30:** fora da visão desta etapa (ADR-006 regra 4).
- **Implementar T6 antes de playtest estável em T5:** risco de retune em cascata.
- **Usar IDs 9600–9699 para Dynarty:** colide com T5 já implementado.

## Consequências

- Teto de conteúdo custom **implementado** permanece **DK/Phoenix (T5)** até
  sprint de Dynarty.
- Playtest T3–T5 (raids, craft, Q900/Q901) segue válido; esta ADR não altera
  runtime.
- Qualquer mudança de `EnchantMax` / scrolls exige autorização explícita na
  sprint de implementação T6.
