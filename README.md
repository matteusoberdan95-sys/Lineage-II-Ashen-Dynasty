# Lineage II: Ashen Dynasty

Base local experimental para estudo, prototipagem e testes fechados de um servidor
Lineage 2 Interlude.

> **Forje seu legado. Conquiste sua dinastia.**

## Identidade

| Item | Valor |
|---|---|
| Nome completo | Lineage II: Ashen Dynasty |
| Nome curto | Ashen Dynasty |
| Abreviação | L2AD |
| Slug técnico | `l2-ashen-dynasty` |

## Estado atual

As Sprints 0 a 13 estão concluídas localmente. L2JMobius
`L2J_Mobius_CT_0_Interlude` foi aceito na ADR-001 e fixado no commit
`e4d1d8336ed28fc0916e7caad3ca752d06169eac`.

O repositório separa source, runtime, banco, infraestrutura, cliente e componentes
.NET futuros conforme a ADR-002. A source permanece limpa; patch ADR-003 no bind
7777; overlays ADR-004/005; escada ADR-006; **Ashen TT** implementado via overlays
(ADR-007); **Draconic** desenhado (ADR-008, sem XML ainda). MariaDB/Login/Game só
em localhost. O cliente permanece fora do Git.

Consulte [o estado do ambiente](docs/ENVIRONMENT_STATUS.md) antes de preparar qualquer
dependência e [os pré-requisitos](docs/setup/PREREQUISITES.md) antes de instalar
ferramentas.

## Limites desta etapa

- Não desenvolver uma engine de MMORPG do zero.
- Não reescrever Login Server ou Game Server em C#.
- Não misturar código de projetos L2J diferentes.
- Não usar repacks obscuros ou pacotes customizados.
- Não executar scripts ou binários sem inspeção.
- Não versionar cliente, executáveis proprietários, segredos ou credenciais.
- Não abrir portas públicas, firewall ou roteador.
- Não alterar rates, itens, skills, classes ou enchant antes da baseline limpa.

## Arquitetura pretendida

```text
Cliente Interlude --> Login Server Java
        |
        +-----------> Game Server Java --> MariaDB
```

ASP.NET Core, portal, painel administrativo, launcher e ferramentas de auditoria
pertencem a fases futuras. Consulte
[a arquitetura detalhada](docs/ARCHITECTURE.md).

## Estrutura do repositório

A pasta atual é a raiz do repositório. Não existe uma pasta adicional
`l2-phoenix-legacy` ou `l2-ashen-dynasty` dentro dela.

```text
.
├── server/
│   ├── source/l2jmobius-upstream/  # submódulo fixado
│   └── runtime/                    # local e ignorado
├── database/                       # bootstrap e verificação do banco local
├── client-patch/                   # documentação; assets proibidos
├── web/                            # ASP.NET Core futuro
├── launcher/                       # C#/.NET futuro
├── infrastructure/                 # scripts e serviços auxiliares
├── docs/                           # arquitetura, ADR, setup e segurança
├── .editorconfig
├── .env.example
├── .gitattributes
├── .gitignore
├── CHANGELOG.md
├── LICENSE-NOTES.md
└── README.md
```

Login Server, Game Server, datapack e ferramentas permanecem dentro do módulo
Interlude upstream. Não há diretórios paralelos na raiz. Subdiretórios ainda
inexistentes serão criados somente quando sua sprint começar.

## Source recomendada

Foi avaliado:

- L2JMobius CT_0 Interlude por repositório oficial público;
- aCis pelo fórum e política de distribuição oficiais;
- mirrors apenas para identificação de risco, nunca como origem.

L2JMobius foi recomendado por origem pública verificável, atividade, documentação e
possibilidade de auditoria reproduzível. O build exige JDK 25 e Apache Ant. Consulte:

- [avaliação das bases](docs/SOURCE_EVALUATION.md);
- [auditoria da source](docs/security/SOURCE_AUDIT.md);
- [ADR-001](docs/adr/ADR-001-SERVER-SOURCE.md);
- [ADR-002](docs/adr/ADR-002-REPOSITORY-STRUCTURE.md);
- [ADR-003](docs/adr/ADR-003-LOCAL-SECURITY-PATCHES.md);
- [ADR-004](docs/adr/ADR-004-PRODUCT-CUSTOMIZATION.md);
- [ADR-005](docs/adr/ADR-005-LOCAL-RATES.md);
- [ADR-006](docs/adr/ADR-006-GEAR-PROGRESSION.md);
- [ADR-007](docs/adr/ADR-007-TT-TIER.md);
- [ADR-008](docs/adr/ADR-008-DRACONIC-TIER.md);
- [ADR-009](docs/adr/ADR-009-DK-PHOENIX-TIER.md);
- [ADR-010](docs/adr/ADR-010-DYNARTY-TIER.md);
- [notas de licença](LICENSE-NOTES.md).

## Próximo bloqueio

Implementação Dynarty (+30 limitado a T6), client-patch ou QoL/observabilidade —
ainda sem rede externa, salvo autorização.

## Segurança e propriedade intelectual

O cliente completo de Lineage 2 e seus executáveis não pertencem a este repositório.
A instalação limpa usada na Sprint 6 fica em `D:\L2-ASHEN-DYNASTY` e não é
versionada. Credenciais locais ficam em arquivos ignorados pelo Git, com templates
sem valores secretos na documentação.

## Documentação

- [visão futura do jogo](docs/GAME_VISION.md);
- [arquitetura](docs/ARCHITECTURE.md);
- [fluxo de desenvolvimento](docs/DEVELOPMENT_WORKFLOW.md);
- [avaliação da source](docs/SOURCE_EVALUATION.md);
- [estado do ambiente](docs/ENVIRONMENT_STATUS.md);
- [guia de build](docs/setup/BUILD_GUIDE.md);
- [relatório do primeiro build](docs/setup/FIRST_BUILD_REPORT.md);
- [configuração do banco](docs/setup/DATABASE_SETUP.md);
- [configuração dos servidores locais](docs/setup/LOCAL_SERVER_SETUP.md);
- [relatório da primeira execução](docs/setup/FIRST_RUN_REPORT.md);
- [configuração do cliente local](docs/setup/CLIENT_SETUP.md);
- [relatório do primeiro login](docs/setup/FIRST_CLIENT_REPORT.md);
- [checklist mínimo de mundo](docs/setup/WORLD_CHECKLIST_REPORT.md);
- [playtest controlado](docs/setup/PLAYTEST_CONTROLLED_REPORT.md);
- [primeira customização de produto](docs/setup/PRODUCT_CUSTOMIZATION_REPORT.md);
- [conta admin local](docs/setup/LOCAL_ADMIN_SETUP.md);
- [roteiro de regressão](docs/setup/REGRESSION_ROTEIRO.md);
- [checklist GM playtest](docs/setup/GM_PLAYTEST_CHECKLIST.md);
- [validação manual Sprint 10](docs/setup/SPRINT10_MANUAL_VALIDATION.md);
- [progressão de equipamento](docs/design/GEAR_PROGRESSION.md);
- [tier Ashen TT](docs/design/TT_TIER.md);
- [IDs Ashen TT](docs/design/TT_ITEM_IDS.md);
- [implementação TT](docs/setup/TT_IMPLEMENTATION_REPORT.md);
- [tier Draconic](docs/design/DRACONIC_TIER.md);
- [IDs Ashen Draconic](docs/design/DRACONIC_ITEM_IDS.md);
- [implementação Draconic](docs/setup/DRACONIC_IMPLEMENTATION_REPORT.md);
- [craft Ashen (fragmentos)](docs/setup/ASHEN_CRAFT_IMPLEMENTATION_REPORT.md);
- [IDs craft Ashen](docs/design/ASHEN_CRAFT_IDS.md);
- [quest Ashen Scale](docs/setup/ASHEN_QUEST_IMPLEMENTATION_REPORT.md);
- [tier DK/Phoenix](docs/design/DK_PHOENIX_TIER.md);
- [IDs Ashen DK/Phoenix](docs/design/DK_PHOENIX_ITEM_IDS.md);
- [implementação DK/Phoenix](docs/setup/DK_PHOENIX_IMPLEMENTATION_REPORT.md);
- [tier Dynarty](docs/design/DYNARTY_TIER.md);
- [compatibilidade do cliente](docs/CLIENT_COMPATIBILITY.md);
- [auditoria do banco](docs/security/DATABASE_AUDIT.md);
- [solução de problemas](docs/TROUBLESHOOTING.md);
- [changelog](CHANGELOG.md).

## Fluxo incremental

Cada fase deverá:

1. declarar objetivo, arquivos, comandos e riscos;
2. aplicar a menor mudança necessária;
3. executar validações proporcionais ao risco;
4. atualizar a documentação;
5. parar diante de bloqueio ou ação manual.

Ao concluir e validar cada sprint, suas alterações são commitadas com Conventional
Commits e enviadas por push normal. Tags, novas branches, downloads e instalações
continuam dependentes de autorização específica.
