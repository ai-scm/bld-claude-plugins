---
name: opusplan
description: 'Hybrid planning workflow: use Opus for architecture/planning, then Sonnet for execution. Use when user says "/opusplan", "plan con Opus", or needs architectural decisions before coding.'
license: MIT
allowed-tools: Bash, Read, Write, Edit
---

# Opusplan — Workflow Híbrido Opus/Sonnet

**Principio**: Opus piensa (caro, profundo), Sonnet construye (económico, rápido).
Solo usa Opus cuando el valor de la planificación justifica el costo.

## Step 1: Verificar modelo actual

Si NO estás ejecutando como Opus, informa al usuario:

> "Para Opusplan necesitas Opus. Inicia la sesión con:"
> ```bash
> claude --model opus
> ```
> "Luego vuelve a ejecutar /opusplan."

Si YA eres Opus, continúa al Step 2.

## Step 2: Recopilar contexto mínimo

Lee SOLO los archivos estrictamente necesarios:
- `CLAUDE.md` (siempre)
- La rule de `.claude/rules/` que aplique según el área de trabajo
- Los archivos específicos mencionados en el pedido del usuario

**NO leas archivos especulativamente.** Si hay duda, pregunta al usuario qué debe incluirse.

## Step 3: Generar el plan

Crea un archivo de plan estructurado:

```bash
PLAN_FILE=".claude/plans/plan-$(date +%Y%m%d-%H%M%S).md"
```

Formato del plan:
```markdown
# Plan: [título]
Fecha: [fecha] | Modelo: Opus (planificación) → Sonnet (ejecución)

## Objetivo
[1-2 oraciones]

## Enfoque
[Pasos numerados con file paths y cambios específicos]

## Archivos a modificar
- `ruta/archivo.ext` — descripción del cambio

## Riesgos / Edge cases
[Problemas conocidos o consideraciones]

## Comandos de verificación
[Cómo confirmar que los cambios funcionan]
```

## Step 4: Handoff a Sonnet

Después de escribir el plan, informa al usuario:

> "Plan guardado en `${PLAN_FILE}`. Para ejecutar con Sonnet:"
> ```bash
> claude --model sonnet
> ```
> "Luego dile: 'Ejecuta el plan en .claude/plans/plan-[timestamp].md'"

## Reglas

- NUNCA ejecutar cambios de código en este skill — solo planificar
- Planes deben ser ≤ 100 líneas para que Sonnet los lea eficientemente
- Usar rutas absolutas en el plan, no relativas
- Incluir comandos específicos que Sonnet debe ejecutar
