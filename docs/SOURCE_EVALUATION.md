# Avaliação de bases Java Interlude

Avaliação documental e auditoria estática inicial realizadas em 1 de agosto de 2026
para o Lineage II: Ashen Dynasty. O módulo L2JMobius Interlude foi clonado por checkout
esparso do repositório oficial e não foi executado.

Commit avaliado: `e4d1d8336ed28fc0916e7caad3ca752d06169eac`.

## Objetivo

Selecionar uma única base Java de Lineage 2 Interlude que permita:

- preservar o comportamento original da crônica;
- compilar Login Server e Game Server de forma reproduzível;
- manter source e datapack auditáveis;
- usar MariaDB local sem credenciais privilegiadas;
- servir como baseline limpa antes de qualquer customização.

## Fontes consultadas

### L2JMobius

- Site oficial: `https://www.l2jmobius.org/`
- Repositório oficial:
  `https://gitlab.com/MobiusDevelopment/L2J_Mobius`
- Módulo Interlude:
  `https://gitlab.com/MobiusDevelopment/L2J_Mobius/-/tree/master/L2J_Mobius_CT_0_Interlude`
- Wiki de instalação: `https://l2jmobius.org/wiki/install.php`
- Wiki de arquitetura: `https://l2jmobius.org/wiki/architecture.php`
- API pública do GitLab para metadados do projeto.

### aCis

- Fórum oficial: `https://acis.i-live.eu/`
- Descrição oficial:
  `https://acis.i-live.eu/index.php?topic=10422.0`
- Política de sources públicas:
  `https://acis.i-live.eu/index.php?topic=1974.0`
- Open Hub, usado apenas como fonte secundária:
  `https://openhub.net/p/acis_project`

Mirrors de terceiros encontrados em buscas não foram tratados como origens
confiáveis.

## Resumo comparativo

| Critério | L2JMobius CT_0 Interlude | aCis |
|---|---|---|
| Crônica | Interlude/C6 em módulo explícito | Interlude/C6 como foco exclusivo |
| Origem pública verificável | Sim, GitLab oficial público | Fórum oficial público; acesso ao código mais recente é restrito |
| Modelo de acesso | Repositório público | Freemium; branch pública é apresentada como demo da privada |
| Atividade | Atividade pública em 2026 | Fórum e projeto ativos; branch pública possui defasagem deliberada |
| Java | JDK 25 segundo documentação oficial atual | Deve ser confirmado na revisão obtida; referências antigas variam |
| Build | Apache Ant, `build.xml` | Apache Ant nas revisões conhecidas; precisa ser confirmado |
| Estrutura | Um módulo autocontido por crônica, com `java/` e `dist/` | Core/datapack organizados para Interlude; layout exato depende da revisão |
| Banco | Documentação oficial usa MySQL; compatibilidade MariaDB deve ser testada | Historicamente MySQL/MariaDB; deve ser verificada na source real |
| Licença | Transição para MIT, com código legado ainda sob GPLv3 por arquivo | Termos próprios/freemium mencionados oficialmente; licença exata precisa ser lida na distribuição |
| Adequação a iniciante | Melhor documentação e origem pública | Exige mais autonomia; branch pública não possui suporte |
| Auditoria independente | Possível após clone público fixado | Limitada sem acesso legítimo à revisão escolhida |

## Candidata A — L2JMobius CT_0 Interlude

### Origem e histórico

O repositório público oficial é
`MobiusDevelopment/L2J_Mobius` no GitLab. A API pública reportou:

- visibilidade pública;
- branch padrão `master`;
- atividade em 1 de agosto de 2026;
- 71 forks e 25 estrelas no momento da consulta;
- descrição indicando atualizações regulares.

O módulo `L2J_Mobius_CT_0_Interlude` aparece explicitamente na raiz do repositório e
recebe atualizações próprias. O repositório atual no GitLab foi criado em junho de
2025; isso parece refletir migração ou republicação e não prova, isoladamente, todo o
histórico anterior do projeto.

### Crônica e datapack

O módulo é identificado oficialmente como Interlude. A documentação de arquitetura
descreve cada crônica como um servidor autocontido:

```text
L2J_Mobius_CT_0_Interlude/
├── build.xml
├── java/
└── dist/
    ├── login/
    ├── game/
    ├── db_installer/
    └── libs/
```

Em termos conceituais:

- `java/` contém Login Server, Game Server e ferramentas;
- `dist/` contém configurações, SQL, dados, scripts, HTML/XML e layout de runtime;
- o datapack não deve ser separado artificialmente antes da inspeção local.

O layout foi confirmado no checkout local. O módulo contém 18.982 arquivos
rastreados, incluindo source Java, scripts Java do datapack, XML/HTML, configurações,
100 scripts SQL e oito JARs.

### Java e build

O `build.xml` local confirma:

- JDK 25;
- Apache Ant 1.8.2 ou superior;
- execução do `build.xml`;
- encoding UTF-8;
- source e target Java 25;
- artefato de distribuição compactado na pasta de build.

JDK 25 substitui a recomendação provisória de JDK 21 para esta candidata.

Não será adotado Eclipse como requisito obrigatório. Primeiro será verificado se o
build Ant funciona de forma reproduzível no PowerShell.

### Banco de dados

A instalação oficial demonstra MySQL por meio do XAMPP. Isso não obriga o projeto a
usar XAMPP. A compatibilidade com MariaDB será confirmada por:

- driver JDBC incluído;
- URLs JDBC reais;
- tipos e sintaxe dos scripts SQL;
- comportamento do instalador de banco;
- charset e collation exigidos.

O checkout usa MySQL Connector/J 9.5.0 e URLs `jdbc:mysql`. Os scripts SQL não
contêm procedures, triggers, events, criação de usuários ou grants, mas contêm
operações `DROP TABLE`. A compatibilidade prática com MariaDB continua **não
comprovada** e será testada sem alterar a source.

### Licença

O README oficial declara transição para MIT. O `build.xml` e muitos arquivos declaram
GPLv3 ou posterior; outros arquivos usam MIT. Não foi encontrado arquivo autônomo
`LICENSE`, `COPYING` ou `NOTICE`. Portanto:

- não se pode classificar o módulo inteiro como MIT sem ler os cabeçalhos;
- obrigações GPL podem continuar aplicáveis a partes derivadas;
- o commit importado deverá ser preservado com licenças e avisos;
- mudanças futuras precisarão manter rastreabilidade por arquivo.

### Vantagens

- origem pública e verificável;
- módulo Interlude explícito;
- atividade pública recente;
- documentação de instalação e arquitetura;
- build conhecido com Ant;
- código e runtime organizados por crônica;
- auditoria e fixação por commit possíveis;
- menor barreira de acesso para um iniciante.

### Desvantagens

- monorepo muito maior que o módulo necessário;
- JDK 25 ainda não está instalado;
- documentação oficial sugere scripts VBS e XAMPP que não serão executados sem
  auditoria;
- licenciamento misto exige análise por arquivo;
- ritmo de mudança na branch `master` exige fixar um commit;
- atividade não equivale a ausência de regressões.

### Riscos

- dependências JAR devem ser inventariadas e ter checksums registrados;
- scripts de banco e execução precisam de inspeção antes do uso;
- clonar sem fixar commit prejudicaria a reprodutibilidade;
- importar outras crônicas aumentaria superfície de auditoria e risco de mistura;
- possíveis chamadas externas ou administrativas ainda não foram auditadas localmente.

### Dificuldade para iniciante

**Média.** A documentação e a origem pública ajudam, mas Java 25, Ant, configuração
JDBC, registro do Game Server e separação entre source e runtime exigem orientação.

## Candidata B — aCis

### Origem e histórico

O fórum oficial define aCis como um emulador Java baseado no trabalho L2J, iniciado
por volta de 2010 e focado exclusivamente em Interlude. O projeto enfatiza:

- comportamento retail-like;
- remoção de customs desnecessários;
- reescritas e correções de sistemas centrais;
- XMLização e revisão de scripts/datapack.

Esse foco técnico é muito compatível com a intenção de uma baseline limpa.

### Modelo de acesso

O projeto adota modelo freemium. A página oficial informa que:

- acesso às sources mais recentes é concedido por contribuição financeira ou de
  código, conforme regras próprias;
- a branch pública funciona como demonstração da branch privada;
- bugs da versão pública podem já estar corrigidos apenas na privada;
- não há suporte para a branch pública;
- seu uso em servidor real não é recomendado pelo próprio autor sem experiência para
  manutenção.

Em 11 de outubro de 2024, a revisão pública foi movida para a 409. Em 31 de julho de
2026, o fórum anunciou novo formato de geodata/pathnodes para a revisão 412 ou
superior, mas isso não demonstra que a revisão privada completa esteja publicamente
disponível.

### Java, build e banco

Revisões conhecidas usam Java e Apache Ant, mas a versão exata do JDK deve ser lida no
`build.xml` da revisão legitimamente obtida. Não será adotada informação de mirrors
como requisito oficial.

O mesmo vale para driver JDBC, MariaDB, schema e organização do datapack: são
historicamente compatíveis com o ecossistema L2J, porém precisam ser confirmados na
distribuição real.

### Licença

O fórum registra que aCis usa termos próprios e distribui um `license.htm`. O texto
integral dessa licença não foi obtido durante esta avaliação. Como o projeto deriva de
trabalho L2J, há risco de sobreposição entre termos próprios e obrigações de código
legado.

Nenhuma revisão aCis deve ser incorporada antes de:

1. obter a source por canal oficial;
2. ler os termos aplicáveis à revisão;
3. identificar cabeçalhos e componentes de terceiros;
4. confirmar permissão para modificar, versionar e eventualmente distribuir.

### Vantagens

- foco exclusivo em Interlude;
- forte orientação a comportamento retail-like;
- remoção deliberada de customs;
- longa história no ecossistema;
- estrutura potencialmente mais enxuta que um monorepo multichronicle.

### Desvantagens

- latest source não é publicamente auditável sem cumprir regras de acesso;
- branch pública é deliberadamente defasada e sem suporte;
- termos de licença ainda não foram lidos;
- mirrors de terceiros não têm cadeia de custódia confiável;
- curva de manutenção maior para um proprietário iniciante.

### Riscos

- origem adulterada ao usar mirror;
- revisão pública com bugs já corrigidos apenas na privada;
- licença incompatível com o fluxo Git planejado;
- dependência operacional do acesso freemium;
- impossibilidade de concluir auditoria sem obter a revisão oficial.

### Dificuldade para iniciante

**Alta na branch pública**, pois o próprio autor não oferece suporte e espera
capacidade de corrigir problemas. A revisão privada pode reduzir problemas técnicos,
mas adiciona barreiras de acesso e licenciamento.

## Outras sources e mirrors

Foram encontrados forks e repacks em GitHub com nomes aCis, L2J Interlude e
customizações. Eles foram rejeitados nesta etapa porque apresentavam um ou mais dos
seguintes sinais:

- poucos contribuidores e histórico curto;
- licença declarada sem prova de compatibilidade com o upstream;
- links para clientes, JDKs ou geodata em serviços de arquivos;
- customs incorporados;
- origem upstream pouco clara;
- ausência de processo verificável de release.

Uma licença MIT adicionada por um fork não pode relicenciar validamente código GPL ou
código sujeito a termos de terceiros.

## Recomendação

Recomenda-se **L2JMobius `L2J_Mobius_CT_0_Interlude`**, condicionada a:

1. clonar somente do GitLab oficial;
2. registrar o commit exato;
3. limitar o checkout ao necessário para o módulo Interlude, se tecnicamente seguro;
4. concluir auditoria estática de source, scripts, SQL e JARs;
5. revisar licenças por arquivo;
6. confirmar JDK 25 no `build.xml`;
7. comprovar MariaDB antes de alterar qualquer SQL;
8. não executar VBS, JAR ou script antes da auditoria.

A auditoria estática inicial foi concluída e está documentada em
[`docs/security/SOURCE_AUDIT.md`](security/SOURCE_AUDIT.md). Ela não encontrou
backdoor confirmado, executável nativo ou integração com webhook/Telegram. Encontrou,
porém, configurações padrão inseguras que bloqueiam a execução até serem isoladas:

- bind em `0.0.0.0`;
- JDBC com usuário `root` e senha vazia;
- instalador e scripts SQL destrutivos;
- consulta automática de IP externo quando não existe `ipconfig.xml`.

### Justificativa

Para o proprietário iniciante, origem pública, atividade recente, documentação e
possibilidade de auditoria reproduzível superam o foco mais enxuto do aCis. A branch
pública aCis é desaconselhada pelo próprio mantenedor para uso sem experiência, e a
branch privada não pode ser avaliada de forma independente neste momento.

## Estado da decisão

**L2JMobius Interlude foi aceito pelo proprietário em 1 de agosto de 2026.**

A source está apta a avançar para preparação do repositório e, depois, build. Isso não
autoriza executar Login Server, Game Server ou instalador de banco. Os achados altos
operacionais devem ser isolados nas configurações locais antes da primeira execução.
