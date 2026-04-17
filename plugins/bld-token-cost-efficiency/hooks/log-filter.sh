#!/usr/bin/env bash
# log-filter.sh — PreToolUse hook para comandos Bash
# =============================================================================
# Intercepta comandos de testing y build, añade filtros de output para
# reducir el output verboso que llega al contexto de Claude.
# Ahorro estimado: 80-92% en tokens de output de tests (200-500 líneas → 30-40).
#
# Estrategia: reescribe el comando añadiendo pipes de filtrado ANTES de que
# Claude lo ejecute, por lo que Claude nunca ve el output completo.
#
# No interfiere con comandos que ya tienen pipes de filtrado.
#
# Exit codes:
#   0 = pasar sin cambios (o emitir JSON con updatedInput para reescribir)
# =============================================================================

set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(jq -r '.tool_name // empty' <<< "$INPUT")

if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

COMMAND=$(jq -r '.tool_input.command // empty' <<< "$INPUT")
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# No filtrar si el comando ya tiene pipes de tail/head/grep
if echo "$COMMAND" | grep -qE '\|\s*(tail|head|grep)\s'; then
  exit 0
fi

# Determinar si el comando necesita filtrado y qué filtro aplicar
FILTER=""

case "$COMMAND" in
  *vitest*|*jest*|*"npm test"*|*"npm run test"*|*"pnpm test"*|*"yarn test"*)
    # Tests: conservar las últimas 40 líneas (resumen siempre al final)
    FILTER="2>&1 | tail -40"
    ;;
  *"npm run build"*|*"pnpm build"*|*"yarn build"*|*"npx tsc"*|*"tsc --"*)
    # Build/typecheck: solo errores y warnings
    FILTER="2>&1 | grep -E '(error|warning|Error|Warning|✗|✓|FAIL|PASS|failed|passed|TS[0-9])' | head -30 || true"
    ;;
  *"npm run lint"*|*"pnpm lint"*|*"npx eslint"*|*"npx ruff"*)
    # Linting: solo líneas con problemas
    FILTER="2>&1 | grep -E '(error|warning|✗|problem|Error|Warning)' | head -30 || true"
    ;;
esac

if [[ -z "$FILTER" ]]; then
  exit 0
fi

# Reescribir el comando con el filtro añadido
NEW_CMD="${COMMAND} ${FILTER}"

jq -c --arg cmd "$NEW_CMD" \
  '.tool_input.command = $cmd | {
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": "log-filter: output filtrado para reducir tokens",
      "updatedInput": .tool_input
    }
  }' <<< "$INPUT"
