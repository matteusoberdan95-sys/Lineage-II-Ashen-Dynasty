# CUSTOM CONTENT AUDIT

Data: 2026-08-03
Escopo principal: l2-ashen-dynasty-rebuild

## Classificação macro
- OFICIAL_INTERLUDE: ENCONTRADO
- CUSTOM_APROVADO: NÃO VALIDADO
- CUSTOM_NÃO_VALIDADO: ENCONTRADO
- CUSTOM_QUEBRADO: ENCONTRADO
- CUSTOM_DUPLICADO: ENCONTRADO
- PLACEHOLDER: ENCONTRADO
- ARQUIVO_ÓRFÃO: ENCONTRADO
- DESCONHECIDO: ENCONTRADO

## Famílias identificadas
| Nome encontrado | Nome esperado | Tipo | Item ID | Skill ID | NPC ID | Multisell ID | Arquivo servidor | Arquivo cliente | Modelo | Textura | Ícone | Status | Conflitos | Dependências | Ação recomendada |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TT | TT | Tier custom | 9300-9399 | NÃO ENCONTRADO | 93000-93099 | 9302xxx | infrastructure/customization/game/data/stats/items/09300-09399.xml | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | EM QUARENTENA | CONFLITANTE com baseline oficial | scripts apply-local-tt-content.ps1 | manter em quarentena |
| Draconic | Draconic Custom | Tier custom | 9400-9499 | NÃO ENCONTRADO | 93100-93199 | 9302xxx | infrastructure/customization/game/data/stats/items/09400-09499.xml | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | EM QUARENTENA | pode conflitar com Draconic oficial | apply-local-draconic-content.ps1 | manter em quarentena |
| Dark Knight / DK | Dark Knight | Tier custom | 9500-9699 | NÃO ENCONTRADO | 93200-93299 | 9302xxx | infrastructure/customization/game/data/stats/items/09500-09599.xml | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | EM QUARENTENA | aliases múltiplos | apply-local-dk-phoenix-content.ps1 | manter em quarentena |
| Dynarty | Dynarty | Tier custom | 9700-9799 | NÃO ENCONTRADO | 93300-93399 | 9302xxx | infrastructure/customization/game/data/stats/items/09700-09799.xml | NÃO VALIDADO | AGUARDANDO TESTE VISUAL | AGUARDANDO TESTE VISUAL | NÃO VALIDADO | EM QUARENTENA | confusão com Dynasty/Dynart | apply-local-dynarty-content.ps1 | preservar referência e manter desativado |
| Dynasty | Dynarty | Nome conflitante | NÃO ENCONTRADO | NÃO ENCONTRADO | NÃO ENCONTRADO | NÃO ENCONTRADO | quest Q00902_AshenCrownOfDynasty | NÃO ENCONTRADO | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | DUPLICADO | conflito semântico com Dynarty | scripts de quest custom | manter em quarentena |
| Ashen progression hub | Hub oficial mínimo futuro | NPC/Multisell | NÃO ENCONTRADO | NÃO ENCONTRADO | NÃO ENCONTRADO | 9301xxx/9302xxx | infrastructure/customization/game/data/multisell/ashen_progression | NÃO ENCONTRADO | NÃO VALIDADO | NÃO VALIDADO | NÃO VALIDADO | EM QUARENTENA | contém referências custom | scripts apply-local-ashen-progression.ps1 | reconstruir na Fase 10 com itens oficiais |

## Evidências
- docs/rebuild/raw/current_hashes.tsv
- docs/rebuild/raw/rebuild_quarantine_hashes.tsv
- docs/rebuild/raw/runtime_cleanup_actions.tsv
