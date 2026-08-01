# ADR-002 — Estrutura do repositório

- **Status:** Aceita
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

A estrutura inicial genérica previa diretórios próprios para Login Server, Game Server
e datapack. O L2JMobius Interlude escolhido já integra esses componentes no mesmo
módulo Ant. Recriá-los na raiz produziria duas fontes de verdade.

Também é necessário impedir que builds, runtime, credenciais, backups e cliente
proprietário se misturem à source auditada.

## Drivers

- preservar uma baseline upstream verificável;
- não misturar bases ou crônicas;
- não duplicar módulos;
- separar source, runtime e configuração;
- manter segredos e assets proprietários fora do Git;
- permitir componentes .NET futuros sem acoplá-los à engine Java;
- tornar build e ambiente reproduzíveis;
- manter o repositório compreensível para um iniciante em Java e L2J.

## Opções consideradas

### Copiar o módulo Interlude para a raiz

Rejeitada. Perderia o vínculo simples com o upstream, facilitaria alterações
acidentais e exigiria manter histórico e licença manualmente.

### Criar wrappers separados para Login, Game e datapack

Rejeitada nesta etapa. O build Ant e a distribuição upstream já possuem essa
separação operacional. Wrappers vazios não acrescentariam isolamento real.

### Submódulo upstream fixado e áreas externas por responsabilidade

Aceita. A source fica identificável por commit e todo conteúdo controlado pelo Ashen
Dynasty permanece fora dela.

## Decisão

Usar os seguintes limites:

```text
.
├── server/
│   ├── source/l2jmobius-upstream/  # submódulo somente leitura nesta etapa
│   └── runtime/                    # gerado localmente e ignorado
├── database/                       # SQL e operação controlados pelo projeto
├── client-patch/                   # documentação; assets proprietários proibidos
├── web/                            # componentes .NET futuros
├── launcher/                       # launcher .NET futuro
├── infrastructure/                 # scripts, Docker e templates locais
└── docs/                           # decisões, setup, segurança e arquitetura
```

Os subdiretórios serão materializados na sprint que os utilizar. Não serão
adicionados diretórios vazios apenas para reproduzir uma árvore idealizada.

Login Server, Game Server e datapack permanecem em:

```text
server/source/l2jmobius-upstream/L2J_Mobius_CT_0_Interlude
```

## Regras

1. O submódulo não receberá customização antes de uma ADR de estratégia de fork ou
   patches.
2. Outras crônicas do monorepo não fornecerão código, scripts ou dados.
3. `server/runtime/` será integralmente ignorado.
4. Configurações versionadas serão templates sem segredos.
5. Configurações efetivas serão locais e ignoradas.
6. SQL do projeto ficará fora do submódulo; SQL upstream será referenciado, não
   duplicado.
7. Cliente, executáveis e assets proprietários não serão versionados.
8. `web/` e `launcher/` só receberão projetos quando sua implementação for autorizada.

## Consequências positivas

- baseline limpa e comparável ao upstream;
- estrutura menor e sem duplicações;
- atualização upstream revisável por commit;
- runtime descartável;
- separação clara para ferramentas .NET futuras.

## Consequências negativas

- customizações Java exigirão decidir entre fork e patches;
- um clone completo precisa inicializar o submódulo;
- parte do monorepo upstream permanece acessível mesmo usando somente Interlude;
- scripts próprios precisarão localizar explicitamente o módulo fixado.

## Validação

- `git submodule status` deve mostrar o commit aprovado.
- `git -C server/source/l2jmobius-upstream status --short` deve permanecer vazio.
- `git check-ignore` deve confirmar exclusão de runtime, `.env`, logs e cliente.
- A raiz não deve conter cópias de Login Server, Game Server ou datapack.

## Relações

- ADR-001 define a source adotada.
- Uma ADR futura definirá como customizações Java serão mantidas.
- A política de runtime e configuração será detalhada antes da primeira execução.
