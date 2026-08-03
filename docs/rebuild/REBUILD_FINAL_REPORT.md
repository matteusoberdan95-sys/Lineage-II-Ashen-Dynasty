# REBUILD FINAL REPORT

Data: 2026-08-03
Projeto: Lineage II: Ashen Dynasty

## Resultado executivo
- `l2-ashen-dynasty-current`: ENCONTRADO
- `l2-ashen-dynasty-rebuild`: ENCONTRADO
- baseline rebuild com stack online (DB/Login/Game): APROVADO
- customizações de maior risco isoladas: EM QUARENTENA

## Fases executadas
- FASE 0 descoberta: APROVADO
- FASE 1 backup e congelamento: APROVADO
- FASE 2 criação da rebuild: APROVADO
- FASE 3 auditoria custom: APROVADO
- FASE 4 quarentena: APROVADO
- FASE 5 regra Dynarty: APROVADO
- FASE 6 catálogo de tiers: APROVADO
- FASE 7 registro de IDs: APROVADO
- FASE 8 baseline limpa: APROVADO COM RESSALVA
- FASE 9 playtest/persistência: APROVADO COM RESSALVA
- FASE 10 hub mínimo oficial: NÃO VALIDADO
- FASE 11 validação final: PARCIAL

## Ressalva técnica crítica
- Build (`build-local-server.ps1`) está BLOQUEADO por estado inconsistente da source local (submódulo aparece com grande volume de arquivos faltantes). A runtime da rebuild ainda foi validada com serviços em execução, mas o build reproduzível ficou pendente de saneamento da source.

## Correções aplicadas na baseline
- desativação de aplicação automática de customs no `prepare-local-runtime.ps1` da rebuild.
- quarentena de overlays custom e scripts de customização.
- remoção de multisells custom 93xxxx do runtime rebuild.
- restauração de `EnchantItemGroups.xml` oficial no runtime rebuild.

## Checklist solicitado
- [x] Projeto original preservado
- [x] Banco original preservado
- [x] Backup validado
- [x] Cópia rebuild criada
- [x] Source identificada
- [x] Customs auditados
- [x] Customs quebrados em quarentena
- [x] Dynarty oficial identificado
- [x] Duplicados Dynarty desativados
- [x] Equipamentos oficiais preservados
- [x] Registro de IDs criado
- [ ] Build aprovado
- [x] MariaDB conectado
- [x] Login Server iniciado
- [x] Game Server iniciado
- [x] Conta ADM preservada
- [ ] Comandos GM preservados (falta teste manual)
- [x] Cliente preparado
- [x] Checklist de login criado
- [x] Persistência preparada para validação
- [ ] Hub de testes mínimo criado
- [x] Nenhum novo set criado
- [x] Nenhuma nova arma criada

## Evidências principais
- docs/rebuild/ENVIRONMENT_DISCOVERY.md
- docs/rebuild/BACKUP_REPORT.md
- docs/rebuild/QUARANTINE_MANIFEST.md
- docs/rebuild/BASELINE_PLAYTEST.md
- docs/rebuild/PERSISTENCE_VALIDATION.md
- docs/rebuild/raw/current_hashes.tsv
- docs/rebuild/raw/rebuild_quarantine_hashes.tsv
- docs/rebuild/raw/runtime_cleanup_actions.tsv

## Atualização da próxima etapa
- Login em cliente com personagem ADM validado: APROVADO.
- Hub custom antigo não aparece mais no mundo após baseline limpa: APROVADO.
- Persistência SQL validada para personagem ASHENADM (posição e inventário): APROVADO.
- Pendente apenas validação manual de comandos GM e ciclo completo de relog com alteração de inventário em jogo.

## Confirmação do proprietário
- validação manual da baseline limpa em jogo: APROVADO
