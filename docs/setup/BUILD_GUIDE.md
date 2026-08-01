# Guia de build

## Escopo

Este guia compila a baseline limpa do L2JMobius
`L2J_Mobius_CT_0_Interlude`. Ele não inicia servidor, banco ou instalador e não
aplica customizações.

## Versões validadas

| Componente | Versão |
|---|---|
| Source | commit `e4d1d8336ed28fc0916e7caad3ca752d06169eac` |
| JDK | BellSoft Liberica Full JDK 25.0.4+9 LTS, Windows x64 |
| Compilador | `javac 25.0.4` |
| Build | Apache Ant 1.10.17 |
| Encoding | UTF-8 |
| Linguagem/bytecode | Java 25 |

Maven e Gradle não são usados. O módulo não contém wrapper de Ant.

## Instalações locais

O JDK foi instalado pelo pacote WinGet oficial:

```powershell
winget install `
  --id BellSoft.LibericaJDK.25.Full `
  --exact `
  --source winget `
  --accept-package-agreements `
  --accept-source-agreements
```

O Ant foi baixado de:

```text
https://downloads.apache.org/ant/binaries/apache-ant-1.10.17-bin.zip
```

SHA-512 validado:

```text
5205a3c87902dd356a6bfcfc5d07659361d1c74627716662d7b31ab47817388dd1d985cfc27ca81a607827cb58d9e36d2d2fbf87a961a5dd4eeabfbde380aa71
```

Localização atual:

```text
JAVA_HOME=C:\Program Files\BellSoft\LibericaJDK-25-Full\
ANT_HOME=C:\Users\mober\AppData\Local\Programs\Apache Ant\apache-ant-1.10.17
```

Esses caminhos são específicos desta máquina e não devem ser colocados em scripts
como requisitos fixos.

## Validar o ambiente

Abra um novo PowerShell e execute:

```powershell
java --version
javac --version
ant -version
$env:JAVA_HOME
$env:ANT_HOME
Get-Command java
Get-Command javac
Get-Command ant
```

O Java e o compilador devem reportar a versão principal 25. O Ant deve reportar
1.10.17 e usar o mesmo JDK.

## Build recomendado

Na raiz do repositório:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\build-server.ps1
```

O script:

1. valida Java 25, `javac` 25 e Ant 1.10.17;
2. confirma o commit upstream aprovado;
3. confirma que a source não possui alterações rastreadas;
4. remove somente o build anterior em `server/runtime/build`;
5. passa um diretório externo ao submódulo por `-Dbuild`;
6. executa o target oficial `cleanup`;
7. confirma Login Server, Game Server e Database Installer dentro do ZIP;
8. imprime duração, tamanho e SHA-256.

Para preservar temporariamente a saída anterior:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\build-server.ps1 `
  -NoClean
```

Essa opção não é recomendada para validar clean build.

## Comando Ant equivalente

O script executa conceitualmente:

```powershell
ant `
  -f .\server\source\l2jmobius-upstream\L2J_Mobius_CT_0_Interlude\build.xml `
  "-Dbuild=<raiz-do-repositorio>\server\runtime\build" `
  cleanup
```

Não execute o build sem `-Dbuild`: o padrão upstream grava artefatos dentro da raiz
do submódulo.

## Saída

Artefato distribuível:

```text
server/runtime/build/L2J_Mobius_CT_0_Interlude.zip
```

Entradas obrigatórias verificadas:

```text
libs/LoginServer.jar
libs/GameServer.jar
db_installer/DatabaseInstaller.jar
```

O diretório `server/runtime/` é ignorado pelo Git.

## Limpeza

Impacto: o comando abaixo remove recursivamente **somente**
`server/runtime/build`, que contém artefatos gerados:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\clean-server.ps1
```

Para visualizar a ação sem remover:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\clean-server.ps1 `
  -WhatIf
```

O script valida o caminho antes da exclusão e recusa destinos fora de
`server/runtime`.

## Testes

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\run-tests.ps1
```

No commit adotado não existem targets `test`, `tests` ou `check`, nem referências a
JUnit ou TestNG. O resultado esperado é:

```text
NO_AUTOMATED_TESTS_AVAILABLE
```

Isso significa **ausência de testes**, não aprovação funcional. O build valida apenas
compilação e empacotamento.

## Solução de problemas

### `java` ou `ant` não encontrado

Feche e reabra o terminal para recarregar as variáveis de ambiente. Em seguida,
repita a validação.

### JDK incompatível

Confirme que `java` e `javac` vêm do mesmo `JAVA_HOME`. JRE isolado não é suficiente.

### Source modificada

O script interrompe o build diante de alterações rastreadas no submódulo. Não descarte
mudanças automaticamente; revise a origem antes de continuar.

### Artefato ausente

Preserve toda a saída do Ant e investigue o primeiro erro. Não copie JARs de outro
projeto ou build para contornar a falha.
