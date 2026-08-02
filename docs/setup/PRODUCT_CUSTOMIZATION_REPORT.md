# Relatório — primeira customização de produto (Sprint 9)

**Data:** 2026-08-01  
**Status:** Aplicada localmente sob ADR-004.

## Escopo autorizado

Somente identidade local:

| Item | Valor |
|---|---|
| Nome do servidor ID 1 | `Ashen Dynasty` (antes `Bartz`) |
| Notícia de entrada | `ShowServerNews = True` |
| HTML da notícia | `servnews.htm` com tagline Ashen Dynasty |

Fora de escopo: rates, drops, itens, skills, classes, enchant, rede externa e
alterações no submódulo.

## Arquivos versionados

- `docs/adr/ADR-004-PRODUCT-CUSTOMIZATION.md`
- `infrastructure/customization/login/data/servername.xml`
- `infrastructure/customization/game/data/html/servnews.htm`
- `infrastructure/scripts/apply-local-product-customization.ps1`
- `infrastructure/scripts/verify-local-product-customization.ps1`

O prepare de runtime chama o apply automaticamente após a configuração local.

## Aplicação no runtime existente

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command `
  '& ".\infrastructure\scripts\stop-local-stack.ps1" -Confirm:$false'

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\apply-local-product-customization.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\start-login-server.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\start-game-server.ps1

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-product-customization.ps1
```

## Validação executada

| Checagem | Resultado |
|---|---|
| `verify-local-product-customization.ps1` | OK |
| `verify-local-servers.ps1` | OK — listeners loopback, registro ID 1 travado |
| Submódulo | limpo |
| Login stderr | `Updated Gameserver [1] Ashen Dynasty IP's` |
| Game log | `Registered on login as Server 1: Ashen Dynasty` |
| `ShowServerNews` | `True` |
| Rates/itens/skills | sem alteração nesta sprint |
