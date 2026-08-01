# Banco de dados

Esta área receberá somente scripts e documentação controlados pelo Ashen Dynasty.

Estrutura prevista para a Sprint 4:

```text
database/
├── schema/
├── migrations/
├── seeds/
├── scripts/
└── backups/  # sempre ignorado pelo Git
```

A source escolhida usa um único schema conceitual, `l2jmobiusinterlude`. O nome será
validado antes de qualquer criação. A aplicação usará um usuário local dedicado, nunca
`root`.

Os scripts SQL upstream não foram copiados nem executados. Antes da importação serão
revisados quanto a operações destrutivas, grants, usuários, triggers, procedures,
events, cargas externas e caminhos absolutos.
