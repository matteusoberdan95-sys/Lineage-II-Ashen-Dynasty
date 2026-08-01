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

As Sprints 0 e 1 estão concluídas. L2JMobius `L2J_Mobius_CT_0_Interlude` foi
recomendado no commit `e4d1d8336ed28fc0916e7caad3ca752d06169eac`, após auditoria
estática inicial, e aceito na ADR-001. Não há banco, cliente, runtime ou customizações.
Ferramentas futuras poderão ser desenvolvidas em C#/.NET.

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
Cliente Interlude
        |
Login Server Java
        |
Game Server Java
        |
MariaDB
```

ASP.NET Core, portal, painel administrativo, launcher e ferramentas de auditoria
pertencem a fases futuras.

## Estrutura inicial proposta

A pasta atual será a raiz do repositório. Não será criada uma pasta
`l2-phoenix-legacy` adicional dentro dela, evitando uma raiz duplicada. A estrutura
abaixo é uma proposta e poderá ser ajustada ao layout consolidado da source escolhida:

```text
.
├── server/
│   ├── source/
│   ├── runtime/
│   ├── login-server/
│   ├── game-server/
│   ├── datapack/
│   └── tools/
├── database/
│   ├── schema/
│   ├── migrations/
│   ├── seeds/
│   ├── scripts/
│   └── backups/
├── client-patch/
│   ├── system/
│   ├── textures/
│   ├── animations/
│   ├── sounds/
│   └── README.md
├── web/
│   ├── api/
│   ├── portal/
│   └── admin/
├── launcher/
├── infrastructure/
│   ├── docker/
│   ├── scripts/
│   ├── configuration/
│   └── monitoring/
├── docs/
│   ├── adr/
│   ├── architecture/
│   ├── economy/
│   ├── game-design/
│   ├── setup/
│   ├── security/
│   └── testing/
├── .editorconfig
├── .env.example
├── .gitattributes
├── .gitignore
├── CHANGELOG.md
├── LICENSE-NOTES.md
└── README.md
```

Os diretórios ainda não foram materializados. Primeiro será avaliada uma única base
Java para evitar duplicação de módulos, datapacks ou sistemas de build.

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
- [notas de licença](LICENSE-NOTES.md).

## Próximo bloqueio

A Sprint 2 organizará o repositório e separará source, runtime e configurações locais.
Login Server, Game Server e instalador de banco não podem ser executados enquanto os
achados altos de configuração e banco não estiverem isolados.

## Segurança e propriedade intelectual

O cliente completo de Lineage 2 e seus executáveis não pertencem a este repositório.
Uma instalação legítima deverá ser fornecida manualmente pelo proprietário em etapa
posterior. Credenciais locais deverão ficar em arquivos ignorados pelo Git, usando
templates sem valores secretos para documentação.

## Fluxo incremental

Cada fase deverá:

1. declarar objetivo, arquivos, comandos e riscos;
2. aplicar a menor mudança necessária;
3. executar validações proporcionais ao risco;
4. atualizar a documentação;
5. parar diante de bloqueio ou ação manual.

Nenhum commit, tag, publicação remota, download ou instalação é automático.
