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
- Scripts PowerShell repetíveis para clean, build e detecção de testes.
- Guia de build e relatório das duas primeiras compilações limpas.
- Validação de Liberica JDK 25.0.4+9 e Apache Ant 1.10.17.
- Bootstrap auditado do schema `l2jmobiusinterlude` em MariaDB 11.4.3.
- Scripts de importação, verificação, backup e controle do serviço MariaDB.
- Usuário local `l2server` com credencial protegida por DPAPI.
- Documentação de setup e auditoria do banco.
- Build local reproduzível com patch mínimo de bind para o Game Server.
- Preparação de runtime, registro de HexID, start, stop, status e verificação dos
  servidores Java.
- Configuração e relatório da primeira execução local.
- ADR-003 para patches de segurança fora do submódulo.

### Segurança

- Login, Game e MariaDB restritos a listeners `127.0.0.1`.
- Cliente proprietário, credenciais, runtime, logs, builds e backups excluídos do Git.
- Artefatos do Ant redirecionados para `server/runtime/build`, fora do submódulo.
- MariaDB restrito a `127.0.0.1:3306`.
- Importação recusa schemas não vazios e evita o instalador destrutivo upstream.
- HexID público upstream removido e substituído por registro local aleatório.
- Criação automática de contas, novos registros, GUI, backup upstream e scripts
  custom desabilitados.
- Descoberta externa de IP impedida por `ipconfig.xml`; nenhuma conexão Java externa
  foi observada.

## Política

- Alterações upstream e customizações do Ashen Dynasty devem aparecer separadamente.
- Toda customização futura deve registrar motivação, arquivos, testes e impacto.
- Releases e datas serão adicionadas somente quando uma versão for efetivamente
  criada; nenhuma tag é implícita.
