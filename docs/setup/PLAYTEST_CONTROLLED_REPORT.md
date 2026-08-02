# Relatório do playtest controlado

## Resultado

**Aprovado pelo proprietário na Sprint 8.**

O playtest local com o cliente limpo e o personagem `NEIDE157` avançou além do
primeiro login: houve progresso de nível, mudança de posição, logout limpo e
persistência coerente no MariaDB, sem customizações de rates ou itens.

## Evidências

| Item | Antes (Sprint 7) | Depois (Sprint 8) |
|---|---|---|
| Personagem | `NEIDE157` nível 1 | `NEIDE157` nível 2 |
| Estado | online observado | `online=0` após logout |
| Posição | `-72022 / 257614 / -3141` | `-84516 / 241220 / -3755` |
| Itens | 6 | 6 |
| Conta | `ashen_test` @ `127.0.0.1` | inalterada e local |
| Tempo online acumulado | 79 s | 587 s |

Checklist de mundo e snapshot final foram reexecutados após a validação do
proprietário. Listeners permaneceram apenas em loopback.

## Escopo coberto

- sessão contínua no mundo local;
- progresso básico (nível 1 → 2);
- logout limpo com `online=0`;
- persistência de posição e inventário;
- ausência de conexão Java externa.

## Fora de escopo

- alteração de rates, drops, skills ou classes;
- geodata/pathfinding;
- múltiplas contas simultâneas;
- customizações de datapack.
