# bld-token-cost-efficiency

Plugin de eficiencia de tokens para Claude Code.

## Quick Start

```
/bld-onboard
```

Configura todo en un solo paso: jq, RTK, análisis de contexto, health check y escaneo del repo.

## Hooks

| Hook | Evento | Ahorro estimado |
|------|--------|-----------------|
| log-filter.sh | PreToolUse (Bash: test/build/lint) | 80-92% |
| read-once.sh | PreToolUse (Read: archivos >1KB) | 40-80% |
| session-context.sh | SessionStart | Inyecta best practices + RTK nudge |

## Skills

| Skill | Trigger |
|-------|---------|
| bld-onboard | `/bld-onboard`, "setup plugin", "first time setup" |
| token-audit | `/token-audit`, preguntas sobre tokens/costo |
| token-scan | `/token-scan`, "scan config", "audit configuration" |
| context-diet | `/context-diet`, "optimize context", "context too large" |
| session-hygiene | `/session-hygiene`, "session tips", "session health" |
| opusplan | `/opusplan`, decisiones arquitectónicas |
| rtk-setup | `/rtk-setup`, "install rtk", "configure rtk" |
| git-commit | `/git-commit`, "commit changes", "create commit" |

## Dependencias

- `jq` — requerido por los hooks (graceful no-op si falta)
- `rtk` — opcional, instala con `/rtk-setup` para tracking completo de tokens
