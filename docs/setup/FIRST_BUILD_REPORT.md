# Relatório do primeiro build

- **Data:** 2026-08-01
- **Sprint:** 3 — Build limpo da source
- **Resultado:** aprovado para compilação e empacotamento
- **Source:** L2JMobius `L2J_Mobius_CT_0_Interlude`
- **Commit:** `e4d1d8336ed28fc0916e7caad3ca752d06169eac`

## Ambiente

| Item | Valor |
|---|---|
| Sistema | Windows 11 Pro x64 |
| Java | BellSoft Liberica OpenJDK 25.0.4+9 LTS |
| `javac` | 25.0.4 |
| Ant | 1.10.17, compilado em 2026-04-06 |
| Encoding | UTF-8 |
| Source/target | Java 25 |

## Sistema de build

O módulo usa exclusivamente Apache Ant. Não foram encontrados:

- `pom.xml`;
- `build.gradle`;
- Maven Wrapper;
- Gradle Wrapper;
- target Ant de testes;
- referências a JUnit ou TestNG.

Targets declarados:

```text
checkRequirements
init
compile
jar
adding-core
adding-datapack
adding-readme
cleanup
```

O target padrão é `cleanup`. Apesar do nome, ele executa toda a cadeia de compilação e
empacotamento antes de remover apenas a pasta intermediária `dist`.

## Comando executado

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\build-server.ps1
```

O script redirecionou a propriedade Ant `build` para:

```text
server/runtime/build
```

Assim, nenhum artefato foi gravado dentro do submódulo.

## Primeira execução

| Métrica | Resultado |
|---|---|
| Arquivos Java compilados | 1.609 |
| Tempo Ant | 36 segundos |
| Tempo medido pelo script | 36,576 segundos |
| Resultado | `BUILD SUCCESSFUL` |
| Tamanho do ZIP | 20.075.637 bytes |
| SHA-256 | `a0ff7b64d082a17b670ec22bab1f3de6555fdfc712f75f648083a7fa30ce4e3f` |

## Segunda execução limpa

O script removeu somente `server/runtime/build` e repetiu toda a cadeia:

| Métrica | Resultado |
|---|---|
| Arquivos Java compilados | 1.609 |
| Tempo Ant | 32 segundos |
| Tempo medido pelo script | 32,519 segundos |
| Resultado | `BUILD SUCCESSFUL` |
| Tamanho do ZIP | 20.075.587 bytes |
| SHA-256 | `b9ad16635d0a18357b848c8b95a0734c9dbd00dfbb33443696b9f88816fcd5bc` |

O processo é repetível, mas o pacote não é bit a bit determinístico. O `build.xml`
insere `Build-Date` nos manifests e o ZIP preserva timestamps de entradas. Por isso,
tamanho e hash podem variar sem mudança de source. O SHA-256 serve para identificar
uma execução específica, não como hash universal dessa revisão.

## Validação final dos scripts

Após adicionar a verificação do commit upstream e a proteção contra junctions no
script de limpeza, um terceiro clean build validou a versão final:

| Métrica | Resultado |
|---|---|
| Arquivos Java compilados | 1.609 |
| Tempo Ant | 1 minuto e 34 segundos |
| Tempo medido pelo script | 1 minuto e 35,252 segundos |
| Resultado | `BUILD SUCCESSFUL` |
| Tamanho do ZIP | 20.076.664 bytes |
| SHA-256 | `8ecde4c9f2c546793e5e20f8a12e6fa45411916524d00d9946992298ba1d4acf` |

O tempo variou entre 32 e 94 segundos nas três execuções. Não houve medição suficiente
para atribuir causa; carga do sistema e sincronização do OneDrive são fatores a
observar em builds futuros.

## Artefatos

Artefato final:

```text
server/runtime/build/L2J_Mobius_CT_0_Interlude.zip
```

Conteúdo obrigatório confirmado:

```text
libs/LoginServer.jar
libs/GameServer.jar
db_installer/DatabaseInstaller.jar
```

O ZIP também inclui datapack, bibliotecas runtime e `readme.txt`, conforme os targets
upstream.

## Warnings

### Compilação

Nenhum warning ou erro foi emitido pelo `javac` nas duas execuções.

### Testes

Não há testes automatizados disponíveis nesse módulo. O script
`run-tests.ps1` retornou:

```text
NO_AUTOMATED_TESTS_AVAILABLE
```

Isso é uma lacuna de cobertura e não deve ser interpretado como validação funcional.
Login, Game Server, banco, protocolo e datapack ainda não foram executados.

### Reprodutibilidade binária

A presença de timestamps no manifest e no ZIP impede hashes idênticos entre builds.
Esse achado é baixo para a baseline local, mas deverá ser revisitado se houver
distribuição reproduzível ou cadeia de suprimentos assinada.

## Problemas encontrados

### Ferramentas ausentes

JDK e Ant não estavam instalados.

**Resolução:** Liberica Full JDK 25.0.4+9 foi instalado pelo WinGet, e Ant 1.10.17 foi
baixado do domínio oficial Apache após validação SHA-512.

### Variável reservada no instalador do Ant

A primeira automação usou `$home`, que no PowerShell conflita com `$HOME`, variável
somente leitura.

**Resolução:** a variável local foi renomeada para `$antHome`. A falha ocorreu antes
do download e não deixou instalação parcial.

### Expansão do `PATH`

O primeiro valor `%ANT_HOME%\bin` não foi expandido no processo de validação.

**Resolução:** o `PATH` de usuário passou a armazenar o caminho absoluto do diretório
`bin`. `Get-Command ant` confirmou o executável correto.

## Não executado

- Login Server;
- Game Server;
- Database Installer;
- scripts SQL;
- cliente;
- configuração de rede;
- banco de dados;
- testes funcionais.

Essas ações pertencem às próximas sprints e continuam sujeitas aos bloqueios de
segurança documentados.

## Conclusão

O critério de build limpo foi atendido. A source compilou três vezes sem alterações,
os três JARs esperados foram empacotados e o submódulo permaneceu limpo.
