# Relatório do primeiro login com cliente

## Resultado

**Aprovado.**

Em 1 de agosto de 2026, o cliente limpo `D:\L2-ASHEN-DYNASTY` autenticou no Login
local, entrou no Game Server e persistiu um personagem no MariaDB.

## Ambiente

| Item | Valor |
|---|---|
| Cliente | `D:\L2-ASHEN-DYNASTY\system\L2.exe` |
| `ServerAddr` | `127.0.0.1` |
| Conta | `ashen_test` (criada por script, `AutoCreateAccounts=False`) |
| Login | `127.0.0.1:2106` |
| Game | `127.0.0.1:7777` |
| Elevação | `L2.exe` exige UAC/administrador |

## Evidências

| Critério | Resultado |
|---|---|
| Conta no banco | `ashen_test`, `accessLevel=0`, `lastIP=127.0.0.1`, `lastServer=1` |
| Personagem | `NEIDE157`, nível 1, `classid=0`, `online=1` |
| Posição inicial | `-71467 / 258378 / -3104` |
| Listeners | somente loopback em 2106, 9014, 7777 e 3306 |
| Conexões Java externas | nenhuma |
| Verificador | `verify-client-persistence.ps1` e `verify-local-servers.ps1` aprovados |

A senha da conta de teste não é registrada neste relatório. Ela permanece em
`secrets/local-test-account.clixml` e pode ser exibida com `show-local-account.ps1`.

## Problemas encontrados

### Cliente encerra sem elevação

`L2.exe` exige elevação. Sem UAC, o processo pode abrir e fechar sem conectar ao
Login. A abertura válida usa “Executar como administrador”.

### Pack L2Agonia rejeitado

`D:\Lineage II - Chronicle Interlude` contém `System L2Agonia` e extensões
customizadas. A baseline usou apenas `D:\L2-ASHEN-DYNASTY`.

### `l2.ini` já apontava para localhost

Após decodificar o Ver413, `ServerAddr` já era `127.0.0.1`. O script de
configuração valida esse estado e mantém backup local em `.ashen-local`.

## Fora de escopo

- balanceamento, rates ou customizações de gameplay;
- geodata/pathfinding;
- distribuição do cliente;
- testes com mais de uma conta simultânea.
