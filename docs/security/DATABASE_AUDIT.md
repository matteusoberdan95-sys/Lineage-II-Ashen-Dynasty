# Auditoria do banco de dados

- **Data:** 2026-08-01
- **Source:** L2JMobius `L2J_Mobius_CT_0_Interlude`
- **Commit:** `e4d1d8336ed28fc0916e7caad3ca752d06169eac`
- **Banco validado:** MariaDB 11.4.3 LTS
- **Escopo:** instalador Java, 100 SQLs upstream, configuração JDBC e instância local

## Resultado

O schema foi aprovado para a baseline local após isolamento dos riscos de usuário
`root`, exposição de rede e importação destrutiva.

Nenhum trigger, procedure, function, event, plugin, carga externa, arquivo externo,
comando de sistema, criação de usuário ou grant foi encontrado nos SQLs upstream.

## Inventário

| Item | Quantidade |
|---|---:|
| SQLs de Login Server | 4 |
| SQLs de Game Server | 96 |
| Tabelas criadas | 100 |
| SQLs com `DROP TABLE IF EXISTS` | 15 |
| Instruções de seed `INSERT`/`REPLACE` | 22 |
| Tabelas InnoDB após importação | 100 |
| Tabelas `utf8mb3_unicode_ci` | 44 |
| Tabelas `latin1_general_ci` | 56 |
| Foreign keys | 0 |

Seeds relevantes validados:

| Tabela | Linhas |
|---|---:|
| `announcements` | 2 |
| `castle` | 9 |
| `clanhall_siege_guards` | 729 |
| `castle_siege_guards` | 3.689 |
| `gameservers` | 1 |

## Fluxo upstream

`DatabaseInstaller.java`:

- cria `l2jmobiusinterlude` sem charset explícito;
- lista arquivos por pasta;
- ordena os nomes sem diferenciar maiúsculas;
- executa cada instrução terminada em ponto e vírgula;
- pode continuar após erro;
- no modo gráfico pode oferecer backup, `DROP DATABASE` e recriação;
- usa `root` com senha vazia como padrão de interface;
- imprime a instrução SQL completa quando ocorre erro.

O projeto não executou o JAR do Database Installer. Scripts próprios usam o cliente
oficial MariaDB, falham no primeiro erro e verificam o conjunto final de tabelas.

## Achados

### DBA-001 — Bind inicial em todas as interfaces

- **Severidade inicial:** alto
- **Evidência:** após a instalação, `netstat` mostrou `0.0.0.0:3306`.
- **Risco:** acesso pela rede local dependendo do firewall.
- **Remediação:** `bind-address=127.0.0.1` no `my.ini`; serviço reiniciado.
- **Validação:** único listener em `127.0.0.1:3306`.
- **Estado:** resolvido para o ambiente local.

### DBA-002 — Credenciais upstream usam root

- **Severidade inicial:** alto
- **Evidência:** `dist/login/config/Database.ini` e
  `dist/game/config/Database.ini` definem `Login = root` e senha vazia.
- **Risco:** comprometimento completo da instância.
- **Remediação:** criado `l2server@127.0.0.1` com acesso somente ao schema do jogo.
- **Validação:** leitura de `mysql.user` foi negada e não há `ALL PRIVILEGES ON *.*`.
- **Estado:** resolvido nos scripts; configuração runtime ainda pertence à Sprint 5.

### DBA-003 — Importação pode apagar tabelas

- **Severidade:** alto
- **Evidência:** 15 SQLs contêm `DROP TABLE IF EXISTS`.
- **Risco:** reimportar sobre um banco em uso apaga dados de conta, personagem ou
  estado de jogo nas tabelas afetadas.
- **Controle:** bootstrap recusa schema com qualquer tabela e não oferece reset
  automático.
- **Estado:** mitigado.

### DBA-004 — Instalador pode apagar o schema

- **Severidade:** alto
- **Evidência:** o modo gráfico executa `DROP DATABASE` após confirmação.
- **Risco:** perda total de dados se backup falhar ou estiver incompleto.
- **Controle:** Database Installer não é usado; restauração/reset exigem autorização
  separada.
- **Estado:** isolado.

### DBA-005 — Tratamento de erros upstream permite estado parcial

- **Severidade:** médio
- **Evidência:** o console registra erro de statement e continua; a GUI oferece
  `Continue`.
- **Risco:** schema aparentemente instalado com tabelas ou seeds ausentes.
- **Controle:** o importador próprio interrompe no primeiro arquivo com falha e
  compara exatamente as 100 tabelas.
- **Estado:** mitigado.

### DBA-006 — Charsets mistos

- **Severidade:** médio
- **Evidência:** 44 tabelas usam UTF-8 legado e 56 usam Latin-1.
- **Risco:** conversão implícita, perda de caracteres e diferenças de comparação.
- **Controle:** declarações upstream preservadas; conexão usa UTF-8; nenhuma migração
  para `utf8mb4` nesta baseline.
- **Estado:** aceito com monitoramento.

### DBA-007 — Ausência de foreign keys

- **Severidade:** baixo
- **Evidência:** nenhum `FOREIGN KEY` ou `REFERENCES` nos 100 SQLs.
- **Risco:** integridade referencial depende integralmente da aplicação.
- **Benefício operacional:** arquivos podem ser importados alfabeticamente sem
  dependência de criação entre tabelas.
- **Estado:** aceito como comportamento upstream.

### DBA-008 — Segredo local protegido por DPAPI

- **Severidade residual:** baixo
- **Evidência:** credencial `l2server` exportada em `secrets/`, ignorada pelo Git.
- **Proteção:** conteúdo cifrado para usuário e máquina do Windows.
- **Risco:** o arquivo está sob uma árvore sincronizada pelo OneDrive e não é
  portável. Comprometimento da sessão Windows permite uso da credencial.
- **Estado:** aceitável apenas para desenvolvimento local.

### DBA-009 — Backup ainda não teve restore testado

- **Severidade:** médio
- **Evidência:** dump `.sql.gz` foi criado, descompactado e inspecionado, mas não
  restaurado em schema separado.
- **Risco:** backup válido sintaticamente pode falhar na restauração.
- **Estado:** pendente para uma sprint de recuperação; não bloqueia a baseline de
  importação local.

### DBA-010 — Compatibilidade runtime ainda não validada

- **Severidade:** médio
- **Evidência:** os 100 SQLs foram aceitos por MariaDB 11.4.3, mas Login Server e Game
  Server ainda não abriram pools JDBC com MySQL Connector/J 9.5.0.
- **Estado:** pendente para a Sprint 5.

## Configuração efetiva

```text
MariaDB: 11.4.3
Bind: 127.0.0.1:3306
Schema: l2jmobiusinterlude
Conta: l2server@127.0.0.1
Engine: InnoDB
Page size: 16384
Timezone: America/Sao_Paulo / SYSTEM
SQL mode: STRICT_TRANS_TABLES, ERROR_FOR_DIVISION_BY_ZERO,
          NO_AUTO_CREATE_USER, NO_ENGINE_SUBSTITUTION
```

## Validações executadas

- serviço Windows ativo e automático;
- bind local após restart;
- autenticação do usuário restrito;
- importação dos 100 SQLs sem erro;
- comparação das 100 tabelas reais com os SQLs;
- quatro tabelas de login presentes;
- grants sem privilégio global;
- acesso a `mysql.user` negado;
- stop/start do serviço;
- persistência do schema após restart;
- dump compactado;
- descompressão do dump em memória;
- 100 `CREATE TABLE` encontrados no backup;
- submódulo permaneceu limpo.

## Não executado

- Login Server;
- Game Server;
- conexão JDBC;
- restauração do backup;
- criação de conta ou personagem;
- migration;
- acesso remoto;
- DBeaver.
