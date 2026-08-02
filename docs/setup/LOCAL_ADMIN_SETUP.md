# Conta e personagem admin local

## Escopo

Conta Master (`accessLevel = 100`) apenas para o servidor local Ashen Dynasty.
Permite painel GM, criação de itens, teleporte, status e demais comandos de dono
definidos em `AccessLevels.xml` / `AdminCommands.xml`.

Não abre rede externa. Não altera rates. A conta de playtest `ashen_test` /
`NEIDE157` permanece sem privilégios GM.

## Identidade padrão

| Item | Valor |
|---|---|
| Conta | `ashen_admin` |
| Personagem | `ASHENADM` |
| Access level | `100` (Master, `isGM=true`) |
| Credencial | `secrets/local-admin-account.clixml` (DPAPI, fora do Git) |

## Criar ou renovar

O Game Server precisa estar parado (alocação de IDs):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\stop-local-stack.ps1" -Confirm:$false'

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\create-local-admin.ps1" -Confirm:$false'
```

Para definir uma senha curta (recomendado: o cliente Interlude quase não aceita colar):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\create-local-admin.ps1" -Password "ashen1" -Confirm:$false'
```

Sem `-Password`, o script gera 8 caracteres aleatórios. Máximo prático no cliente: 16.

## Exibir senha e verificar

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\show-local-admin-account.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-admin.ps1
```

## Uso no cliente

1. Suba Login e Game.
2. Abra `D:\L2-ASHEN-DYNASTY\system\L2.exe` como administrador.
3. Entre com `ashen_admin` e a senha do script show.
4. Selecione `ASHENADM`.
5. No jogo, digite `//admin` para o painel principal.
6. Criação de itens: `//itemcreate` ou `//create_item <id> <qtd>`.
7. Teleporte e demais ferramentas ficam nos painéis GM (Alt+G / menus admin).

## Limites

- Usar somente contra `127.0.0.1`.
- Não versionar senha, HexID ou dumps com credenciais.
- Não promover `ashen_test` / `NEIDE157` a GM sem decisão explícita.
- `GMAudit` permanece habilitado no runtime local.
