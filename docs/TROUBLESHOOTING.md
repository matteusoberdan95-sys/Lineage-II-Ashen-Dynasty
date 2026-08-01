# Solução de problemas

## Login não abre 2106 ou 9014

1. Confirme MariaDB em `127.0.0.1:3306`.
2. Leia `server/runtime/logs/login.stderr.log`.
3. Execute `verify-local-database.ps1`.
4. Não copie senha para o terminal; recrie o runtime a partir da credencial DPAPI.

Se o processo permanecer em teste de conexões, confirme
`TestDatabaseConnections = False` e que `Password` possui valor na mesma linha.

## Game não abre 7777

- Confirme que Login já escuta em 9014.
- Leia `server/runtime/logs/game.stderr.log`.
- Confirme que o artefato veio de `build-local-server.ps1`.
- Execute `status-local-stack.ps1`; qualquer bind diferente de `127.0.0.1` reprova a
  baseline.

Editar somente `GameserverHostname` em um build upstream não corrige o bind.

## Registro foi rejeitado

Não apague registros ou HexID manualmente.

- Runtime novo: execute `initialize-game-server-registration.ps1` antes do primeiro
  startup.
- Runtime já registrado: confirme a presença de
  `game/config/hexid.txt` e do ID 1 no banco.
- O script recusa limpar qualquer linha que não seja o seed público upstream esperado.
- `AcceptNewGameServer=False` é o estado normal após o primeiro registro.

## Script informa timeout, mas o log mostra startup

Os logs do `ConsoleHandler` Java ficam em `*.stderr.log`. Use os scripts atuais, que
consultam os dois streams. Não mantenha uma cópia antiga de `start-game-server.ps1`.

## Porta já está em uso

```powershell
Get-NetTCPConnection -State Listen -LocalPort 2106,7777,9014 |
  Format-Table LocalAddress,LocalPort,OwningProcess
```

Não encerre PID desconhecido. Use `stop-local-stack.ps1` somente para processos
registrados pelos scripts do projeto.

## Preparação do runtime demora

O ZIP contém milhares de arquivos e o projeto está no OneDrive. A extração observada
levou cerca de três minutos. Não interrompa enquanto houver atividade; considere
pausar a sincronização local se houver bloqueio de arquivo.

## Avisos de NPC inexistente

Três avisos do script base `Core` sobre o NPC `899099` foram observados. Eles não
impediram banco, spawns, registro ou listeners. Novos avisos devem ser comparados ao
relatório da primeira execução; erros críticos não devem ser ignorados.

## Reset de runtime

O reset remove configuração efetiva e logs somente antes do registro:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\reset-local-runtime.ps1" -Confirm:$false'
```

O script recusa um runtime que já possua HexID, evitando deixar o registro do banco
órfão.
