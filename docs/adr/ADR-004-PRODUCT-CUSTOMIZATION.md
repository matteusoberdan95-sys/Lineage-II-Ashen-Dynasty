# ADR-004 — Customizações de produto Ashen Dynasty

- **Status:** Aceita
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

A baseline Interlude está estável. A visão do Ashen Dynasty exige, no futuro, mudanças
de identidade e gameplay. O submódulo upstream deve permanecer comparável ao commit
auditado. ADR-003 já cobre patches mínimos de segurança; falta a política para
customizações de produto.

## Decisão

Customizações de produto serão versionadas fora do submódulo, em
`infrastructure/customization/`, e aplicadas ao runtime descartável.

Regras:

1. O submódulo `server/source/l2jmobius-upstream` permanece limpo.
2. Overlays de datapack/config ficam em `infrastructure/customization/{login,game}/...`
   espelhando o caminho relativo do runtime.
3. Alterações de código Java de produto, quando inevitáveis, usam patches em
   `server/patches/` e entram no build local, com ADR ou relatório próprio.
4. Toda customização registra motivação, arquivos, validação e impacto no changelog.
5. Rates, economia, itens, skills, enchant e sistemas da visão futura exigem ADR
   específica antes da implementação.
6. Nenhuma customização abre bind público, firewall ou roteador.

## Primeira customização autorizada

Somente identidade local:

- renomear o servidor ID 1 de `Bartz` para `Ashen Dynasty`;
- habilitar notícia de entrada com texto Ashen Dynasty.

Sem alteração de rates, drops, classes, inventário inicial ou combate.

## Alternativas rejeitadas

- **Editar o submódulo diretamente:** perde a baseline auditável.
- **Fork imediato:** custo de governança alto antes de existir volume de produto.
- **Começar por rates/itens:** viola a visão atual e antecipa economia sem métricas.

## Consequências

- Runtime deixa de ser byte a byte idêntico ao upstream dist.
- Recriar runtime exige reaplicar overlays.
- Atualizações upstream continuam revisáveis por commit.
- Customizações futuras ficam isoladas e reversíveis.

## Validação

- `git -C server/source/l2jmobius-upstream status --short` vazio.
- Runtime login carrega nome `Ashen Dynasty` para o ID 1.
- `ShowServerNews = True` e `servnews.htm` Ashen Dynasty presentes.
- Nenhuma mudança de rate/item/skill nesta ADR.
