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

- client-patch completo de ícones/nomes custom;
- implementação Dynarty / enchant `+30` no datapack (design ADR-010);
- TVT customizado;
- loja, pagamentos ou doações;
- itens ou skills customizados além do autorizado por ADR.

Já autorizados e entregues em sprints: rates ADR-005; overlays TT/Draconic/
DK-Phoenix; craft por fragmentos; quests ponte Q900/Q901. O desenho do T6 está
na ADR-010.

## Próximo passo

1. atual: design T6 (ADR-010) publicado;
2. playtest T3–T5 continua válido;
3. próxima: implementação Dynarty (+30 limitado), client-patch ou QoL.
