# Roteiro de regressão local

Use este roteiro após mudanças de runtime, rates ou customização. A parte
automatizada roda com `verify-local-regression.ps1`; a parte manual exige o
cliente Interlude.

## Pré-requisitos

- MariaDB, Login e Game em loopback
- Cliente `D:\L2-ASHEN-DYNASTY\system\L2.exe` (admin/UAC)
- Contas: `ashen_test` (playtest) e `ashen_admin` (GM)

## Automático

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\verify-local-regression.ps1
```

Cobre: listeners, identidade Ashen Dynasty, rates ADR-005, admin Master e
checklist do personagem `NEIDE157`.

## Automático — conteúdo (T3–T6, craft, quest e hub)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\infrastructure\scripts\run-local-content-playtest.ps1
```

Gera relatório PASS/FAIL em `docs/setup/playtest-reports/` com checklist manual
de validação em jogo (tiers TT/Draconic/DK/Dynarty, Q900–Q902, craft e hub).

## Manual — playtest (`ashen_test` / `NEIDE157`)

1. Login no servidor **Ashen Dynasty**.
2. Enter world; confirmar notícia de boas-vindas.
3. Relogin completo (sair ao character select e voltar).
4. Matar 2–3 mobs próximos; observar XP alto (500x) e drop sem sensação de 500x.
5. Morrer (ou quase) e retornar ao ponto/cidade sem soft-lock.
6. Falar com um NPC de Talking Island / cidade; abrir diálogo sem erro.
7. Logout limpo; `online=0` no banco (opcional: `wait-for-online-state.ps1`).

## Manual — GM (`ashen_admin` / `ASHENADM`)

Seguir [`GM_PLAYTEST_CHECKLIST.md`](GM_PLAYTEST_CHECKLIST.md).

## Critério de aprovação

- Automático: verde.
- Manual: proprietário marca os itens em [`SPRINT10_MANUAL_VALIDATION.md`](SPRINT10_MANUAL_VALIDATION.md).
