# ENVIRONMENT DISCOVERY

Data da coleta: 2026-08-03
Escopo: FASE 0 (somente leitura)

## Raiz real do projeto
- Caminho detectado: D:\Lineage-II-Ashen-Dynasty
- Repositório Git: ENCONTRADO
- Branch atual: main
- Estado Git: ENCONTRADO (árvore com alterações locais pré-existentes)

## Comandos obrigatórios executados

### Git
- Comando: git status --short --branch
- Resultado: ENCONTRADO (main...origin/main com vários arquivos modificados/não rastreados)

- Comando: git branch --show-current
- Resultado: main

### Java
- Comando: java --version
- Resultado: openjdk 25.0.4 LTS

- Comando: javac --version
- Resultado: javac 25.0.4

### Docker
- Comando: docker --version
- Resultado: Docker version 29.6.1

- Comando: docker compose version
- Resultado: Docker Compose version v5.3.0

### MariaDB/MySQL CLI
- Comando: mariadb --version
- Resultado: NÃO ENCONTRADO no PATH

- Comando: mysql --version
- Resultado: NÃO ENCONTRADO no PATH

- Verificação adicional de binários:
  - C:\Program Files\MariaDB 11.4\bin\mariadb.exe --version: ENCONTRADO (11.4.3)
  - C:\Program Files\MariaDB 11.4\bin\mysql.exe --version: ENCONTRADO (11.4.3)
  - C:\Program Files\MariaDB 11.4\bin\mysqldump.exe --version: ENCONTRADO (11.4.3)

## Portas obrigatórias

### Porta 2106
- Estado: NÃO ENCONTRADO listener ativo no momento da coleta

### Porta 7777
- Estado: NÃO ENCONTRADO listener ativo no momento da coleta

### Porta 3306
- Estado: ENCONTRADO listener ativo em 127.0.0.1:3306
- Processo: mysqld

## Serviços atualmente em execução
- MariaDB local: ENCONTRADO (3306)
- Login Server: NÃO ENCONTRADO em execução no momento
- Game Server: NÃO ENCONTRADO em execução no momento

## Versão da source e build
- Source base: L2J_Mobius_CT_0_Interlude (submódulo)
- Commit de referência registrado no runtime: e4d1d8336ed28fc0916e7caad3ca752d06169eac
- Sistema de build: Apache Ant (build.xml no módulo Interlude)

## Observações de segurança
- Credenciais de banco existem em arquivos de runtime.
- Senhas não foram registradas neste documento.

## Status da fase
- FASE 0: APROVADO (descoberta inicial concluída sem alteração funcional)
