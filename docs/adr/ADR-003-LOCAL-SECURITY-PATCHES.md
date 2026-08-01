# ADR-003 — Patches de segurança para runtime local

- **Status:** Aceita
- **Data:** 2026-08-01
- **Decisores:** proprietário do projeto e arquitetura técnica

## Contexto

O módulo Interlude lê `GameserverHostname`, mas inicia a porta 7777 com
`new InetSocketAddress(port)`. Essa sobrecarga vincula o socket a todas as interfaces.
Portanto, a configuração `GameserverHostname = 127.0.0.1` não cumpre o isolamento
local sozinha.

O submódulo auditado deve permanecer limpo e fixado. Alterar firewall, aceitar o bind
global ou criar um fork antes da baseline também foi rejeitado.

## Decisão

Manter patches mínimos e revisáveis em `server/patches/`. O script
`build-local-server.ps1`:

1. confirma o commit e a limpeza do submódulo;
2. copia somente o módulo Interlude para `server/runtime`;
3. exige uma ocorrência exata do código vulnerável;
4. aplica a substituição equivalente ao patch versionado;
5. compila a cópia descartável;
6. registra commit, patch e SHA-256 do artefato.

O primeiro patch passa `ServerConfig.GAMESERVER_HOSTNAME` ao
`InetSocketAddress`. Nenhuma regra de gameplay é alterada.

## Alternativas rejeitadas

- **Somente editar `Server.ini`:** não altera o bind real.
- **Abrir ou alterar firewall:** contraria o isolamento por construção e as regras do
  projeto.
- **Modificar diretamente o submódulo:** perde a baseline limpa.
- **Criar fork agora:** adiciona governança remota antes de existir customização de
  produto.

## Consequências

- A distribuição local não é byte a byte igual ao build upstream.
- Todo patch exige motivo, diff pequeno, build limpo e validação dinâmica.
- O submódulo continua comparável ao commit auditado.
- O runtime pode ser recriado sem edição manual.

## Validação

- `git -C server/source/l2jmobius-upstream status --short` vazio.
- Bytecode chama `InetSocketAddress(String, int)`.
- Porta 7777 escuta somente em `127.0.0.1`.
- Nenhuma conexão externa pertence aos processos Java.

## Relações

- ADR-001 escolhe e fixa a source.
- ADR-002 separa source, runtime e configuração.
- Esta ADR não autoriza customizações de gameplay.
