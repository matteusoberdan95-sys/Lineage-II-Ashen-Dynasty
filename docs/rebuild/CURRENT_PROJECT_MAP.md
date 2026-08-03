# CURRENT PROJECT MAP

Data da coleta: 2026-08-03
Escopo: mapeamento da base ativa para rebuild controlado

## Estrutura macro identificada
- server/: ENCONTRADO
- database/: ENCONTRADO
- infrastructure/: ENCONTRADO
- docs/: ENCONTRADO
- client-patch/: ENCONTRADO
- launcher/: ENCONTRADO

## Source, runtime e datapack
- Source upstream (submódulo): server/source/l2jmobius-upstream
- Runtime local preparado: server/runtime/interlude
- Dist de execução:
  - Login: server/runtime/interlude/login
  - Game: server/runtime/interlude/game
  - DB installer: server/runtime/interlude/db_installer
- Logs de execução: server/runtime/logs
- PIDs gerenciados: server/runtime/pids

## Configurações críticas
- Login DB config: server/runtime/interlude/login/config/Database.ini
- Game DB config: server/runtime/interlude/game/config/Database.ini
- Login net/server: server/runtime/interlude/login/config/Server.ini
- Game net/server: server/runtime/interlude/game/config/Server.ini
- Game scripts load: server/runtime/interlude/game/config/Scripts.xml
- Game IP config: server/runtime/interlude/game/config/ipconfig.xml

## Banco de dados
- Engine local: MariaDB 11.4.3
- Listener: 127.0.0.1:3306
- Schema em uso (JDBC runtime): l2jmobiusinterlude
- Scripts de banco:
  - database/scripts/create-local-databases.sql
  - database/scripts/create-local-user.sql
  - database/scripts/import-base-schema.ps1
  - database/scripts/verify-local-database.ps1

## Scripts operacionais principais
- Preparar runtime: infrastructure/scripts/prepare-local-runtime.ps1
- Iniciar DB: infrastructure/scripts/start-database.ps1
- Iniciar Login: infrastructure/scripts/start-login-server.ps1
- Iniciar Game: infrastructure/scripts/start-game-server.ps1
- Verificar stack: infrastructure/scripts/status-local-stack.ps1
- Parar stack: infrastructure/scripts/stop-local-stack.ps1

## Cliente e patch
- Cliente alvo local: D:\L2-ASHEN-DYNASTY (referência em script)
- Configuração cliente: infrastructure/scripts/configure-local-client.ps1
- Patch/documentação cliente: client-patch/

## Conta e mecanismo administrativo
- Evidência documental de conta admin local: docs/setup/LOCAL_ADMIN_SETUP.md
- Evidência de comandos admin: server/runtime/interlude/game/config/AdminCommands.xml
- Access levels: server/runtime/interlude/game/config/AccessLevels.xml

## Customizações detectadas na cadeia de preparo
O script de preparo aplica customizações locais automaticamente:
- apply-local-product-customization.ps1
- apply-local-rates.ps1
- apply-local-tt-content.ps1
- apply-local-draconic-content.ps1
- apply-local-dk-phoenix-content.ps1
- apply-local-dynarty-content.ps1
- apply-local-ashen-craft.ps1
- apply-local-ashen-quest.ps1
- apply-local-ashen-progression.ps1

Status atual para rebuild controlado: CONFLITANTE (baseline misturada com conteúdo custom)
