# Visão do jogo

## Propósito

Lineage II: Ashen Dynasty será um servidor Interlude experimental para estudo,
prototipagem e testes fechados. A prioridade inicial é uma baseline limpa, estável,
segura e persistente.

> **Forje seu legado. Conquiste sua dinastia.**

## Direção futura

- Progressão de nível relativamente rápida.
- Progressão de equipamentos longa e significativa.
- Economia persistente e observável.
- Evolução possível sem depender de eventos.
- TVT opcional como atividade complementar.
- Escada de gear oficial na ADR-006: retail T0–T2 → TT → Draconic custom →
  DK/Fênix → Dynarty (`+30`, muitos meses).
- Retenção baseada em progressão, comunidade e estabilidade.

Consulte [`docs/design/GEAR_PROGRESSION.md`](design/GEAR_PROGRESSION.md).

## Princípios econômicos

- Equipamento forte deve exigir tempo e participação no mundo.
- O jogador deve conseguir progredir por caminhos regulares.
- Eventos não devem ser a única fonte de evolução.
- Itens máximos não serão vendidos diretamente nesta etapa.
- O servidor começa sem foco em lucro.
- Alterações econômicas futuras devem ser mensuráveis e reversíveis.

## Fora do escopo atual

Esta visão não autoriza implementar ainda:

- client-patch completo de ícones TT / quest de transição TT;
- Draconic custom no datapack (design ADR-008);
- DK;
- armas Fênix;
- Dynarty;
- enchant `+30`;
- TVT customizado;
- loja, pagamentos ou doações;
- itens ou skills customizados além do autorizado por ADR.

Rates locais de XP/SP foram autorizados pela ADR-005 (500x level / drop retail-like).
O desenho do TT está na ADR-007. Os demais sistemas acima exigem desenho,
balanceamento, testes, auditoria econômica e ADR própria.

## Prioridade atual

1. baseline + rates + escada de gear (até Sprint 12);
2. Ashen TT implementado em overlays (Sprint 13);
3. design Draconic T4 (ADR-008 / Sprint 13);
4. próxima: implementação Draconic, client-patch TT, ou QoL.
