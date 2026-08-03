# ACTIVE SOURCE REPORT

Data da coleta: 2026-08-03
Escopo: identificação da source ativa e fronteiras de alteração

## Source ativa
- Nome: L2J_Mobius_CT_0_Interlude
- Origem: submódulo Git
- Caminho: server/source/l2jmobius-upstream
- URL do submódulo: https://gitlab.com/MobiusDevelopment/L2J_Mobius.git
- Status: ENCONTRADO

## Evidências
- .gitmodules aponta submódulo em server/source/l2jmobius-upstream
- README raiz descreve CT_0 Interlude e commit fixado
- runtime local aponta sourceCommit em local-runtime.json

## Build system
- Tecnologia: Apache Ant
- Evidência: build.xml no módulo Interlude
- Java: JDK 25 (java/javac 25.0.4)

## Fronteiras técnicas
- Submódulo upstream deve permanecer como referência controlada.
- Runtime local é materializado em server/runtime/interlude e pode ser recriado.
- Customizações são aplicadas por overlays/scripts de infrastructure/scripts.

## Riscos para rebuild
1. Runtime atual pode conter mistura de oficial + custom em cadeia automática.
2. Há muitos scripts de custom visual e de itens com nomenclatura semelhante (Dynarty/Dynasty/DK/Draconic/TT).
3. Há alterações locais não commitadas no repositório raiz.

## Decisão para as próximas fases
- Preservar projeto atual sem deleção: APROVADO
- Congelar snapshot recuperável antes de limpeza: PENDENTE
- Criar cópia rebuild separada e auditável: PENDENTE

## Status da identificação
- Source identificada: APROVADO
- Build identificado: APROVADO
- Runtime identificado: APROVADO
- Dependências críticas identificadas: APROVADO
