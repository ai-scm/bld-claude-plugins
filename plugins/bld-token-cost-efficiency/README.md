# bld-token-cost-efficiency

Plugin de eficiencia de tokens para Claude Code.

## Hooks

| Hook | Evento | Ahorro estimado |
|------|--------|-----------------|
| log-filter.sh | PreToolUse (Bash: test/build/lint) | 80-92% |
| read-once.sh | PreToolUse (Read: archivos >1KB) | 40-80% |
| session-context.sh | SessionStart | Inyecta best practices + RTK nudge |

## Skills

| Skill | Trigger |
|-------|---------|
| token-audit | `/token-audit`, preguntas sobre tokens/costo |
| opusplan | `/opusplan`, decisiones arquitectónicas |
| rtk-setup | `/rtk-setup`, "install rtk", "configure rtk" |
| context-diet | `/context-diet`, "optimize context", "context too large" |
| session-hygiene | `/session-hygiene`, "session tips", "session health" |

## Dependencias

- `jq` — requerido por los hooks (graceful no-op si falta)
- `rtk` — opcional, instala con `/rtk-setup` para tracking completo de tokens
