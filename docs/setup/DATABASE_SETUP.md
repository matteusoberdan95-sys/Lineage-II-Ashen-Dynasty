# Configuração do banco local

## Estado validado

| Item | Valor |
|---|---|
| Servidor | MariaDB 11.4.3 LTS x64 |
| Serviço Windows | `MariaDB`, automático |
| Endpoint | `127.0.0.1:3306` |
| Schema | `l2jmobiusinterlude` |
| Usuário da aplicação | `l2server@127.0.0.1` |
| Tabelas | 100 |
| Engine | InnoDB em todas as tabelas |
| Timezone | `SYSTEM`, resolvido como `America/Sao_Paulo` |
| Page size | 16 KiB |
| Buffer pool | 3.203.399.680 bytes |

Login Server e Game Server compartilham um único schema na source adotada. Não foram
criados bancos artificiais `l2_login` e `l2_game`.

## Instalação

MariaDB 11.4.3 foi instalado pelo pacote oficial `MariaDB.Server` do WinGet:

```powershell
winget install `
  --id MariaDB.Server `
  --version 11.4.3.0 `
  --exact `
  --source winget `
  --interactive
```

Configuração local efetiva:

```ini
[mysqld]
bind-address=127.0.0.1
port=3306
```

O instalador inicialmente vinculou `0.0.0.0:3306`. Isso foi corrigido antes da
criação do schema. Um backup local do `my.ini` anterior foi preservado ao lado da
configuração do MariaDB.

## Credenciais

Existem duas identidades distintas:

- `root`: administração local, senha conhecida somente pelo proprietário;
- `l2server@127.0.0.1`: conta usada pelos scripts e, futuramente, pela aplicação.

A senha de `l2server`:

- foi gerada com RNG criptográfico;
- não foi exibida;
- não aparece em linha de comando;
- não foi gravada em SQL;
- foi protegida por DPAPI com `Export-Clixml`;
- está em `secrets/`, diretório ignorado pelo Git.

O arquivo DPAPI só pode ser descriptografado pelo mesmo usuário do Windows na mesma
máquina. Ele não substitui um cofre de segredos para ambientes externos.

Não use `root` no Login Server, Game Server, DBeaver ou scripts cotidianos.

## Bootstrap inicial

O comando executado foi:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\database\scripts\import-base-schema.ps1
```

O script:

1. exige MariaDB ativo somente em `127.0.0.1`;
2. confirma 4 SQLs de login e 96 de game;
3. confirma 100 tabelas esperadas;
4. solicita `root` em diálogo seguro;
5. recusa importar se o schema já contiver tabelas;
6. cria o schema com `utf8/utf8_unicode_ci`;
7. cria `l2server@127.0.0.1`;
8. concede privilégios somente em `l2jmobiusinterlude.*`;
9. importa os arquivos em ordem alfabética, como o instalador upstream;
10. compara as tabelas reais com o inventário auditado;
11. confirma os 27 índices standalone declarados;
12. confirma a identidade e os grants da aplicação.

O script não oferece reset automático. Uma reinstalação destrutiva exige backup,
revisão e autorização separada.

## Verificação

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\database\scripts\verify-local-database.ps1
```

Resultado esperado:

```text
Database verification passed.
Version: 11.4.x-MariaDB
Account: l2server@127.0.0.1
Schema: l2jmobiusinterlude
Tables: 100
Login tables: 4
Audited standalone indexes: 27
System schema access: denied as expected
```

O arquivo `database/scripts/verify-database.sql` contém consultas equivalentes sem
credenciais e pode ser usado em uma ferramenta gráfica.

## Serviço

Iniciar:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\start-database.ps1
```

Parar:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\stop-database.ps1
```

Os scripts solicitam UAC somente quando precisam alterar o estado do serviço. O start
também recusa listeners fora de `127.0.0.1`.

## Backup

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\backup-database.ps1
```

O backup:

- usa `l2server`, não `root`;
- usa `--single-transaction`;
- não bloqueia tabelas explicitamente;
- é compactado como `.sql.gz`;
- recebe SHA-256;
- fica em `database/backups/`, ignorado pelo Git.

O primeiro backup foi descompactado em memória e continha as 100 instruções
`CREATE TABLE` esperadas.

Restauração ainda não foi executada. Ela é destrutiva sobre um schema existente e
exigirá procedimento e autorização próprios.

## DBeaver

DBeaver é opcional e não substitui o servidor MariaDB. Não reutilize `root` nem
extraia a senha de `l2server` apenas para navegação.

Se uma interface gráfica for necessária, deverá ser criado futuramente um usuário
separado e somente leitura, também restrito a `127.0.0.1`.

## Compatibilidade de charset

Os SQLs upstream declaram:

- 44 tabelas em `utf8mb3_unicode_ci`;
- 56 tabelas em `latin1_general_ci`.

Essa mistura foi preservada para não alterar prematuramente a semântica da source.
Conversão para `utf8mb4` só poderá ocorrer após testes de protocolo, dados e índices.

## Próxima etapa

Na Sprint 5 serão geradas configurações locais de Login e Game Server usando:

```text
jdbc:mysql://127.0.0.1/l2jmobiusinterlude
Login = l2server
Password = fornecida no runtime a partir da credencial local protegida
```

Nenhuma configuração upstream será alterada diretamente.
