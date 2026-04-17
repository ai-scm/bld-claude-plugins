#!/usr/bin/env bash
# read-once.sh — PreToolUse hook para la herramienta Read
# =============================================================================
# Bloquea re-lecturas redundantes de archivos grandes que Claude ya leyó
# en la sesión actual. Ahorro estimado: 40-80% en tokens de lectura.
#
# Funciona con caché por sesión (scoped por PPID) + verificación de mtime.
# Si el archivo fue modificado desde la última lectura, permite re-leer.
#
# Exit codes:
#   0 = permitir lectura
#   2 = BLOQUEAR (archivo ya leído y sin cambios)
# =============================================================================

set -euo pipefail

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(jq -r '.tool_name // empty' <<< "$INPUT")

# Solo actuar en herramienta Read
if [[ "$TOOL_NAME" != "Read" ]]; then
  exit 0
fi

FILE_PATH=$(jq -r '.tool_input.file_path // empty' <<< "$INPUT")
if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Ignorar archivos pequeños (< 1KB) — no vale la pena cachear
FILE_SIZE=$(stat -c%s "$FILE_PATH" 2>/dev/null || echo 0)
if (( FILE_SIZE < 1024 )); then
  exit 0
fi

# Caché scoped por sesión (PPID del proceso Claude)
CACHE_DIR="/tmp/claude-read-cache"
CACHE_FILE="${CACHE_DIR}/session-${PPID}"
mkdir -p "$CACHE_DIR" 2>/dev/null

CURRENT_MTIME=$(stat -c%Y "$FILE_PATH" 2>/dev/null || echo 0)

if [[ -f "$CACHE_FILE" ]]; then
  CACHED_LINE=$(grep -F "|${FILE_PATH}|" "$CACHE_FILE" 2>/dev/null || true)
  if [[ -n "$CACHED_LINE" ]]; then
    CACHED_MTIME=$(echo "$CACHED_LINE" | cut -d'|' -f1)
    if [[ "$CACHED_MTIME" == "$CURRENT_MTIME" ]]; then
      echo "BLOQUEADO: Ya leíste '${FILE_PATH}' esta sesión (sin cambios)." >&2
      echo "Usa tu conocimiento existente del archivo. Si necesitas re-leer, pídelo explícitamente." >&2
      exit 2
    fi
    # Archivo modificado — actualizar caché y permitir re-lectura
    sed -i "\||${FILE_PATH}||d" "$CACHE_FILE" 2>/dev/null || true
  fi
fi

# Registrar esta lectura con mtime actual
echo "${CURRENT_MTIME}|${FILE_PATH}|" >> "$CACHE_FILE"
exit 0
