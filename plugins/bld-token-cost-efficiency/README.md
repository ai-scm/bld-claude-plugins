# bld-token-cost-efficiency

Plugin de eficiencia de tokens para Claude Code.

## Hooks

| Hook | Matcher | Ahorro estimado |
|------|---------|-----------------|
| log-filter.sh | Bash (test/build/lint) | 80-92% |
| read-once.sh | Read (archivos >1KB) | 40-80% |

## Skills

| Skill | Trigger |
|-------|---------|
| token-audit | `/token-audit`, preguntas sobre tokens/costo |
| opusplan | `/opusplan`, decisiones arquitectónicas |

## Dependencias

- `jq` — requerido por los hooks
- `rtk` — opcional, enriquece token-audit con métricas detalladas
