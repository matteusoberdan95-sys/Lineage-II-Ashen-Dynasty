# Compatibilidade do cliente

## Baseline validada

| Item | Valor |
|---|---|
| Cliente | `D:\L2-ASHEN-DYNASTY` |
| Crônica alvo | Interlude |
| Cabeçalho `l2.ini` | `Lineage2Ver413` |
| Protocolo do Game Server | `AllowedProtocolRevisions = 746` |
| Login | `127.0.0.1:2106` |
| Game | `127.0.0.1:7777` |

O cliente limpo não contém `System L2Agonia`, `CliExt.dll` nem `entry.dll`.

## Relação 413 × 746

`Lineage2Ver413` identifica a criptografia do arquivo `l2.ini`, não o número de
protocolo de rede. O Game Server L2JMobius Interlude aceita a revisão `746`, padrão
da crônica Interlude nesta source.

## Cliente rejeitado nesta etapa

`D:\Lineage II - Chronicle Interlude` é um pack L2Agonia e não faz parte da baseline.
Ele pode alterar protocolo, UI e binários além do Interlude limpo.

## Ferramenta de edição

Para ler/gravar `l2.ini` Ver413, o projeto usa
[open-l2encdec](https://github.com/ritsuwastaken/open-l2encdec) 1.3.9 (MIT), baixado
para `server/runtime/tools` com SHA-256 verificado. O binário não é versionado.

## Contas

O Login Server compara senha com SHA-1 em Base64, sem salt, compatível com o
`AccountManager` upstream. A criação automática permanece desabilitada; contas de
teste entram só pelos scripts locais.
