# Banco de dados

Esta área contém scripts e documentação de banco controlados pelo Ashen Dynasty.

Estrutura:

```text
database/
├── schema/
├── migrations/
├── seeds/
├── scripts/
└── backups/  # sempre ignorado pelo Git
```

A source escolhida usa um único schema, `l2jmobiusinterlude`. Ele foi importado no
MariaDB 11.4.3 com 100 tabelas. A aplicação usa o usuário local
`l2server@127.0.0.1`, nunca `root`.

Os SQLs upstream não foram copiados ou modificados; o importador os lê diretamente do
submódulo fixado. A auditoria está em
[`docs/security/DATABASE_AUDIT.md`](../docs/security/DATABASE_AUDIT.md).

Comandos principais:

```powershell
.\database\scripts\verify-local-database.ps1
.\infrastructure\scripts\backup-database.ps1
```

`database/backups/` e `secrets/` são locais e ignorados pelo Git.
