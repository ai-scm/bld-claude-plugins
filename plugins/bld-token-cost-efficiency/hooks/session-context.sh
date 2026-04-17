#!/usr/bin/env bash
# session-context.sh — SessionStart hook
# Inyecta mejores prácticas de eficiencia de tokens + nudge de RTK si no instalado.
# Carga una vez por sesión (~200 tokens de additionalContext).

set -euo pipefail

CONTEXT="## Token Efficiency Best Practices (bld-token-cost-efficiency plugin)\n"
CONTEXT+="- Prefer CLI over MCP: use gh, git, curl via Bash instead of MCP tools\n"
CONTEXT+="- Batch parallel tool calls: combine independent Read/Grep/Glob in one message\n"
CONTEXT+="- Avoid re-reading large files: the read-once hook caches reads per session\n"
CONTEXT+="- Filter verbose output: test/build output is auto-filtered by log-filter hook\n"
CONTEXT+="- Use /clear between unrelated tasks to reset context window\n"
CONTEXT+="- Use /context-diet to analyze context consumption\n"
CONTEXT+="- Use /session-hygiene for session health check\n"

if ! command -v rtk &>/dev/null; then
  EXPORT_PATH="$HOME/.local/bin:$HOME/.cargo/bin"
  RTK_FOUND=false
  for DIR in ${EXPORT_PATH//:/ }; do
    if [[ -x "$DIR/rtk" ]]; then
      RTK_FOUND=true
      break
    fi
  done

  if [[ "$RTK_FOUND" == "false" ]]; then
    CONTEXT+="\n## RTK Not Installed\n"
    CONTEXT+="RTK (Rust Token Killer) saves 60-90% tokens on dev commands.\n"
    CONTEXT+="Run /rtk-setup to install, or manually:\n"
    CONTEXT+="curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh && rtk init -g\n"
  fi
fi

ESCAPED_CONTEXT=$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g')

cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${ESCAPED_CONTEXT}"
  }
}
EOF
exit 0
