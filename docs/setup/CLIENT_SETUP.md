# Cliente Interlude local

## Cliente aprovado

| Item | Valor |
|---|---|
| Caminho | `D:\L2-ASHEN-DYNASTY` |
| Executável | `system\L2.exe` |
| Protocolo observado | `Lineage2Ver413` em `l2.ini` |
| Endpoint | `ServerAddr=127.0.0.1` |
| Porta de jogo no ini | `7777` |

O cliente proprietário permanece fora do Git. Não use o pack
`D:\Lineage II - Chronicle Interlude` (L2Agonia) nesta baseline.

## Preparação

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\configure-local-client.ps1
```

O script:

1. recusa pasta `System L2Agonia`, `CliExt.dll` e `entry.dll`;
2. garante o utilitário MIT `open-l2encdec` 1.3.9 em `server/runtime/tools`;
3. valida o SHA-256 do ZIP;
4. decodifica `l2.ini` protocolo 413;
5. exige ou define `ServerAddr=127.0.0.1`;
6. mantém backup em `D:\L2-ASHEN-DYNASTY\.ashen-local\`.

## Conta de teste

`AutoCreateAccounts` permanece `False`. Crie a conta local assim:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\create-local-account.ps1" -Confirm:$false'
```

Para ver usuário e senha no momento do login:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\show-local-account.ps1
```

A credencial fica em `secrets/local-test-account.clixml` (DPAPI, ignorado pelo Git).

## Fluxo de playtest

1. Suba MariaDB, Login e Game.
2. Configure o cliente e crie a conta.
3. Abra `D:\L2-ASHEN-DYNASTY\system\L2.exe` **como administrador** (UAC).
   Sem elevação, o processo pode encerrar imediatamente.
4. Entre com a conta local e crie um personagem.
5. Confirme persistência:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-client-persistence.ps1
```

## Limites

- Não versionar cliente, `.dat`, DLL ou launcher.
- Não apontar o cliente para IP público.
- Não reativar `AutoCreateAccounts` sem decisão explícita.
- GameGuard do cliente oficial pode exigir intervenção manual se bloquear a abertura.
