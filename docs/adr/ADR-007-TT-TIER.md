# ADR-007 — Tier T3 (TT) como entrada de endgame

- **Status:** Aceita
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

A ADR-006 fixou a escada T0–T6 e deixou o **T3 (TT)** como próxima ADR de conteúdo.
Sem definição de peças, origem e tempo, qualquer implementação futura vira inventário
aleatório.

Nesta etapa o servidor continua com teto jogável **T2 retail**. Esta ADR desenha o
TT; **não** cria XML, NPC, raid nem altera drops.

## Decisão

### Nome e papel

- **Nome de produto:** Ashen TT (abreviado **TT**).
- **Significado:** Tier de Transição — primeira camada **custom** após S-grade
  Interlude, porta de entrada do endgame Ashen Dynasty.
- **Posição:** acima de T2 (S retail), abaixo de T4 (Draconic custom).

### Famílias de set

Três linhas de armor (padrão Interlude), todas equivalentes em poder de tier:

| Linha | Uso | Peças obrigatórias |
|---|---|---|
| TT Heavy | tanks / melee heavy | Helmet, Breastplate, Gaiters, Gauntlets, Boots (+ Shield opcional) |
| TT Light | dagger / archer / light melee | Helmet, Leather Armor, Leggings, Gloves, Boots |
| TT Robe | mystic | Circlet/Helmet, Tunic, Stockings, Gloves, Shoes |

Bônus de set: 2 / 3 / 5 peças (números exatos na ADR de implementação).

### Armas TT

Uma arma TT por família de combate Interlude relevante:

| Família | Exemplos de papel |
|---|---|
| Sword (1H) | duelista / tank sidearm |
| Two-hand sword | fury / warlord path |
| Dual swords | duals |
| Dagger | dagger |
| Bow | archer |
| Blunt / two-hand blunt | orc / temple |
| Polearm | warlord |
| Fist | tyrant |
| Staff / magic blunt | mystic |

Arma TT sozinha não substitui set completo: o marco de “entrou no endgame” é
**set 5 peças + arma TT** (ou equivalente light/robe).

### Poder relativo (política, não números finais)

| Comparado a | Política |
|---|---|
| Melhor S-grade retail | claramente superior (jogador sente o upgrade) |
| Draconic custom (T4) | claramente inferior |
| Enchant | permanece no teto retail até ADR de enchant; **sem +30 no TT** |

Stats exatos (P.Def, P.Atk, skills de set) ficam para a ADR/implementação de item,
com planilha de balanceamento. Esta ADR só trava o envelope.

### Obtenção (economia)

Nenhuma peça TT em loja, doação ou GM shop público.

| Fonte | Papel | Notas |
|---|---|---|
| Raid boss custom “Guardião TT” (nome final depois) | principal — peças de armor | party, CD semanal ou janela controlada |
| Mini-boss / world boss secundário | armas TT | mais raro que armor |
| Quest de transição Ashen (cadeia pós-S) | 1–2 peças ou token de craft | não entrega set completo |
| Craft com token de raid | alternativa | evita dependência só de RNG de peça |
| Evento | no máximo **um** token cosmético/apoio | nunca única fonte do set |

Tempo alvo (jogador dedicado, já em T2, XP 500x, drop custom ainda a calibrar):
**4–8 semanas** para o primeiro set TT completo + arma.
Isso alinha com “+1–2 meses após T2” da ADR-006.

### IDs reservados (ainda não alocados no datapack)

Faixa **9300–9399** reservada no projeto Ashen Dynasty para T3:

| Subfaixa | Uso |
|---|---|
| 9300–9329 | TT Heavy |
| 9330–9359 | TT Light |
| 9360–9389 | TT Robe |
| 9390–9399 | Armas TT e tokens |

Nenhum ID dessa faixa pode ser usado por outro tier. Alocação nome↔ID ocorre só
na sprint de implementação.

### Implementação

Autorizada somente em sprint futura que entregue, no mínimo:

1. overlays de item fora do submódulo (ADR-004);
2. NPC/raid/quest versionados;
3. tabela de stats e chance de drop;
4. teste local GM + relatório econômico curto;
5. sem rede externa.

## Alternativas rejeitadas

- **TT = reskin de Majestic/S:** não cria endgame, só confunde.
- **TT só por craft de adena:** inflaciona e pula o mundo.
- **Entregar TT inteiro em quest única:** quebra “gear lento”.
- **Implementar XML já nesta sprint:** prematuro sem planilha de stats.

## Consequências

- ADR-006 T3 deixa de ser “futura” e passa a “especificada / não implementada”.
- Teto jogável **continua T2** até a sprint de implementação do TT.
- T4–T6 seguem bloqueados.

## Validação desta sprint

- ADR-007 e `docs/design/TT_TIER.md` publicados.
- Escada de gear atualizada.
- Zero alteração de datapack de item / drop.
- Submódulo limpo.
