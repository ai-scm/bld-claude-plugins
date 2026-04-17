---
name: token-audit
description: 'Check token usage and savings for the current session. Use when user asks about tokens, cost, usage, savings, or mentions "/token-audit".'
license: MIT
allowed-tools: Bash
---

# Token Audit

Muestra un snapshot del consumo y ahorro de tokens de la sesión actual.

## Step 0: Check prerequisites

```bash
command -v rtk >/dev/null 2>&1 && echo "rtk: installed" || echo "rtk: NOT installed — Steps 1-3 will be skipped"
```

If rtk is NOT installed, skip Steps 1-3 and go to Step 4.
Inform the user: "rtk no está instalado. Instálalo para tracking completo de tokens. Mostrando solo read-once cache."

## Step 1: RTK Savings Report

```bash
rtk gain
```

## Step 2: Command History with Savings

```bash
rtk gain --history
```

## Step 3: Missed Opportunities

```bash
rtk discover
```

## Step 4: Read-Once Cache Status

```bash
ls /tmp/claude-read-cache/ 2>/dev/null && cat /tmp/claude-read-cache/session-* 2>/dev/null || echo "Cache vacío (no hay lecturas bloqueadas aún)"
```

## Presentar resultados

Muestra los resultados en formato compacto:

| Métrica | Valor |
|---------|-------|
| Comandos reescritos por RTK | (de rtk gain, o N/A si no instalado) |
| Tokens ahorrados por RTK | (de rtk gain, o N/A si no instalado) |
| Lecturas bloqueadas (read-once) | (del cache) |
| Oportunidades perdidas | (de rtk discover, o N/A si no instalado) |

## Recomendaciones automáticas

- Si hay oportunidades perdidas > 0 → "Considera agregar estos comandos a RTK"
- Si la sesión lleva muchos turnos → "Ejecuta /clear antes de cambiar de tarea"
- Si rtk no está instalado → "Instala rtk para obtener métricas completas de ahorro"
