# Servidor

Esta área separa a source Java auditada do runtime local.

```text
server/
├── source/
│   └── l2jmobius-upstream/  # submódulo fixado
└── runtime/                 # gerado localmente; ignorado pelo Git
```

Login Server, Game Server, datapack, ferramentas e build Ant já pertencem ao módulo
`L2J_Mobius_CT_0_Interlude` no submódulo. Não crie cópias paralelas na raiz.

Até uma decisão específica sobre customizações, trate o submódulo como somente
leitura. Runtime, logs, HexID, artefatos de build e configurações locais não devem ser
commitados.
