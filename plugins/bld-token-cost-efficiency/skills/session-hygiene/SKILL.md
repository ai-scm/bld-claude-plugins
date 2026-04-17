---
name: session-hygiene
description: 'Session management best practices and health check. Use when user says "/session-hygiene", "session tips", "optimize session", "session health", or asks about session optimization.'
license: MIT
allowed-tools: Bash
---

# Session Hygiene — Chequeo de Salud de Sesión

Audita el estado de la sesión actual y recomienda ajustes para eficiencia.

## Step 1: Estado del caché read-once

```bash
CACHE_DIR="/tmp/claude-read-cache"
if [[ -d "$CACHE_DIR" ]]; then
  SESSION_FILE=$(ls -t "$CACHE_DIR"/session-* 2>/dev/null | head -1)
  if [[ -n "$SESSION_FILE" ]]; then
    CACHED_COUNT=$(wc -l < "$SESSION_FILE")
    echo "Archivos cacheados esta sesión: $CACHED_COUNT"
    echo "Archivos protegidos:"
    cat "$SESSION_FILE" | while IFS='|' read -r mtime path _; do
      [[ -n "$path" ]] && echo "  $path"
    done
  else
    echo "Cache vacío (no hay lecturas registradas aún)"
  fi
else
  echo "Cache read-once no inicializado"
fi
```

## Step 2: Estado de RTK

```bash
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
if command -v rtk &>/dev/null; then
  echo "=== RTK instalado ==="
  rtk --version
  rtk gain 2>/dev/null || echo "Sin datos de savings aún"
else
  echo "RTK NO instalado — ejecuta /rtk-setup para instalar"
  echo "Ahorro potencial: 60-90% en tokens de comandos dev"
fi
```

## Step 3: Verificar dependencias de hooks

```bash
echo "=== Dependencias ==="
command -v jq &>/dev/null && echo "jq: OK" || echo "jq: FALTA (los hooks no filtrarán sin jq)"
command -v rtk &>/dev/null && echo "rtk: OK" || echo "rtk: opcional (instala con /rtk-setup)"
```

## Step 4: Recomendación de modelo

Muestra la recomendación de modelo según el tipo de tarea:

| Tarea | Modelo recomendado | Razón |
|-------|-------------------|-------|
| Arquitectura, planificación, debugging complejo | Opus | Pensamiento profundo justifica el costo |
| Edición de código, tareas rutinarias, ejecución de planes | Sonnet | Rápido y económico |
| Preguntas rápidas, formateo, ediciones simples | Haiku | Mínimo costo |

Sugiere `/opusplan` si el usuario necesita planificar con Opus y ejecutar con Sonnet.

## Step 5: Resumen

Presenta tabla compacta:

| Check | Estado | Acción |
|-------|--------|--------|
| read-once cache | N archivos | — |
| RTK | instalado/no | /rtk-setup si falta |
| jq | OK/falta | apt install jq |
| Modelo actual | (informar) | ajustar según tarea |
