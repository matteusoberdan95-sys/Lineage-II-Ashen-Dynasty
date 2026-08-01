# Fluxo de desenvolvimento

## Princípios

- `main` representa o último estado estável e documentado.
- `develop` será criada somente com autorização quando o trabalho recorrente começar.
- Cada mudança terá uma branch curta com escopo único.
- A source L2JMobius limpa não será customizada diretamente.
- Commits serão pequenos, revisáveis e sem artefatos gerados.
- Decisões duradouras serão registradas em ADR.

## Branches

| Tipo | Convenção | Exemplo |
|---|---|---|
| Estável | `main` | baseline validada |
| Integração | `develop` | próxima versão em preparação |
| Funcionalidade | `feat/<descricao>` | `feat/local-db-bootstrap` |
| Correção | `fix/<descricao>` | `fix/login-bind-localhost` |
| Documentação | `docs/<descricao>` | `docs/first-build-report` |
| Manutenção | `chore/<descricao>` | `chore/update-ant-script` |

Branches e tags exigem autorização do proprietário. Há autorização permanente para
criar um commit e executar push normal da branch atual após cada sprint concluída e
validada.

## Commits

Usar Conventional Commits:

```text
feat: add local database bootstrap
fix: bind login server to localhost
docs: record first build result
test: cover account password encoding
chore: update pinned upstream revision
```

Antes de cada commit:

1. revisar `git status` e o diff completo;
2. confirmar que o submódulo aponta para o commit aprovado;
3. procurar credenciais, dados pessoais e arquivos proprietários;
4. executar as validações proporcionais à mudança;
5. atualizar documentação e changelog quando aplicável;
6. explicar conteúdo e impacto ao proprietário.

Ao concluir uma sprint, o agente deve executar automaticamente:

1. commit apenas dos arquivos pertencentes à sprint;
2. mensagem Conventional Commits em inglês e no imperativo;
3. push normal da branch atual para o remote configurado;
4. relatório com branch, hash, mensagem, validações e resultado.

Tipos aceitos: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `build`, `ci`,
`chore` e `revert`. Correções de bugs usam `fix`; `bug` não é um tipo do padrão.

Essa autorização não permite `force push`, ignorar hooks, incluir mudanças alheias ou
publicar quando houver conflito, segredo, falha de validação ou divergência remota.

## Source limpa e customizações

O diretório `server/source/l2jmobius-upstream` é uma referência upstream fixada. Até
que uma ADR defina fork ou estratégia de patches:

- não editar arquivos dentro do submódulo;
- não fazer commit no estado detached do submódulo;
- não copiar classes de outras crônicas ou projetos;
- não atualizar o ponteiro do submódulo sem auditoria do intervalo de commits;
- não colocar runtime, configuração local ou segredos no submódulo.

O primeiro custom exigirá uma decisão explícita sobre um fork próprio ou patches
reproduzíveis. A baseline upstream continuará identificável por commit.

## Atualização upstream

Uma atualização futura deve:

1. registrar commit atual e candidato;
2. revisar changelog e diff entre os commits;
3. repetir a varredura estática de segurança;
4. revisar dependências e licenças;
5. executar build e testes em branch isolada;
6. validar banco e protocolo;
7. atualizar ADR, auditoria e changelog;
8. mover o ponteiro apenas após aceite.

Executar `git submodule update --remote` sem commit-alvo revisado é proibido.

## Build e testes

- Build limpo é obrigatório após alteração Java relevante.
- Scripts devem falhar com exit code diferente de zero.
- Warnings importantes não podem ser ocultados.
- Resultados devem registrar versões de JDK e Ant, comando, duração e artefatos.
- Testes de banco exigem backup antes de migration.
- Testes manuais devem usar checklists versionadas.
- Nunca afirmar que algo foi testado sem executar a validação correspondente.

## Banco

- MariaDB local deve usar usuário dedicado, nunca `root` na aplicação.
- Migrations precisam ser revisadas antes de executar.
- Mudanças destrutivas exigem explicação, backup e autorização.
- Dumps, backups e senhas não são versionados.
- SQL upstream permanece intacto até existir uma estratégia de importação segura.

## Revisão

Toda revisão deve priorizar:

1. falhas funcionais e regressões;
2. exposição de rede, segredos e permissões;
3. perda ou corrupção de dados;
4. mistura de bases ou licenças;
5. desempenho e operação;
6. testes e documentação ausentes.

## Definition of Done

Uma mudança está pronta quando:

- escopo e riscos estão claros;
- diff foi revisado;
- validações necessárias passaram;
- documentos afetados estão atualizados;
- nenhum segredo ou artefato proibido entrou no Git;
- o submódulo está limpo;
- o proprietário recebeu um resumo antes de commit ou publicação.
