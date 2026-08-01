# Infraestrutura local

Esta área receberá, nas sprints correspondentes:

```text
infrastructure/
├── docker/         # serviços auxiliares locais
├── scripts/        # automação PowerShell segura e repetível
├── configuration/  # templates versionados sem segredos
└── monitoring/     # observabilidade local
```

Scripts devem usar `Set-StrictMode`, validar caminhos, tratar erros, evitar senhas
fixas e retornar exit code apropriado.

Nenhuma automação poderá abrir firewall ou roteador, publicar portas, executar
deploy, acessar produção ou aplicar mudanças destrutivas sem autorização explícita.
