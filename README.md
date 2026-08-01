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

As Sprints 0 a 6 estão concluídas localmente. L2JMobius
`L2J_Mobius_CT_0_Interlude` foi aceito na ADR-001 e fixado no commit
`e4d1d8336ed28fc0916e7caad3ca752d06169eac`, após auditoria estática inicial.

O repositório separa source, runtime, banco, infraestrutura, cliente e componentes
.NET futuros conforme a ADR-002. A source permanece limpa; um patch local reproduzível
corrige exclusivamente o bind 7777 conforme a ADR-003. MariaDB 11.4.3, Login Server e
Game Server rodam somente em localhost. O cliente limpo em `D:\L2-ASHEN-DYNASTY`
autenticou, criou o personagem `NEIDE157` e persistiu no banco. Nenhuma conexão Java
externa foi observada. O cliente permanece fora do Git.

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
- [notas de licença](LICENSE-NOTES.md).

## Próximo bloqueio

A próxima sprint deverá validar relogin, logout limpo, inventário inicial e um
checklist mínimo de mundo local, ainda sem customizações de rates ou itens.

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
