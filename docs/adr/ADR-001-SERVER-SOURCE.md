# ADR-001 — Source do servidor

- **Status:** Aceita
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

O Ashen Dynasty precisa de Login Server e Game Server Java para Interlude/C6. O
proprietário está começando em Java e L2J, então origem verificável, documentação,
build reproduzível e facilidade de auditoria têm prioridade sobre quantidade de
customizações.

Não serão misturadas bases, e nenhuma engine será desenvolvida do zero.

## Drivers da decisão

- compatibilidade real com Interlude;
- source disponível por origem oficial;
- atividade e histórico verificáveis;
- licença compreensível;
- build reproduzível;
- datapack organizado;
- possibilidade de auditoria independente;
- compatibilidade testável com MariaDB;
- curva de aprendizado adequada;
- ausência de customs como critério de escolha.

## Opções consideradas

### L2JMobius CT_0 Interlude

Repositório oficial público e ativo, módulo Interlude explícito, documentação de
arquitetura e build Ant. A documentação atual indica JDK 25.

Riscos principais:

- monorepo com várias crônicas;
- licenciamento misto MIT/GPLv3;
- configurações upstream inseguras para execução local sem isolamento;
- necessidade de fixar commit.

### aCis

Projeto maduro e focado em Interlude retail-like. O modelo oficial é freemium; a
branch pública é descrita pelo mantenedor como demonstração antiga, sem suporte ou
garantia de estabilidade.

Riscos principais:

- latest source não publicamente auditável;
- termos completos ainda não revisados;
- mirrors de terceiros não confiáveis;
- maior dificuldade de manutenção para iniciante.

### Forks e repacks

Rejeitados devido à ausência de cadeia de origem confiável, customs incorporados,
histórico curto, licenças potencialmente inválidas e links para binários externos.

## Decisão proposta

Adotar **L2JMobius `L2J_Mobius_CT_0_Interlude`**, inicialmente fixado no commit
`e4d1d8336ed28fc0916e7caad3ca752d06169eac`.

A auditoria estática inicial não encontrou risco crítico ou backdoor confirmado.
Achados altos de configuração, banco e licença foram documentados. Eles impedem a
execução dos serviços, mas não impedem preservar a source nem preparar o build.

O proprietário aceitou a recomendação em 1 de agosto de 2026. Esse aceite fixa a base,
mas não autoriza instalação, build, banco ou execução.

## Restrições da adoção

1. Origem exclusiva:
   `https://gitlab.com/MobiusDevelopment/L2J_Mobius.git`.
2. Commit inicial:
   `e4d1d8336ed28fc0916e7caad3ca752d06169eac`.
3. Somente o módulo Interlude será usado.
4. Outras crônicas não poderão fornecer código ou datapack.
5. Scripts e JARs não serão executados antes de isolar os achados altos.
6. Licenças e cabeçalhos serão preservados.
7. O build usará JDK 25, conforme confirmado no `build.xml`.
8. MariaDB será validado sem modificar prematuramente o SQL upstream.
9. A source limpa ficará separada de runtime e customizações.

## Consequências positivas

- auditoria reproduzível;
- origem pública;
- documentação acessível;
- atualizações podem ser avaliadas por diff;
- menor dependência de mirrors ou acesso privado;
- caminho didático mais claro para o proprietário.

## Consequências negativas

- instalação futura de JDK 25 e Ant;
- revisão cuidadosa das licenças por arquivo;
- maior volume de repositório;
- necessidade de manter um commit estável em vez de acompanhar `master`
  automaticamente.

## Evidências necessárias para aceitar

- [x] Clone oficial concluído sem execução.
- [x] Commit registrado.
- [x] Licença e cabeçalhos avaliados inicialmente.
- [x] `build.xml` revisado.
- [x] Dependências JAR inventariadas e comparadas com Maven Central.
- [x] Scripts e SQL auditados estaticamente.
- [x] Varredura de segurança classificada.
- [x] Aceite explícito do proprietário.
- [ ] Isolamento dos achados altos antes de executar serviços ou banco.

## Plano de reversão

Antes de customizações, a decisão pode ser rejeitada removendo a cópia local da
source, após apresentar os arquivos e a justificativa ao proprietário. Nenhuma remoção
será automática.

Depois da baseline, trocar de base exigiria nova ADR e não permitiria portar código
sem análise de licença e desenho; misturar bases continua proibido.
