# Login Server e Game Server local

## Estado validado

Login Server e Game Server foram executados com JDK 25 e MariaDB 11.4.3:

| Serviço | Listener |
|---|---|
| MariaDB | `127.0.0.1:3306` |
| Login para clientes | `127.0.0.1:2106` |
| Login para Game Server | `127.0.0.1:9014` |
| Game Server | `127.0.0.1:7777` |

O Game Server está registrado como ID 1, `AutoCreateAccounts` e novos registros estão
desabilitados, e nenhum processo Java apresentou conexão externa.

## Por que existe um build local

O upstream ignora `GameserverHostname` ao abrir a porta 7777. O patch
`server/patches/0001-bind-gameserver-to-configured-host.patch` corrige somente esse
bind em uma cópia descartável. O submódulo permanece intacto. Consulte a ADR-003.

## Preparação a partir de um clone configurado

Na raiz do repositório:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\build-local-server.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\prepare-local-runtime.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\initialize-game-server-registration.ps1
```

O último comando aceita somente o seed público upstream esperado ou uma tabela vazia.
Ele recusa registros desconhecidos. O runtime:

- remove o HexID público distribuído upstream;
- obtém a senha `l2server` da credencial DPAPI;
- grava a senha somente em arquivos ignorados;
- cria `ipconfig.xml` estritamente local;
- desabilita GUI, criação automática de contas, backup upstream e conteúdo custom;
- habilita criptografia de pacotes;
- permite novos Game Servers apenas durante o primeiro registro.

## Primeira inicialização e registro

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\start-login-server.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\start-game-server.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\lock-game-server-registration.ps1
```

O Game Server gera um HexID aleatório, persiste-o em
`server/runtime/interlude/game/config/hexid.txt` e registra o ID 1 no banco. O HexID
é segredo operacional local e nunca deve ser copiado para documentação ou Git.

Pare e reinicie os dois servidores para aplicar o bloqueio:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\stop-local-stack.ps1" -Confirm:$false'

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\start-login-server.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\start-game-server.ps1
```

## Verificação

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-servers.ps1
```

A verificação exige listeners locais, processos corretos, 100 tabelas, registro ID 1,
carregamento de skills, itens, NPCs e spawns, ausência de erro crítico e ausência de
conexões Java externas.

Para consultar apenas estado:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\status-local-stack.ps1 `
  -RequireRunning
```

## Parada e reset

`stop-local-stack.ps1` encerra primeiro Game e depois Login. No Windows, essa parada é
forçada; use-a somente no ambiente local e sem jogadores conectados.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\stop-local-stack.ps1" -Confirm:$false'
```

O reset abaixo apaga configuração efetiva, logs e PID, mas preserva o build. Ele
recusa execução quando existe um HexID registrado:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\reset-local-runtime.ps1" -Confirm:$false'
```

Depois do registro, preserve o runtime. Remover identidade e linha do banco exige um
fluxo controlado ainda não automatizado.

## Logs

- processo: `server/runtime/logs/`;
- logger do Login: `server/runtime/interlude/login/log/`;
- logger do Game: `server/runtime/interlude/game/log/`.

Todos ficam fora do Git.
