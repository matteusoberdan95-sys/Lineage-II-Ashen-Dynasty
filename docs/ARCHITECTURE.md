# Arquitetura

## Escopo atual

O Ashen Dynasty usa uma base L2JMobius Interlude existente. Login Server e Game
Server permanecem em Java; não haverá reimplementação da engine em C#.

```text
Cliente Interlude (proprietário, fora do Git)
                  |
                  | TCP 127.0.0.1:2106
                  v
          Login Server Java
                  |
                  | TCP 127.0.0.1:9014
                  v
           Game Server Java
                  |
                  | TCP 127.0.0.1:3306
                  v
              MariaDB

Cliente Interlude -- TCP 127.0.0.1:7777 --> Game Server
```

A porta 9014 é usada internamente entre Game Server e Login Server na source
escolhida. Ela não substitui a porta 2106 usada pelo cliente.

## Componentes

### Source upstream

```text
server/source/l2jmobius-upstream/
└── L2J_Mobius_CT_0_Interlude/
    ├── build.xml
    ├── java/
    └── dist/
        ├── login/
        ├── game/
        ├── db_installer/
        └── libs/
```

O repositório upstream é um submódulo Git fixado por commit. Seu módulo Interlude já
contém Login Server, Game Server e datapack. Criar cópias paralelas desses módulos na
raiz aumentaria o risco de divergência e mistura, portanto isso foi rejeitado.

### Runtime local

`server/runtime/` contém artefatos gerados, configurações locais, logs, HexID e
arquivos necessários à execução. Todo o diretório é ignorado pelo Git.

O runtime nunca será usado como source of truth. Ele poderá ser apagado e recriado a
partir do commit fixado, build e templates versionados.

O build local aplica, em cópia descartável, o patch que faz a porta 7777 respeitar
`GameserverHostname`. A source upstream permanece limpa. Patches desse tipo seguem a
ADR-003 e não autorizam mudanças de gameplay.

Customizações de produto (nome do servidor, notícia e futuros overlays de datapack)
ficam em `infrastructure/customization/` e são aplicadas ao runtime conforme a
ADR-004. Rates, itens e economia continuam bloqueados até ADR específica.

### Banco

`database/` contém scripts controlados pelo Ashen Dynasty para:

- bootstrap local;
- verificações;
- migrations futuras;
- seeds explicitamente aprovados;
- documentação de backup.

Os 100 scripts SQL originais permanecem dentro do submódulo e são importados sem
cópia ou alteração. Login e Game Server compartilham o schema
`l2jmobiusinterlude`; a separação em `l2_login` e `l2_game` não foi inventada.

MariaDB 11.4.3 escuta somente em `127.0.0.1:3306`. O usuário
`l2server@127.0.0.1` possui privilégios somente nesse schema.

### Infraestrutura

`infrastructure/` contém scripts PowerShell, templates de configuração local,
overlays de produto e, no futuro, Compose auxiliar e monitoramento. Nenhum script
alterará firewall, roteador ou produção.

### Cliente

`client-patch/` conterá somente documentação e, futuramente, arquivos cuja
distribuição seja comprovadamente permitida. O cliente completo, executáveis e assets
proprietários permanecem fora do repositório.

## Arquitetura futura

Somente nas sprints correspondentes:

```text
ASP.NET Core API
├── contas e autenticação compatível
├── ranking e status
└── serviços administrativos controlados

ASP.NET Core Portal
ASP.NET Core Admin
C#/.NET Launcher e Updater
Dashboard econômico
Serviços de auditoria
```

Esses componentes não acessarão o banco sem uma camada controlada e não exporão
comandos GM diretamente.

## Limites de confiança

```text
[Cliente proprietário]
          |
          v
[Protocolos Login/Game] ---- entrada não confiável
          |
          v
[Servidores Java] ---------- código e datapack executáveis
          |
          v
[MariaDB local] ------------ dados persistentes e credenciais
```

- Entrada de rede deve ser tratada como não confiável.
- Scripts Java do datapack são código executável.
- Configurações locais e segredos não pertencem ao Git.
- Acesso administrativo deve ser auditável.
- Atualizações upstream exigem nova revisão de diff e segurança.

## Decisões relacionadas

- `docs/adr/ADR-001-SERVER-SOURCE.md`
- `docs/adr/ADR-002-REPOSITORY-STRUCTURE.md`
- `docs/adr/ADR-003-LOCAL-SECURITY-PATCHES.md`
- `docs/adr/ADR-004-PRODUCT-CUSTOMIZATION.md`
- `docs/adr/ADR-005-LOCAL-RATES.md`
- `docs/adr/ADR-006-GEAR-PROGRESSION.md`
- `docs/adr/ADR-007-TT-TIER.md`
- `docs/adr/ADR-008-DRACONIC-TIER.md`
- `docs/adr/ADR-009-DK-PHOENIX-TIER.md`
- `docs/design/DK_PHOENIX_TIER.md`
- `docs/design/GEAR_PROGRESSION.md`
- `docs/design/TT_TIER.md`
- `docs/design/DRACONIC_TIER.md`
- `docs/design/DRACONIC_ITEM_IDS.md`
- `docs/setup/DRACONIC_IMPLEMENTATION_REPORT.md`
- `docs/setup/ASHEN_CRAFT_IMPLEMENTATION_REPORT.md`
- `docs/design/ASHEN_CRAFT_IDS.md`
- `docs/setup/ASHEN_QUEST_IMPLEMENTATION_REPORT.md`
- `docs/security/SOURCE_AUDIT.md`
