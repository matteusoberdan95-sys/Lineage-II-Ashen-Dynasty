# Auditoria de segurança da source

## Estado

**Auditoria estática inicial concluída — execução bloqueada até tratar achados altos.**

Foi auditado o checkout esparso oficial do módulo Interlude no commit:

```text
Origem: https://gitlab.com/MobiusDevelopment/L2J_Mobius.git
Branch: master
Commit: e4d1d8336ed28fc0916e7caad3ca752d06169eac
Módulo: L2J_Mobius_CT_0_Interlude
```

O clone estava limpo após a auditoria. Nenhum arquivo da source foi executado.

## Escopo avaliado

- origem e visibilidade dos projetos;
- modelo de distribuição;
- documentação de instalação;
- `build.xml` e requisitos de compilação;
- 18.982 arquivos rastreados no módulo;
- 2.473 arquivos Java, incluindo scripts de datapack;
- 100 scripts SQL;
- 14 scripts VBS e shell;
- oito JARs, sendo quatro binários e quatro source JARs;
- configurações de rede, banco, contas e runtime;
- chamadas de processo, rede externa, reflexão e compilação dinâmica;
- comandos destrutivos de banco;
- hashes e presença de código nativo nas dependências;
- cabeçalhos e sinais de licenciamento.

## Escopo ainda não avaliado

- comportamento dinâmico, pois nenhum código foi executado;
- build e testes, pois JDK 25 e Ant não estão instalados;
- análise bytecode a bytecode dos JARs;
- auditoria funcional de todos os comandos GM;
- vulnerabilidades lógicas que não sejam detectáveis por busca estática inicial;
- compatibilidade prática com MariaDB.

## Source recomendada para auditoria local

```text
Origem: https://gitlab.com/MobiusDevelopment/L2J_Mobius.git
Módulo: L2J_Mobius_CT_0_Interlude
Commit: e4d1d8336ed28fc0916e7caad3ca752d06169eac
```

Somente essa origem poderá ser usada. Forks, mirrors e repacks não serão aceitos como
substitutos.

## Achados classificados

### AUD-001 — Origem oficial pública

- **Severidade:** informativo
- **Candidata:** L2JMobius
- **Evidência:** API pública do GitLab identifica
  `MobiusDevelopment/L2J_Mobius` como projeto público, com atividade atual e URL HTTPS
  de clone.
- **Impacto:** permite fixar commit e reproduzir a auditoria.
- **Ação:** registrar URL, commit e data no primeiro clone autorizado.

### AUD-002 — Repositório multichronicle

- **Severidade:** médio
- **Candidata:** L2JMobius
- **Evidência:** a raiz contém múltiplas crônicas, incluindo o módulo específico
  `L2J_Mobius_CT_0_Interlude`.
- **Impacto:** aumenta a superfície de auditoria e o risco de importar código de outra
  crônica por engano.
- **Ação:** avaliar checkout esparso após confirmar dependências entre pastas; nunca
  misturar módulos.

### AUD-003 — Licenciamento misto e arquivo de licença ausente

- **Severidade:** alto
- **Candidata:** L2JMobius
- **Evidência:** o README da raiz declara transição para MIT, o `build.xml` e muitos
  arquivos Java declaram GPLv3 ou posterior, outros arquivos usam MIT, e não foi
  encontrado `LICENSE`, `COPYING` ou `NOTICE` autônomo no checkout.
- **Impacto:** redistribuição ou relicenciamento incorreto pode violar obrigações. A
  afirmação geral de transição não substitui os cabeçalhos existentes.
- **Ação:** tratar o módulo como licenciamento misto, preservar todos os cabeçalhos e
  solicitar esclarecimento upstream antes de qualquer distribuição pública.

### AUD-004 — Scripts VBS de inicialização

- **Severidade:** médio
- **Candidata:** L2JMobius
- **Evidência:** a documentação oficial propõe executar `DatabaseInstaller.vbs`,
  `LoginServer.vbs` e `GameServer.vbs`.
- **Impacto:** scripts podem iniciar processos, alterar banco ou depender de caminhos
  locais. A documentação não é uma auditoria do conteúdo.
- **Ação:** não executar. Ler integralmente os scripts e os JARs chamados por eles;
  substituir por scripts PowerShell controlados somente depois de compreender o fluxo.

### AUD-005 — Dependências JAR verificadas

- **Severidade:** informativo
- **Candidata:** L2JMobius
- **Evidência:** foram encontrados HikariCP 7.0.2, MySQL Connector/J 9.5.0,
  `slf4j-api` 2.0.17 e `slf4j-simple` 2.0.17, além dos source JARs. Os SHA-1 dos
  quatro binários coincidiram com Maven Central; SHA-256 local foi registrado. Nenhum
  `.dll`, `.exe`, `.so` ou `.dylib` foi encontrado dentro dos JARs.
- **Impacto:** reduz o risco de adulteração dos binários neste commit, mas não elimina
  vulnerabilidades de dependência.
- **Ação:** manter inventário e monitorar advisories. Não substituir JARs manualmente.

### AUD-006 — Uso documentado de XAMPP

- **Severidade:** baixo
- **Candidata:** L2JMobius
- **Evidência:** a instalação oficial usa o MySQL incluído no XAMPP.
- **Impacto:** adicionaria componentes desnecessários e ampliaria a superfície local.
- **Ação:** não instalar XAMPP. Validar MariaDB isolado na Sprint 4.

### AUD-007 — Branch mutável

- **Severidade:** médio
- **Candidata:** L2JMobius
- **Evidência:** o repositório é atualizado regularmente na branch `master`.
- **Impacto:** dois clones em datas diferentes podem conter código distinto.
- **Ação:** fixar commit após a auditoria e registrar atualização somente por decisão
  explícita.

### AUD-008 — Source pública aCis sem garantia

- **Severidade:** médio
- **Candidata:** aCis
- **Evidência:** o mantenedor classifica a branch pública como demo da privada, sem
  suporte ou garantia de estabilidade.
- **Impacto:** defeitos conhecidos podem permanecer na revisão pública.
- **Ação:** não usar como baseline inicial sem acesso oficial, licença revisada e
  auditoria completa.

### AUD-009 — Mirrors aCis de terceiros

- **Severidade:** alto
- **Candidata:** mirrors aCis
- **Evidência:** buscas retornaram forks não oficiais, alguns com customs e licenças
  declaradas sem cadeia de origem verificável.
- **Impacto:** código adulterado, backdoors, licença inválida ou dependências
  substituídas.
- **Ação:** rejeitar. Nenhum mirror será baixado ou executado.

### AUD-010 — Networking faz parte do domínio

- **Severidade:** informativo
- **Candidata:** qualquer L2J
- **Evidência:** Login Server e Game Server necessariamente usam sockets nas portas
  locais planejadas.
- **Impacto:** ocorrências de `Socket` e `ServerSocket` não são automaticamente
  maliciosas.
- **Ação:** classificar cada endpoint por finalidade, bind address e direção. Somente
  `127.0.0.1` será permitido na baseline local.

### AUD-011 — Serviços vinculados a todas as interfaces

- **Severidade:** alto
- **Evidência:** `LoginserverHostname` e `GameserverHostname` têm valor padrão
  `0.0.0.0`.
- **Impacto:** ao iniciar sem configuração local, as portas 2106 e 7777 podem ficar
  acessíveis por outras interfaces da máquina.
- **Ação:** não iniciar os servidores com os arquivos upstream. Criar configuração de
  runtime com bind explícito em `127.0.0.1` antes da primeira execução.

### AUD-012 — Usuário root e senha vazia na configuração JDBC

- **Severidade:** alto
- **Evidência:** os dois `Database.ini` usam `Login = root` e `Password =` por padrão.
- **Impacto:** viola o princípio do menor privilégio e a regra do projeto.
- **Ação:** não iniciar servidor ou instalador com esses valores. Criar usuário
  `l2server` restrito ao schema real, mantendo senha fora do Git.

### AUD-013 — Instalador e SQL possuem operações destrutivas

- **Severidade:** alto
- **Evidência:** o instalador contém opção que executa `DROP DATABASE` e recria o
  schema; 15 scripts SQL contêm `DROP TABLE IF EXISTS`.
- **Impacto:** uso contra schema existente pode apagar dados.
- **Ação:** não executar o instalador upstream. Na Sprint 4, importar somente em schema
  vazio, após backup e confirmação explícita. Scripts destrutivos serão tratados como
  bootstrap, nunca como migrations incrementais.

### AUD-014 — Consulta externa automática de IP

- **Severidade:** médio
- **Evidência:** quando `config/ipconfig.xml` não existe, `ServerConfig` acessa
  `http://checkip.amazonaws.com`.
- **Impacto:** gera conexão externa inesperada e usa HTTP sem TLS; também tenta
  descobrir IP público, comportamento incompatível com a baseline local.
- **Ação:** antes da execução, fornecer `ipconfig.xml` local derivado do template,
  limitado a `127.0.0.1`. Não depender da configuração automática.

### AUD-015 — Backup executa processo e remove arquivos antigos

- **Severidade:** médio
- **Evidência:** `DatabaseBackup` executa `mysqldump`, inclui a senha no argumento do
  processo e remove arquivos antigos no caminho configurado. Erros são ignorados.
- **Impacto:** senha pode ficar visível a processos locais; caminho incorreto pode
  causar exclusões indevidas; falha silenciosa pode produzir falsa confiança.
- **Ação:** manter `BackupDatabase = False`. Criar script PowerShell próprio e seguro
  em sprint posterior, validando caminho e resultado.

### AUD-016 — Compilação e execução dinâmica do datapack

- **Severidade:** médio
- **Evidência:** `ScriptExecutor` compila arquivos Java de `data/scripts`, carrega as
  classes e invoca métodos `main` por reflexão.
- **Impacto:** qualquer script Java inserido no datapack possui capacidade de executar
  código dentro do processo do Game Server.
- **Ação:** tratar `data/scripts` como código executável, exigir revisão de diff e
  proibir plugins ou scripts de origem não verificada.

### AUD-017 — Hash legado de senha

- **Severidade:** médio
- **Evidência:** o Login Server calcula `MessageDigest.getInstance("SHA")`, equivalente
  ao SHA-1 legado do ecossistema L2J, e armazena Base64 sem salt.
- **Impacto:** hashes vazados são mais suscetíveis a ataque offline que algoritmos
  modernos.
- **Ação:** não alterar o mecanismo nesta etapa, pois ele faz parte da compatibilidade
  do Login Server. Restringir acesso ao banco, usar senhas de teste exclusivas e
  documentar o risco antes de qualquer teste externo.

### AUD-018 — Criação automática de contas habilitada

- **Severidade:** médio
- **Evidência:** `AutoCreateAccounts = True` por padrão.
- **Impacto:** qualquer tentativa de login com conta inexistente cria uma conta quando
  o serviço está acessível.
- **Ação:** permitido apenas em localhost durante playtest controlado; desabilitar
  antes de qualquer teste externo.

### AUD-019 — Criptografia de pacotes desabilitada

- **Severidade:** baixo no escopo local
- **Evidência:** `PacketEncryption = False`.
- **Impacto:** tráfego do jogo pode ser observado com maior facilidade na máquina ou
  rede em que circular.
- **Ação:** manter registrado para teste posterior; não é bloqueio enquanto todo o
  tráfego estiver restrito ao loopback.

### AUD-020 — JDK e build confirmados

- **Severidade:** informativo
- **Evidência:** `build.xml` define `source="25"`, `target="25"`, UTF-8 e Ant 1.8.2 ou
  superior. O alvo padrão cria artefatos e remove a pasta intermediária `../build/dist`.
- **Impacto:** JDK diferente não é compatível; o build grava e limpa somente a pasta
  de build adjacente ao módulo.
- **Ação:** instalar JDK 25 x64 e Ant somente após concluir esta sprint. Executar o
  build na Sprint 3, nunca a partir de caminho não verificado.

### AUD-021 — Dependência HikariCP requer monitoramento

- **Severidade:** baixo no uso atual
- **Evidência:** HikariCP 7.0.2 não possuía CVE publicada na consulta, mas havia relato
  público não corrigido sobre lookup JNDI quando certas propriedades de registry são
  controladas por atacante. O código L2J analisado instancia `HikariConfig` e define
  propriedades diretamente, sem configurar esses registries por entrada externa.
- **Impacto:** o caminho relatado não foi identificado como alcançável nesta
  configuração, mas a dependência deve ser monitorada.
- **Ação:** não habilitar propriedades arbitrárias do Hikari e rever advisories antes
  de cada atualização.

### AUD-022 — Ausência de mecanismos suspeitos pesquisados

- **Severidade:** informativo
- **Evidência:** não foram encontrados PowerShell, `reg.exe`, `schtasks`,
  `System.load`, bibliotecas nativas, webhooks, Telegram, downloads automáticos ou
  plugins binários. “Discord” encontrado no datapack era nome de skill, não integração.
- **Impacto:** nenhum indício estático de persistência no Windows ou backdoor por
  esses mecanismos.
- **Ação:** repetir a varredura em todo novo commit.

## Termos usados na varredura

Foram pesquisados, sem executar arquivos:

```text
Runtime.getRuntime
ProcessBuilder
System.load
System.loadLibrary
URLClassLoader
Socket
ServerSocket
HttpClient
URLConnection
http://
https://
ftp://
webhook
discord
telegram
admin
root
password
secret
token
127.0.0.1
localhost
base64
decrypt
Class.forName
reflection
native
powershell
cmd.exe
reg.exe
schtasks
```

Cada ocorrência será analisada em contexto. Pesquisa textual isolada não prova
vulnerabilidade nem segurança.

## Inventário de dependências runtime

| Arquivo | SHA-256 local | Maven Central |
|---|---|---|
| `HikariCP-7.0.2.jar` | `f1e612fa27345be3107a85431e8a8aeb205c15364ab2f2d411e40a9d7bb08095` | SHA-1 coincidente |
| `mysql-connector-j-9.5.0.jar` | `f2ca3dfaf00d4aa311470db7ea3051962944ba0cb60005a2f75467549c39f425` | SHA-1 coincidente |
| `slf4j-api-2.0.17.jar` | `7b751d952061954d5abfed7181c1f645d336091b679891591d63329c622eb832` | SHA-1 coincidente |
| `slf4j-simple-2.0.17.jar` | `ddfea59ac074c6d3e24ac2c38622d2d963895e17f70b38ed4bdae4d780be6964` | SHA-1 coincidente |

Os quatro source JARs não entram no classpath de distribuição produzido pelo
`build.xml`. Nenhum JAR continha biblioteca nativa.

## Conclusão

- Achados críticos: nenhum.
- Achados altos: três de segurança operacional e um jurídico.
- Backdoor confirmado: nenhum.
- Conexão externa identificada: consulta de IP da AWS quando falta `ipconfig.xml`.
- Executáveis ou bibliotecas nativas: nenhum.
- Dependências runtime: hashes coincidentes com Maven Central.

A source é adequada para continuar como candidata, mas **Login Server, Game Server e
instalador de banco permanecem proibidos de executar** até os achados altos
operacionais serem isolados por configuração local e estratégia segura de banco.
