# ADR-005 — Rates locais (level rápido, gear lento)

- **Status:** Aceita
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

A visão do Ashen Dynasty pede progressão de nível relativamente rápida e progressão
de equipamento longa. A baseline estava em rates retail (`1`). Com Login/Game,
cliente, playtest e identidade estáveis, é seguro aplicar a primeira política de
rates — ainda sem Dynarty, Draconic custom, DK ou Fênix.

## Decisão

Aplicar no runtime local, via script versionado (sem alterar o submódulo):

| Chave | Valor | Motivo |
|---|---|---|
| `RateXp` / `RateSp` | `500` | level rápido |
| `RatePartyXp` / `RatePartySp` | `500` | party coerente |
| `RateQuestRewardXP` / `RateQuestRewardSP` | `500` | quests acompanham o level |
| `RateQuestRewardAdena` | `5` | adena de quest moderada |
| `RateQuestReward` e multiplicadores de item de quest | `1` | não acelerar gear via quest |
| Drop/Spoil/Raid chance e amount | `1` | gear continua retail-like |
| Adena (`57`) amount multiplier | `10` | liquidez mínima sem flood |
| Joias de raid na lista por ID | `1` | endgame lento |

Regras:

1. Rates ficam só no runtime; source upstream limpa.
2. Recriar runtime exige reaplicar `apply-local-rates.ps1`.
3. Dynarty / custom items / enchant +30 continuam proibidos até ADR própria.
4. Sem rede externa.

## Alternativas rejeitadas

- **500x em drop/spoil:** contradiz “equipamento difícil”.
- **XP baixo + drop alto:** invertiria a visão.
- **Editar Rates.ini no submódulo:** perde baseline auditável.

## Consequências

- Farm de nível fica rápido; farm de set permanece longo.
- Economia de adena sobe levemente (10x amount no ID 57).
- Validação manual de XP no cliente é necessária após restart do Game Server.

## Validação

- `verify-local-rates.ps1` confirma os valores no `Rates.ini` do runtime.
- Submódulo limpo.
- Game Server reiniciado após apply.
- Playtest manual: ganho de XP acelerado e drop de equipamento sem sensação de 500x.
