# ADR-006 — Escada de progressão de equipamento

- **Status:** Aceita
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

Rates (ADR-005) aceleram nível e mantêm drop retail-like. A visão define tiers
custom futuros (Draconic, DK/Fênix, Dynarty), mas ainda não havia uma escada
única que diga **o que o jogador veste em cada fase**, **quanto tempo alvo** e
**o que pode ser implementado agora**.

Sem isso, qualquer spawn/custom de item vira chute econômico.

## Decisão

Adotar a escada abaixo como contrato de produto. Esta ADR **não autoriza** criar
XML de item custom, alterar drops, enchant +30 nem abrir rede externa.

### Escada oficial

| Tier | Nome | Conteúdo | Tempo alvo* | Status de implementação |
|---|---|---|---|---|
| T0 | Fundação retail | NG → D → C (armas/armor Interlude) | dias | já existe no datapack |
| T1 | Mid retail | B → A (Avadon, Blue Wolf, Doom, Tallum…) | 1–3 semanas | já existe no datapack |
| T2 | Alto retail | S-grade Interlude (Majestic / Nightmare / armes S) | 3–8 semanas | já existe no datapack |
| T3 | Entrada endgame | **Ashen TT** | +1–2 meses após T2 (4–8 sem. em T3) | ADR-007 + overlays Sprint 13 |
| T4 | Posterior | **Draconic custom** | meses | ADR-008 + overlays Sprint 14 |
| T5 | Avançado | **DK + armas Fênix** | meses | futura ADR de item |
| T6 | Máximo | **Dynarty** completo, enchant até `+30` | muitos meses | futura ADR de item |

\*Tempo alvo para jogador dedicado em XP/SP 500x e drop ~1x, sem doação de gear.
Valores são ordem de grandeza para desenho, não SLA.

### Regras

1. Enquanto T3–T6 não tiverem ADR de conteúdo, o teto jogável é **T2 retail Interlude**.
2. Custom de item só entra por overlay fora do submódulo (ADR-004), com IDs novos
   reservados e relatório econômico.
3. Eventos não podem ser a única fonte de um tier.
4. Itens máximos (T6) não serão vendidos diretamente nesta fase do projeto.
5. Enchant retail permanece até ADR de enchant (+30 só no T6, quando autorizado).
6. Loja/NPC buffer/teleport QoL de playtest, se feitos, não avançam tier de gear.

### Caminhos de obtenção (política)

| Fonte | Papel |
|---|---|
| Drop/spoil/raid retail | base de T0–T2 |
| Craft/recipe retail | alternativa legítima |
| Quest retail | apoio early, não atalho de endgame |
| Custom raid/quest futuros | principal para T3–T6 (ADR própria) |
| GM spawn | só teste local, nunca economia pública |

## Alternativas rejeitadas

- **Pular retail e ir direto a Dynarty:** quebra curva e onboarding.
- **Subir drop junto com XP:** invalida “gear lento”.
- **Implementar T4–T6 já:** sem números de drop/enchant/tempo, risco alto.
- **Pay-to-win de set máximo:** fora da visão desta etapa.

## Consequências

- Próximas sprints de conteúdo sabem o teto atual (T2) e a ordem T3→T6.
- Balanceamento e ADRs de item ficam fatiáveis.
- Playtest GM continua usando IDs Interlude reais para simular T0–T2.

## Validação desta sprint

- Documento da escada publicado e referenciado no README / visão.
- Nenhuma alteração de datapack de item nesta ADR.
- Submódulo intacto.
- Rates ADR-005 permanecem.

## Próximo trabalho autorizado (fora desta ADR)

1. Quest de transição TT–Draconic (craft por fragmentos: Sprint 15).
2. Design ADR do **T5 (DK/Fênix)**.
3. Client-patch ou QoL / observabilidade econômica.
