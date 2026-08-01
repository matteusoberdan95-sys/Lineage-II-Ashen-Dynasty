# Relatório da primeira execução local

## Resultado

**Aprovado para a baseline local, sem cliente.**

Em 1 de agosto de 2026, Login Server e Game Server iniciaram, conectaram ao MariaDB,
registraram o Game Server e permaneceram acessíveis somente por loopback. Após
bloquear novos registros, ambos foram parados, reiniciados e validados novamente.

## Build executado

| Item | Valor |
|---|---|
| Source | `e4d1d8336ed28fc0916e7caad3ca752d06169eac` |
| Patch | `0001-bind-gameserver-to-configured-host.patch` |
| Fontes compiladas | 1.609 |
| Tempo Ant | 30 segundos |
| Resultado | `BUILD SUCCESSFUL` |
| SHA-256 do ZIP | `d82c0ed4f3b2a653247c3ad868fe0abe35c1a9b923095e094a169e8f09042463` |

O bytecode foi inspecionado e chama `InetSocketAddress(String, int)` com
`GAMESERVER_HOSTNAME`.

## Evidências de execução

| Critério | Resultado |
|---|---|
| Pool JDBC Login | conexão válida com `l2server` |
| Pool JDBC Game | conexão válida com `l2server` |
| Login cliente | `127.0.0.1:2106` |
| Canal Login/Game | `127.0.0.1:9014` |
| Game cliente | `127.0.0.1:7777` |
| Registro | ID 1, Bartz, HexID local persistido |
| Skills | 29.861 templates |
| Itens | 9.208 |
| NPCs | 6.519 |
| Spawns | 34.121 |
| Startup Game | 17–18 segundos |
| Tabelas | 100 |
| Conexões Java externas | nenhuma |
| Marcadores `SEVERE`, `FATAL` ou `Exception` | nenhum |

`ipconfig.xml` foi reconhecido antes do carregamento do banco, impedindo a descoberta
automática de IP externo. O diretório de scripts `custom` foi excluído, elevando a
lista de exclusões para 401 arquivos.

## Registro seguro

O SQL upstream trazia um registro ID 2 e a distribuição trazia o HexID
correspondente. Ambos são públicos e foram removidos antes da execução. O primeiro
startup gerou material novo para o ID 1. Depois:

1. `AcceptNewGameServer` foi alterado para `False`;
2. Game e Login foram reiniciados;
3. o Game autenticou novamente com o HexID persistido;
4. o verificador confirmou o único registro esperado.

Nenhum valor de HexID ou senha foi registrado neste relatório.

## Problemas encontrados e corrigidos

### Bind 7777 ignorava a configuração

O código upstream lia `GameserverHostname`, mas abria um socket wildcard. Foi aplicado
o patch mínimo descrito na ADR-003 e confirmado o bind real em loopback.

### Substituição de senha vazia consumia quebra de linha

A primeira geração de runtime usou `\s*` ao preencher uma propriedade vazia e colocou
a senha na linha seguinte. O Login não abriu portas e foi encerrado pelo timeout.
A expressão foi restringida a espaços e tabulações; o runtime foi apagado e recriado.
As validações seguintes confirmaram uma única propriedade com o tamanho esperado,
sem imprimir o valor.

### Detecção consultava o stream errado

O logger Java escreve no stream de erro por padrão. O Game já havia carregado e
registrado corretamente, mas o script aguardava a mensagem no stream de saída. A
detecção passou a consultar ambos os streams e o processo foi reiniciado.

## Avisos não bloqueantes

- Geodata possui zero regiões e pathfinding está desabilitado, como distribuído.
- O script base `Core` referencia o NPC `899099`, ausente nos dados carregados. Foram
  emitidos três avisos, sem erro crítico ou falha de startup.
- A parada no Windows é forçada e serve somente ao ambiente local sem jogadores.
- Nenhum cliente Interlude foi conectado nesta sprint.

## Estado final

MariaDB, Login Server e Game Server ficaram em execução local ao concluir a
validação. `verify-local-servers.ps1` aprovou rede, banco, registro, conteúdo e logs.
