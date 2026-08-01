# Notas de licenciamento e propriedade intelectual

Este arquivo registra observações técnicas e não constitui aconselhamento jurídico.

## Projeto Ashen Dynasty

Ainda não foi definida uma licença própria para os arquivos originais do Ashen
Dynasty. Essa decisão será tomada somente depois de:

- confirmar a licença da source adotada;
- separar código upstream de código original;
- entender obrigações de distribuição e disponibilização de source;
- identificar marcas, assets e dados que não pertencem ao projeto.

Até essa decisão, não se deve presumir que o conteúdo do repositório pode ser
redistribuído livremente.

## L2JMobius

O projeto oficial declara estar em transição para a licença MIT. No commit
`e4d1d8336ed28fc0916e7caad3ca752d06169eac`, o `build.xml` e muitos arquivos Java do
módulo Interlude declaram GPLv3 ou posterior, enquanto outros arquivos declaram MIT.
Não foi encontrado arquivo autônomo `LICENSE`, `COPYING` ou `NOTICE` no checkout.
Consequências:

- a licença deve ser verificada por arquivo;
- cabeçalhos e avisos não podem ser removidos;
- arquivos GPL não se tornam MIT por estarem no mesmo repositório;
- modificações e distribuições podem gerar obrigações diferentes conforme a origem;
- o commit exato e os textos de licença devem ser preservados.

Para fins conservadores, o módulo deve ser tratado como **licenciamento misto**, sem
relicenciar ou remover cabeçalhos. Antes de distribuição pública, deve-se obter
esclarecimento upstream e aconselhamento jurídico apropriado.

Referências:

- `https://www.l2jmobius.org/`
- `https://gitlab.com/MobiusDevelopment/L2J_Mobius`

## aCis

O fórum oficial descreve modelo freemium e termos próprios, historicamente incluídos
em `license.htm`. A branch pública é uma demonstração da privada e não recebe suporte.

Como o texto integral aplicável à revisão atual não foi obtido:

- aCis não será incorporado a partir de mirrors;
- acesso à revisão privada não será adquirido automaticamente;
- nenhuma licença declarada por fork será aceita como prova;
- permissão para modificar, versionar e redistribuir precisa ser confirmada na
  distribuição oficial.

Referências:

- `https://acis.i-live.eu/index.php?topic=10422.0`
- `https://acis.i-live.eu/index.php?topic=1974.0`

## Forks e relicenciamento

Um fork não pode substituir obrigações GPL ou termos de terceiros simplesmente
adicionando um arquivo MIT. Antes de usar qualquer fork, seria necessário provar:

1. origem de todo o código;
2. direito de relicenciamento;
3. preservação dos avisos;
4. compatibilidade entre licenças;
5. ausência de arquivos proprietários.

Os forks encontrados nesta avaliação não atenderam a essa cadeia de evidências.

## Lineage 2 e cliente

Lineage 2, nomes, marcas, cliente, executáveis, texturas, animações, sons e outros
assets pertencem aos respectivos titulares. Este projeto não concede direitos sobre
esses materiais.

Regras do repositório:

- não versionar o cliente completo;
- não versionar executáveis do cliente;
- não copiar texturas, animações, sons ou mapas proprietários;
- não distribuir cliente ou patch proprietário;
- não publicar links não oficiais;
- manter eventual cliente legítimo fora da raiz Git;
- registrar somente documentação e arquivos cuja distribuição seja permitida.

## Geodata e datapack

Geodata, pathnodes, HTML, XML, SQL e scripts também precisam de origem e licença
verificáveis. O fato de um arquivo ser necessário para o servidor não implica
permissão de redistribuição.

Cada conjunto deverá registrar:

- origem;
- versão ou commit;
- licença;
- hash, quando binário;
- alterações locais;
- permissão de distribuição.

## Dependências

Para cada JAR ou biblioteca futura serão registrados:

- nome e versão;
- fornecedor e URL oficial;
- licença;
- checksum SHA-256;
- finalidade;
- presença de código nativo;
- vulnerabilidades conhecidas relevantes.

Dependências baixadas manualmente não serão commitadas sem justificativa e licença
compatível.

Dependências runtime encontradas no commit auditado:

| Componente | Versão | Observação de licença |
|---|---|---|
| HikariCP | 7.0.2 | Apache License 2.0 conforme upstream; confirmar avisos na distribuição |
| MySQL Connector/J | 9.5.0 | GPLv2 com Universal FOSS Exception conforme upstream |
| SLF4J API | 2.0.17 | Licença MIT incluída no JAR |
| SLF4J Simple | 2.0.17 | Licença MIT incluída no JAR |

Os hashes SHA-1 dos quatro JARs runtime coincidiram com Maven Central. Os hashes
SHA-256 locais estão em `docs/security/SOURCE_AUDIT.md`.

## Estado atual

- Source adotada: L2JMobius Interlude no commit
  `e4d1d8336ed28fc0916e7caad3ca752d06169eac`, conforme ADR-001.
- Licença do código original L2AD: pendente.
- Cliente no repositório: nenhum.
- Binários de terceiros no repositório: nenhum.
- Próxima revisão: após clone e auditoria autorizados.
