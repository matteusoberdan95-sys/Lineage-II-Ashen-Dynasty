# Relatório do checklist mínimo de mundo

## Resultado

**Aprovado pelo proprietário na Sprint 7.**

O personagem local `NEIDE157` permaneceu coerente no MariaDB com inventário
persistido, listeners somente em loopback e scripts de verificação disponíveis
para snapshot, estado online e checklist de mundo.

## Evidências capturadas

| Item | Valor |
|---|---|
| Conta | `ashen_test`, `accessLevel=0`, `lastIP=127.0.0.1` |
| Personagem | `NEIDE157`, nível 1, `classid=0` |
| Itens persistidos | 6 |
| Posição observada | `-72022 / 257614 / -3141` |
| Listeners | `127.0.0.1:2106`, `9014`, `7777`, `3306` |
| Conexões Java externas | nenhuma |

Snapshots locais (ignorados pelo Git) foram gravados em `server/runtime/logs/`.

## Scripts adicionados

- `capture-character-snapshot.ps1`
- `wait-for-online-state.ps1`
- `verify-world-checklist.ps1`

## Escopo

Esta sprint não altera rates, skills, itens, geodata nem customizações de gameplay.
O objetivo foi confirmar operação local contínua após o primeiro login.
