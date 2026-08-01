# Estado do ambiente

Diagnóstico realizado em 1 de agosto de 2026, no início da preparação local do projeto.
Projeto: **Lineage II: Ashen Dynasty (L2AD)**.

## Resumo

O computador atende aos requisitos básicos de sistema, Git e .NET. O Docker CLI e o
Docker Compose estão instalados, mas o Docker Engine não estava em execução durante a
verificação. Java/JDK, MariaDB/MySQL e ferramentas de build Java não foram encontrados.

Nenhuma instalação foi realizada.

As instruções condicionais de instalação e validação estão em
[`docs/setup/PREREQUISITES.md`](setup/PREREQUISITES.md).

## Sistema

| Item | Resultado |
|---|---|
| Sistema operacional | Windows 11 Pro, versão `10.0.26200` |
| Arquitetura do sistema | 64 bits |
| Arquitetura do processo | x64 |
| PowerShell | 5.1.26100.8894 |
| Pasta do projeto | `C:\Users\mober\OneDrive\Desktop\Lineage II Ashen Dynasty` |
| Repositório Git | Ainda não inicializado |
| Código-fonte existente | L2JMobius Interlude em checkout esparso; commit `e4d1d8336ed28fc0916e7caad3ca752d06169eac` |

### Observação sobre o OneDrive

O projeto está dentro de uma pasta sincronizada pelo OneDrive. Isso é funcional, mas
pode causar bloqueios de arquivos, sincronização de artefatos grandes e conflitos em
pastas de runtime. Antes do primeiro build, deve-se decidir entre manter o repositório
nesse local com exclusões adequadas ou movê-lo manualmente para uma pasta de
desenvolvimento não sincronizada.

## Ferramentas encontradas

| Ferramenta | Versão/estado | Caminho ou observação |
|---|---|---|
| Git | 2.55.0.windows.2 | `C:\Program Files\Git\mingw64\bin\git.exe` |
| .NET SDK | 10.0.301 | `C:\Program Files\dotnet\dotnet.exe` |
| Docker CLI | 29.6.1 | `C:\Program Files\Docker\Docker\resources\bin\docker.exe` |
| Docker Compose | 5.3.0 | Plugin do Docker CLI |
| Docker Engine | Indisponível no diagnóstico | O named pipe do Docker Desktop Linux Engine não existia; provavelmente o Docker Desktop estava fechado |

## Ferramentas ausentes ou indisponíveis

| Ferramenta | Resultado |
|---|---|
| Java runtime (`java`) | Não encontrado no `PATH` nem na lista de programas instalada |
| Java compiler (`javac`) | Não encontrado |
| `JAVA_HOME` | Não definido |
| MariaDB CLI (`mariadb`) | Não encontrado |
| MySQL CLI (`mysql`) | Não encontrado |
| Serviço MariaDB/MySQL | Nenhum serviço detectado |
| Maven (`mvn`) | Não encontrado |
| Gradle (`gradle`) | Não encontrado |
| Ant (`ant`) | Não encontrado |

Não há entrada de Java no `PATH`. Maven, Gradle e Ant não devem ser instalados por
suposição: primeiro será identificado o sistema de build da source escolhida, dando
preferência ao wrapper versionado pelo próprio projeto quando existir.

## Portas locais

As consultas foram feitas somente para listeners TCP.

| Porta | Uso planejado | Estado |
|---|---|---|
| 2106 | Login Server | Livre |
| 7777 | Game Server | Livre |
| 3306 | MariaDB | Livre |

Uma porta livre agora não garante disponibilidade durante a futura execução. A
validação deverá ser repetida antes de iniciar os serviços.

## Incompatibilidades e bloqueios

1. L2JMobius Interlude foi aceito na ADR-001 e está fixado no commit auditado.
2. O `build.xml` confirma JDK 25 e Apache Ant 1.8.2 ou superior; ambos estão ausentes.
3. Sem MariaDB local ou Docker Engine ativo, o banco ainda não pode ser preparado.
4. A pasta ainda não é um repositório Git.
5. O local sincronizado pelo OneDrive precisa ser avaliado antes de gerar runtime,
   logs e artefatos de build.

Para o futuro build, serão necessários JDK 25 e Ant; para execução, os achados altos
da auditoria deverão ser isolados antes de iniciar qualquer serviço.

## Ações manuais recomendadas, ainda não executadas

### Java/JDK

- **Nome recomendado:** BellSoft Liberica JDK x64.
- **Versão confirmada:** JDK 25.
- **Motivo:** o `build.xml` usa source/target 25 e a documentação oficial L2JMobius
  recomenda Liberica JDK 25.
- **Importante:** não foi instalado nesta sprint.
- **Instalação futura:** baixar o instalador JDK 25 x64 somente de
  `https://bell-sw.com/pages/downloads/`, habilitando `JAVA_HOME` e a inclusão no
  `PATH`.
- **Validação futura:**

  ```powershell
  java --version
  javac --version
  $env:JAVA_HOME
  ```

### MariaDB

- **Nome:** MariaDB Server x64.
- **Versão recomendada:** linha LTS 11.4, condicionada à compatibilidade da source.
- **Motivo:** banco relacional pretendido para Login Server e Game Server, com suporte
  prolongado.
- **Instalação futura no Windows:** usar somente o instalador oficial disponível em
  `https://mariadb.org/download/`.
- **Alternativa futura:** container MariaDB com tag fixada em Docker Compose, depois
  de ativar e validar o Docker Engine.
- **Validação futura:**

  ```powershell
  mariadb --version
  Get-Service *maria*
  Test-NetConnection 127.0.0.1 -Port 3306
  ```

Não será usado o usuário `root` pela aplicação. Usuário, schemas e privilégios serão
definidos somente depois de inspecionar o modelo de banco da source.

### Docker Desktop

- **Nome:** Docker Desktop (já instalado).
- **Versões detectadas:** Docker CLI 29.6.1 e Docker Compose 5.3.0.
- **Ação necessária:** iniciar manualmente o Docker Desktop quando a opção de banco em
  container for avaliada. Não é necessária reinstalação neste momento.
- **Validação:**

  ```powershell
  docker info
  docker compose version
  ```

### Apache Ant

- **Versão mínima confirmada:** 1.8.2.
- **Versão recomendada para instalação:** 1.10.17.
- **Sistema de build:** `build.xml` do Apache Ant; não há wrapper.
- **Instalação:** será detalhada e executada manualmente antes da Sprint 3.
- **Validação futura:** `ant -version`.

## Comandos usados no diagnóstico

Todos os comandos abaixo foram executados apenas para leitura:

```powershell
java --version
javac --version
git --version
dotnet --version
docker --version
docker compose version
docker info
mariadb --version
mysql --version
mvn --version
gradle --version
ant -version
Get-CimInstance Win32_OperatingSystem
Get-NetTCPConnection -State Listen -LocalPort 2106,7777,3306
```

## Próxima atualização deste documento

Repetir o diagnóstico depois que o proprietário autorizar e concluir as instalações
de JDK 25 e Ant. Registrar também o estado real do Docker Engine e, na Sprint 4, a
estratégia escolhida para MariaDB.

## Conclusão da Sprint 0

O ambiente foi inventariado sem executar código externo. Não há incompatibilidade
crítica no sistema operacional, Git, PowerShell ou .NET. As ausências de JDK e banco
são esperadas nesta etapa e devem ser resolvidas somente após as decisões das sprints
correspondentes. O Docker Engine parado é uma pendência operacional, não um bloqueio
para encerrar o diagnóstico.
