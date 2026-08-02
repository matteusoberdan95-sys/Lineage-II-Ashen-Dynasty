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
- Configuração do cliente limpo, conta local controlada e relatório do primeiro login.
- Scripts para `l2.ini` Ver413, criação/exibição de conta e verificação de personagem.
- Checklist mínimo de mundo, snapshot de personagem e espera de estado online/offline.
- Relatório do playtest controlado com progresso de nível, logout limpo e persistência.
- ADR-004 para customizações de produto via overlays fora do submódulo.
- Overlay de identidade: servidor ID 1 `Ashen Dynasty` e notícia de entrada local.
- Scripts para aplicar e verificar a customização de produto no runtime.
- Scripts para conta/personagem Master local (`ashen_admin` / `ASHENADM`) com
  privilégios GM de dono, credencial DPAPI e verificação isolada do playtest.
- ADR-005: rates locais XP/SP 500x com drop/spoil retail-like e Adena amount 10x.
- Roteiro de regressão, checklist GM Interlude e validação manual da Sprint 10.
- ADR-006 e documento de design da escada de gear (retail T0–T2, depois TT →
  Draconic → DK/Fênix → Dynarty), sem implementação de item custom.
- ADR-007: especificação do tier Ashen TT (peças, obtenção, tempo, IDs 9300–9399).
- Implementação Ashen TT em overlays (itens, sets, raids, spawns) + scripts apply/verify.
- ADR-008: design do tier Ashen Draconic (T4), IDs 9400–9499.
- Implementação Ashen Draconic em overlays (itens, sets, raids, spawns) + scripts
  apply/verify (Sprint 14).
- Craft Ashen TT/Draconic com fragmentos (`9399`/`9499`): scrolls 9500–9545,
  merge de recipes em `Recipes.xml`, drops de recipe nos raids (Sprint 15).
- Quest Q900 Ashen Scale of Transition (NPC 93002): ponte TT→Draconic com
  fragmentos + recipe de peitoral (Sprint 16).
- ADR-009: design do tier Ashen DK / Phoenix (T5), IDs 9600–9699 (Sprint 17).
- Implementação Ashen DK / Phoenix em overlays (itens, sets, raids, spawns) +
  scripts apply/verify (Sprint 18).
- Craft Ashen DK/Phoenix com fragmentos (`9699`/`9499`): scrolls 9546–9568,
  recipes listIds 918–940, drops nos raids T5 (Sprint 19).
- Quest Q901 Ashen Ember of Ascent: ponte Draconic→DK (exige Q900), fragmentos
  DK + recipe peitoral DK (Sprint 20).
- ADR-010: design do tier Ashen Dynarty (T6), IDs 9700–9799 (Sprint 21).
- Implementação Ashen Dynarty + scrolls 9570/9571 e merge enchant +30
  Dynarty-only (Sprint 22).
- Craft Ashen Dynarty com fragmentos (`9799`/`9699`): scrolls 9572–9594
  (pula 9569–9571), recipes listIds 941–963, drops nos raids T6 (Sprint 23).
- Quest Q902 Ashen Crown of Dynasty: ponte DK→Dynarty (exige Q901), fragmentos
  Dynarty + recipe peitoral Dynarty (Sprint 23).

### Segurança

- Login, Game e MariaDB restritos a listeners `127.0.0.1`.
- Cliente proprietário, credenciais, runtime, logs, builds e backups excluídos do Git.
- Conta de teste local com senha DPAPI; `AutoCreateAccounts` permanece desabilitado.
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
