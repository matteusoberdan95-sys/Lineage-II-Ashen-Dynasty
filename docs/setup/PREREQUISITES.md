# Pré-requisitos locais

Este documento descreve os pré-requisitos do Lineage II: Ashen Dynasty (L2AD) para
Windows e registra as ferramentas validadas na Sprint 3.

O estado efetivamente detectado está em
[`docs/ENVIRONMENT_STATUS.md`](../ENVIRONMENT_STATUS.md).

## Regra principal

A versão do JDK e o sistema de build foram determinados pelo `build.xml` auditado do
L2JMobius Interlude. O projeto exige JDK 25 e Apache Ant 1.8.2 ou superior.

## Matriz de pré-requisitos

| Componente | Necessidade | Estado atual | Ação |
|---|---|---|---|
| Windows x64 | Obrigatório | Windows 11 Pro x64 | Nenhuma |
| Git | Obrigatório | 2.55.0 instalado | Nenhuma |
| PowerShell | Obrigatório | 5.1 instalado | Suficiente para os scripts locais planejados |
| JDK 25 x64 | Obrigatório para build e execução | Liberica Full JDK 25.0.4+9 instalado | Manter na linha 25 durante a baseline |
| Apache Ant 1.8.2+ | Obrigatório; não há wrapper | Ant 1.10.17 instalado | Usar 1.10.17 para reproduzir o build |
| MariaDB | Obrigatório para execução | Ausente | Preparar somente na Sprint 4 |
| Docker Desktop | Alternativa para MariaDB | Instalado, Engine parado | Iniciar manualmente apenas quando necessário |
| .NET SDK | Futuro | 10.0.301 instalado | Nenhuma nesta fase |
| Cliente Interlude legítimo | Necessário no primeiro login | Não avaliado | Disponibilização manual somente na Sprint 6 |

## JDK

### Versão

O `build.xml` do commit auditado define `source="25"` e `target="25"`. A documentação
oficial recomenda BellSoft Liberica JDK 25. Portanto, a versão exigida é:

```text
BellSoft Liberica JDK 25, Windows x64
```

JDK 21 não é suficiente para esse commit.

### Instalação validada

O pacote `BellSoft.LibericaJDK.25.Full` versão 25.0.4.9 foi instalado pelo WinGet
após autorização explícita. Para reinstalação manual:

1. Acessar `https://bell-sw.com/pages/downloads/`.
2. Selecionar:
   - Java: 25;
   - sistema operacional: Windows;
   - arquitetura: x86 64-bit;
   - pacote: Full JDK;
   - instalador: MSI.
3. Conferir que o publicador é BellSoft.
4. No instalador, habilitar a definição de `JAVA_HOME` e a inclusão no `PATH`.
5. Fechar e abrir novamente o terminal.

### Validação

```powershell
java --version
javac --version
$env:JAVA_HOME
Get-Command java
Get-Command javac
```

`java` e `javac` devem reportar a mesma linha principal de versão, e `JAVA_HOME` deve
apontar para a raiz do JDK, não para sua pasta `bin`.

## Apache Ant

O módulo usa Apache Ant e não contém wrapper. O requisito mínimo declarado é Ant
1.8.2. A versão recomendada é **Apache Ant 1.10.17**, release estável atual,
compatível com JDK 25 e obtida em `https://ant.apache.org/bindownload.cgi`.

Instalação validada:

1. baixar `apache-ant-1.10.17-bin.zip` do site oficial Apache;
2. verificar o SHA-512 publicado;
3. extrair em uma pasta de ferramentas local;
4. definir `ANT_HOME` para a pasta extraída;
5. adicionar `%ANT_HOME%\bin` ao `PATH`;
6. abrir novo terminal.

Validação:

```powershell
ant -version
```

Maven e Gradle não são necessários para esta source.

O Ant 1.10.17 foi instalado em escopo de usuário. O SHA-512 validado e os comandos de
build estão em [`BUILD_GUIDE.md`](BUILD_GUIDE.md).

## MariaDB

### Versão

A linha MariaDB 11.4 LTS x64 é a referência inicial. A versão final e o modo de
execução dependem da compatibilidade dos scripts SQL da source e serão definidos na
Sprint 4.

Existirão duas alternativas documentadas:

1. MariaDB Server instalado no Windows;
2. MariaDB em container por Docker Compose.

Somente uma será adotada como opção principal. A aplicação nunca usará `root`; será
criado um usuário local com privilégios limitados aos schemas necessários.

### Instalação manual futura no Windows

1. Aguardar a auditoria dos scripts SQL e a decisão da Sprint 4.
2. Acessar somente `https://mariadb.org/download/`.
3. Selecionar MariaDB Server, Windows, x86_64 e a versão LTS aprovada.
4. Conferir assinatura e publicador do instalador.
5. Definir uma senha local forte para administração e mantê-la fora do Git.
6. Não habilitar acesso remoto.
7. Não reutilizar a conta administrativa na aplicação.

### Validação futura

```powershell
mariadb --version
Get-Service *maria*
Test-NetConnection 127.0.0.1 -Port 3306
```

O resultado esperado é um serviço saudável, acessível por `127.0.0.1`, sem exposição
em interfaces públicas.

## Docker Desktop

Docker CLI e Compose já estão instalados, mas o Docker Engine estava parado no
diagnóstico.

Quando a alternativa em container for necessária:

1. iniciar manualmente o Docker Desktop pelo menu Iniciar;
2. aguardar o indicador de Engine ativo;
3. abrir um novo PowerShell;
4. executar:

```powershell
docker info
docker compose version
```

`docker info` deve mostrar as seções Client e Server sem erro de named pipe. Não será
criado ou iniciado container antes da Sprint 4.

## Git

O Git está instalado e a pasta é um repositório sincronizado com `origin/main`. A
source L2JMobius é um submódulo fixado por commit.

Validação atual:

```powershell
git --version
```

## Portas locais

Portas planejadas:

| Serviço | Endereço |
|---|---|
| Login Server | `127.0.0.1:2106` |
| Game Server | `127.0.0.1:7777` |
| MariaDB | `127.0.0.1:3306` |

Verificação não destrutiva:

```powershell
Get-NetTCPConnection -State Listen -LocalPort 2106,7777,3306 -ErrorAction SilentlyContinue
```

Ausência de saída significa que não há listener TCP nessas portas naquele momento.
Nenhum script do projeto abrirá firewall ou configurará roteador automaticamente.

## Cliente Interlude

O cliente é software proprietário e não será baixado, distribuído ou versionado pelo
projeto. Na Sprint 6, o proprietário deverá fornecer manualmente uma instalação
legítima e compatível. Até lá, nenhuma ação é necessária.

## Instalações necessárias por etapa

### Agora, na Sprint 0

Nenhuma.

### Para o build

- BellSoft Liberica Full JDK 25.0.4+9 x64: instalado.
- Apache Ant 1.10.17: instalado.

### Antes da primeira execução

- MariaDB Server local **ou** Docker Engine funcional com MariaDB em container.

Toda instalação será feita manualmente pelo proprietário após instruções específicas e
será validada antes de avançar.
