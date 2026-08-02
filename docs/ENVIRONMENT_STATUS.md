# Estado do ambiente

Diagnóstico realizado em 1 de agosto de 2026 e atualizado após a primeira
customização de produto na Sprint 9. Projeto: **Lineage II: Ashen Dynasty (L2AD)**.

## Resumo

O computador atende aos requisitos de sistema e build. Liberica Full JDK 25.0.4+9 e
Apache Ant 1.10.17 foram instalados e validados na Sprint 3. MariaDB 11.4.3 foi
instalado e validado na Sprint 4. O Docker CLI e o Docker Compose estão instalados,
mas o Docker Engine não é necessário para a opção de banco adotada.

Login Server e Game Server foram compilados, configurados e executados na Sprint 5.
Os processos Java e o banco usam somente loopback. O cliente limpo validou login e
personagem na Sprint 6.

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
| Repositório Git | Inicializado e sincronizado com `origin/main` |
| Código-fonte existente | L2JMobius Interlude como submódulo; commit `e4d1d8336ed28fc0916e7caad3ca752d06169eac` |

### Observação sobre o OneDrive

O projeto está dentro de uma pasta sincronizada pelo OneDrive. Isso é funcional, mas
pode causar bloqueios de arquivos, sincronização de artefatos grandes e conflitos em
pastas de runtime. Dois builds foram concluídos nesse local sem bloqueio. Runtime e
artefatos estão ignorados pelo Git, mas eventuais erros de arquivo em uso devem
considerar a sincronização do OneDrive como possível causa.

## Ferramentas encontradas

| Ferramenta | Versão/estado | Caminho ou observação |
|---|---|---|
| Git | 2.55.0.windows.2 | `C:\Program Files\Git\mingw64\bin\git.exe` |
| .NET SDK | 10.0.301 | `C:\Program Files\dotnet\dotnet.exe` |
| Docker CLI | 29.6.1 | `C:\Program Files\Docker\Docker\resources\bin\docker.exe` |
| Docker Compose | 5.3.0 | Plugin do Docker CLI |
| Docker Engine | Indisponível no diagnóstico | O named pipe do Docker Desktop Linux Engine não existia; provavelmente o Docker Desktop estava fechado |
| Java runtime | BellSoft Liberica OpenJDK 25.0.4+9 LTS | `C:\Program Files\BellSoft\LibericaJDK-25-Full\bin\java.exe` |
| Java compiler | `javac 25.0.4` | Mesmo `JAVA_HOME` do runtime |
| Apache Ant | 1.10.17 | Instalação de usuário validada por SHA-512 |
| MariaDB Server/CLI | 11.4.3 LTS | Serviço Windows ativo em `127.0.0.1:3306` |

## Ferramentas ainda ausentes ou indisponíveis

| Ferramenta | Resultado |
|---|---|
| Maven (`mvn`) | Não encontrado; não é necessário para esta source |
| Gradle (`gradle`) | Não encontrado; não é necessário para esta source |

## Portas locais

As consultas foram feitas somente para listeners TCP.

| Porta | Uso planejado | Estado |
|---|---|---|
| 2106 | Login Server | Em uso somente por `127.0.0.1` |
| 9014 | Login ↔ Game | Em uso somente por `127.0.0.1` |
| 7777 | Game Server | Em uso somente por `127.0.0.1` |
| 3306 | MariaDB | Em uso somente por `127.0.0.1` |

## Incompatibilidades e bloqueios

1. L2JMobius Interlude foi aceito na ADR-001 e está fixado no commit auditado.
2. JDK 25 e Ant 1.10.17 estão instalados; três clean builds foram aprovados.
3. MariaDB local, schema e usuário restrito foram preparados.
4. Bind, JDBC, descoberta de IP e registro foram isolados na Sprint 5.
5. Cliente, checklist de mundo e playtest controlado validados até a Sprint 8.

## Estado das ferramentas por etapa

### Java/JDK

- **Nome recomendado:** BellSoft Liberica JDK x64.
- **Versão confirmada:** JDK 25.
- **Motivo:** o `build.xml` usa source/target 25 e a documentação oficial L2JMobius
  recomenda Liberica JDK 25.
- **Versão instalada:** BellSoft Liberica Full JDK 25.0.4+9 LTS.
- **Origem:** pacote WinGet `BellSoft.LibericaJDK.25.Full`, cujo MSI veio de
  `download.bell-sw.com`.
- **Validação executada:**

  ```powershell
  java --version
  javac --version
  $env:JAVA_HOME
  ```

### MariaDB

- **Nome:** MariaDB Server x64.
- **Versão instalada:** 11.4.3 LTS.
- **Motivo:** banco relacional pretendido para Login Server e Game Server, com suporte
  prolongado.
- **Modo adotado:** serviço Windows local; Docker não é usado para o banco.
- **Bind:** `127.0.0.1:3306`.
- **Validação executada:**

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
- **Versão instalada:** 1.10.17.
- **Sistema de build:** `build.xml` do Apache Ant; não há wrapper.
- **Integridade:** SHA-512 coincidente com o publicado pela Apache.
- **Validação executada:** `ant -version`.

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
Get-NetTCPConnection -State Listen -LocalPort 2106,7777,9014,3306
```

## Próxima atualização deste documento

Na próxima sprint, registrar roteiro de regressão local ou a próxima customização
sob ADR dedicada (ainda sem rates/itens/rede externa).

## Conclusão da Sprint 0

O ambiente foi inventariado sem executar código externo. Não houve incompatibilidade
crítica no sistema operacional, Git, PowerShell ou .NET. Na Sprint 0, as ausências de
JDK e banco eram esperadas. O JDK foi resolvido na Sprint 3 e o banco na Sprint 4. O
Docker Engine parado não bloqueou o diagnóstico.

## Conclusão da Sprint 3

JDK 25 e Ant foram instalados e validados. A source compilou três vezes, sem warning
do compilador, e gerou o pacote esperado fora do submódulo. Consulte
[`docs/setup/FIRST_BUILD_REPORT.md`](setup/FIRST_BUILD_REPORT.md).

## Conclusão da Sprint 4

MariaDB 11.4.3 foi instalado como serviço Windows, restrito a localhost. O schema
`l2jmobiusinterlude` possui 100 tabelas, o usuário `l2server` está restrito ao schema,
e backup, stop/start e persistência após restart foram validados.

## Conclusão da Sprint 5

O build local aplicou um patch mínimo para o bind 7777 sem alterar o submódulo.
Login, Game e canal interno abriram somente em loopback. Os pools JDBC conectaram com
`l2server`; skills, itens, NPCs e spawns carregaram; o ID 1 foi registrado e novos
cadastros foram bloqueados. Não houve conexão Java externa nem erro crítico.

## Conclusão da Sprint 6

O cliente limpo em `D:\L2-ASHEN-DYNASTY` autenticou em localhost. A conta controlada
`ashen_test` criou o personagem `NEIDE157`, persistido no MariaDB com
`lastIP=127.0.0.1`. `L2.exe` exige elevação UAC. O pack L2Agonia foi rejeitado.

## Conclusão da Sprint 7

Checklist mínimo de mundo aprovado: personagem `NEIDE157` com 6 itens, posição
coerente e listeners apenas em loopback. Scripts de snapshot e verificação de
estado online foram adicionados.

## Conclusão da Sprint 8

Playtest controlado aprovado pelo proprietário. `NEIDE157` avançou para o nível 2,
mudou de posição, fez logout com `online=0` e manteve 6 itens persistidos. Stack
local e listeners em loopback permaneceram estáveis.

## Conclusão da Sprint 9

ADR-004 aceita. Overlays versionados renomeiam o servidor ID 1 para `Ashen Dynasty`
e habilitam a notícia de entrada local. Submódulo permanece limpo; rates e gameplay
não foram alterados. Consulte
[`docs/setup/PRODUCT_CUSTOMIZATION_REPORT.md`](setup/PRODUCT_CUSTOMIZATION_REPORT.md).

Conta Master local `ashen_admin` / personagem `ASHENADM` (`accessLevel=100`) criada
para ferramentas GM de dono. Playtest `ashen_test` / `NEIDE157` permanece sem GM.
Consulte [`docs/setup/LOCAL_ADMIN_SETUP.md`](setup/LOCAL_ADMIN_SETUP.md).
