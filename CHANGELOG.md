# Changelog

Todas as mudanças relevantes do Ashen Dynasty serão registradas neste arquivo.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o
versionamento futuro seguirá [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Não lançado]

### Adicionado

- Diagnóstico do ambiente Windows local.
- Avaliação de L2JMobius Interlude e aCis.
- Auditoria estática inicial da source escolhida.
- L2JMobius Interlude como submódulo fixado no commit
  `e4d1d8336ed28fc0916e7caad3ca752d06169eac`.
- Documentação de arquitetura, segurança, visão e fluxo de desenvolvimento.
- Configurações básicas de editor, Git e ambiente local.

### Segurança

- Execução bloqueada enquanto bind de rede, usuário de banco e SQL destrutivo não
  estiverem isolados.
- Cliente proprietário, credenciais, runtime, logs, builds e backups excluídos do Git.

## Política

- Alterações upstream e customizações do Ashen Dynasty devem aparecer separadamente.
- Toda customização futura deve registrar motivação, arquivos, testes e impacto.
- Releases e datas serão adicionadas somente quando uma versão for efetivamente
  criada; nenhuma tag é implícita.
