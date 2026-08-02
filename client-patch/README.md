# Client patch

O cliente Lineage 2 Interlude é proprietário e não faz parte deste repositório.

Não adicione aqui:

- cliente completo ou pasta `system`;
- executáveis, DLLs ou launchers de terceiros;
- arquivos `.dat`, texturas, animações, sons ou mapas proprietários;
- credenciais de conta;
- downloads obtidos de origem desconhecida.

## Estado atual (Sprint 24 / ADR-011)

Há um **patch local de nomes/ícones** Ashen, reproduzível por scripts:

- manifesto versionável:
  `infrastructure/customization/ashen_client/ashen_client_manifest.csv`
- apply/verify:
  `infrastructure/scripts/apply-local-client-patch.ps1`
  `infrastructure/scripts/verify-local-client-patch.ps1`

O patch é aplicado somente em `D:\L2-ASHEN-DYNASTY` (fora do Git), com backup em
`.ashen-local/`. Detalhes:
[`docs/setup/CLIENT_PATCH_IMPLEMENTATION_REPORT.md`](../docs/setup/CLIENT_PATCH_IMPLEMENTATION_REPORT.md).

A configuração de endpoint e contas continua em:

- [`docs/setup/CLIENT_SETUP.md`](../docs/setup/CLIENT_SETUP.md)
- [`docs/CLIENT_COMPATIBILITY.md`](../docs/CLIENT_COMPATIBILITY.md)
