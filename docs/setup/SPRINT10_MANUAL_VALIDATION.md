# Sprint 10 — validação manual do proprietário

**Data:** 2026-08-01  
**Estado automático:** passou (`verify-local-regression.ps1`)  
**Estado manual:** **aprovado pelo proprietário**

## Automático (agente)

- [x] `verify-local-regression.ps1` passou
- [x] Rates ADR-005 aplicados e Game reiniciado
- [x] Commit/push da Sprint 10

## Manual — regressão playtest (`NEIDE157`)

- [x] Lista mostra **Ashen Dynasty**
- [x] Notícia de entrada aparece
- [x] Relogin ok
- [x] XP de mob claramente acelerado (500x)
- [x] Drop de equipamento **não** parece 500x
- [x] Morte/retorno sem soft-lock
- [x] NPC abre diálogo
- [x] Logout limpo

## Manual — GM (`ASHENADM`)

- [x] `//admin` abre
- [x] `//create_coin adena 100000` ok
- [x] `//create_item 78 1` (Great Sword) ok e equipa
- [x] `//create_item 2376 1` (Avadon Breastplate) ok
- [x] Teleporte ok (`//show_moves` / painel admin)
- [x] Ferramentas GM ok (Alt+G limitado no cliente Interlude; chat admin suficiente)

## Decisão de rates

Proprietário manteve **500x XP/SP** como adequado à visão (level rápido, gear lento).
Drop retail-like permanece.

## Resultado final

- [x] **Aprovado** pelo proprietário
- [ ] Reprovado — motivo:
