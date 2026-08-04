# Content Playtest Report

Date: 2026-08-03 21:54:53
User: mober
Repo: D:\Lineage-II-Ashen-Dynasty\l2-ashen-dynasty-rebuild

## Automated checks

| Check | Script | Status | Exit code |
|---|---|---|---|
| Local servers | verify-local-servers.ps1 | PASS | 0 |
| Product customization | verify-local-product-customization.ps1 | PASS | 0 |
| Rates ADR-005 | verify-local-rates.ps1 | PASS | 0 |
| GM admin account | verify-local-admin.ps1 | PASS | 0 |
| World checklist | verify-world-checklist.ps1 | PASS | 0 |
| TT content | verify-local-tt-content.ps1 | PASS | 0 |
| Draconic content | verify-local-draconic-content.ps1 | PASS | 0 |
| DK/Phoenix content | verify-local-dk-phoenix-content.ps1 | PASS | 0 |
| Dynarty content | verify-local-dynarty-content.ps1 | PASS | 0 |
| Ashen craft | verify-local-ashen-craft.ps1 | PASS | 0 |
| Ashen quest | verify-local-ashen-quest.ps1 | PASS | 0 |
| Ashen progression hub | verify-local-ashen-progression.ps1 | PASS | 0 |

Summary: PASS=12 FAIL=0 SKIP=0

## Manual in-game checklist

- [ ] Login with `ashen_test` and enter world without error.
- [ ] Kill 2-3 mobs and confirm XP/SP pace (500x feel) and non-inflated drops.
- [ ] Open Ashen GM Shop and buy one item from each grade block (NG, D, C, B, A, S).
- [ ] Equip one TT set/weapon (T3) and relog.
- [ ] Equip one Draconic set/weapon (T4) and relog.
- [ ] Equip one DK/Phoenix set/weapon (T5) and relog.
- [ ] Equip one Dynarty set/weapon (T6) and relog.
- [ ] Run Q900 -> Q901 -> Q902 bridge flow and confirm rewards.
- [ ] Validate one craft recipe from TT/Draconic/DK/Dynarty tiers.
- [ ] Confirm only one GM Shop NPC is present in hub.

## Raw outputs

### Local servers

```text
Local server verification passed.
Listeners: 127.0.0.1:2106, 127.0.0.1:9014, 127.0.0.1:7777
Database: valid l2server connection, 100 tables
Registration: server ID 1, enrollment locked
External Java connections: none
Custom script directory: excluded
```

### Product customization

```text
fatal: not a git repository: (NULL)
Product customization verification passed.
Server ID 1: Ashen Dynasty
ShowServerNews: True
servnews.htm: Ashen Dynasty identity present
Submodule: clean
```

### Rates ADR-005

```text
fatal: not a git repository: (NULL)
Local rates verification passed (ADR-005).
XP/SP: 500 | Drop chance/amount: 1 | Adena amount: 10
Submodule: clean
```

### GM admin account

```text
Local admin verification passed.
Account: ashen_admin accessLevel=100
Character: ASHENADM accesslevel=100 (Master)
Playtest ashen_test / NEIDE157 remain non-GM.
```

### World checklist

```text
World checklist passed.
Account: ashen_test	0	127.0.0.1	1
Character: NEIDE157	2	0	0	-84516	241220	-3755
Items: 6
Online state check: Any (actual=0)
Listeners: 127.0.0.1 only for 2106/7777/9014/3306
```

### TT content

```text
fatal: not a git repository: (NULL)
Ashen TT content verification passed.
Runtime contains TT items/sets/NPCs/spawns; submodule clean.
```

### Draconic content

```text
fatal: not a git repository: (NULL)
Ashen Draconic content verification passed.
Runtime contains Draconic items/sets/NPCs/spawns; submodule clean.
```

### DK/Phoenix content

```text
fatal: not a git repository: (NULL)
Ashen DK/Phoenix content verification passed.
Runtime contains DK/Phoenix items/sets/NPCs/spawns; submodule clean.
```

### Dynarty content

```text
fatal: not a git repository: (NULL)
Ashen Dynarty content verification passed.
Items/sets/raids/spawns + Dynarty-only +30 enchant merge present; submodule clean.
```

### Ashen craft

```text
fatal: not a git repository: (NULL)
Ashen craft verification passed.
Scrolls 9500-9594 (skip 9569-9571) and Recipes.xml merge present; submodule clean.
```

### Ashen quest

```text
fatal: not a git repository: (NULL)
Ashen quest verification passed.
Q900/Q901/Q902 scripts/NPC/spawn present; custom scripts still excluded; submodule clean.
```

### Ashen progression hub

```text
Ashen progression verification passed (36 multisells, 36 root mirrors).
```

