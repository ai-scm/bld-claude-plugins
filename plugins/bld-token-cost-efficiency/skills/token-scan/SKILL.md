---
name: token-scan
description: 'Scan repository Claude Code configuration and generate optimization report card. Use when user says "/token-scan", "scan config", "audit configuration", "check claude setup", "optimize repo config", or asks about configuration quality.'
license: MIT
allowed-tools: Bash, Read
---

# Token Scan — Auditoría de Configuración del Repositorio

Escanea la configuración de Claude Code del repositorio actual y genera un reporte con calificación por categoría (A-F).

## Step 1: Auditar CLAUDE.md

```bash
echo "=== CLAUDE.md ===" && if [[ -f CLAUDE.md ]]; then SIZE=$(wc -c < CLAUDE.md) && LINES=$(wc -l < CLAUDE.md) && echo "Existe: SI | Size: ${SIZE}B | Lines: ${LINES}" && grep -c "^##" CLAUDE.md 2>/dev/null | xargs -I{} echo "Secciones (##): {}" && grep -ciE "(convention|convenci|style|estilo|rule|regla)" CLAUDE.md 2>/dev/null | xargs -I{} echo "Menciones de convenciones: {}"; else echo "Existe: NO"; fi
```

Calificación CLAUDE.md:
- **A**: existe, <5KB, tiene secciones, tiene convenciones
- **B**: existe, <5KB, le faltan secciones o convenciones
- **C**: existe, >5KB (debería dividirse en rules)
- **D**: existe pero >10KB o sin estructura
- **F**: no existe

## Step 2: Auditar Rules

```bash
echo "=== Rules ===" && if [[ -d .claude/rules ]]; then find .claude/rules/ -name "*.md" -exec wc -lc {} + 2>/dev/null && echo "---" && for f in .claude/rules/*.md; do [[ -f "$f" ]] && LINES=$(wc -l < "$f") && echo "$f: ${LINES}L"; done; else echo "No existe .claude/rules/"; fi
```

Calificación Rules:
- **A**: rules existen, tienen path triggers específicos, <50 líneas cada una
- **B**: rules existen pero algunas sin triggers o >50 líneas
- **C**: rules existen pero todas son wildcard o muy grandes
- **D**: solo 1 rule genérica
- **F**: no hay rules (todo en CLAUDE.md o nada)

## Step 3: Auditar Skills

```bash
echo "=== Skills ===" && for DIR in .claude/skills/*/; do [[ -d "$DIR" ]] && SKILL="$DIR/SKILL.md" && if [[ -f "$SKILL" ]]; then LINES=$(wc -l < "$SKILL") && HAS_FM=$(head -1 "$SKILL" | grep -c "^---" || true) && HAS_TOOLS=$(grep -c "allowed-tools" "$SKILL" || true) && HAS_TRIGGER=$(grep -c "Use when" "$SKILL" || true) && echo "$SKILL: ${LINES}L | frontmatter:${HAS_FM} | allowed-tools:${HAS_TOOLS} | triggers:${HAS_TRIGGER}"; fi; done 2>/dev/null || echo "No skills locales"
```

Calificación Skills:
- **A**: frontmatter correcto, <150 líneas, trigger phrases, allowed-tools
- **B**: falta allowed-tools o triggers
- **C**: >150 líneas o sin frontmatter
- **F**: no hay skills locales (informativo, no es error grave)

## Step 4: Auditar Hooks

```bash
echo "=== Hooks ===" && for SETTINGS in .claude/settings.json .claude/settings.local.json; do if [[ -f "$SETTINGS" ]]; then echo "$SETTINGS:" && python3 -c "
import json
with open('$SETTINGS') as f:
    s = json.load(f)
hooks = s.get('hooks', {})
for event, matchers in hooks.items():
    print(f'  {event}: {len(matchers) if isinstance(matchers, list) else 1} matcher(s)')
if not hooks: print('  (sin hooks)')
" 2>/dev/null || echo "  No se pudo parsear"; fi; done
```

Calificación Hooks:
- **A**: hooks configurados, scripts ejecutables, jq check presente
- **B**: hooks configurados pero incompletos
- **C**: settings.json existe pero sin hooks
- **F**: no hay settings.json

## Step 5: Oportunidades de optimización

```bash
echo "=== Oportunidades ===" && echo "Archivos MD grandes (>10KB):" && find . -maxdepth 3 -name "*.md" -size +10k ! -path "./.git/*" -exec ls -lh {} + 2>/dev/null | head -10 || echo "Ninguno" && echo "---" && echo ".gitignore:" && [[ -f .gitignore ]] && echo "Existe ($(wc -l < .gitignore) líneas)" || echo "NO EXISTE" && echo "---" && echo "RTK:" && command -v rtk &>/dev/null && echo "Instalado ($(rtk --version 2>&1))" || echo "No instalado — /rtk-setup para instalar"
```

Calificación Token Optimization:
- **A**: .gitignore robusto, no hay archivos grandes innecesarios, RTK instalado
- **B**: falta RTK o algunos archivos grandes
- **C**: múltiples archivos grandes sin protección
- **F**: sin .gitignore o repo sin optimizar

## Step 6: Generar reporte final

Presenta el Report Card:

| Categoría | Nota | Detalles |
|-----------|------|----------|
| CLAUDE.md | [A-F] | (resumen) |
| Rules | [A-F] | (resumen) |
| Skills | [A-F] | (resumen) |
| Hooks | [A-F] | (resumen) |
| Token Optimization | [A-F] | (resumen) |
| **NOTA GENERAL** | **[A-F]** | Promedio ponderado |

Lista las 3-5 acciones más impactantes como items accionables:
1. "Ejecuta X para resolver Y"
2. "Mueve Z a rules con trigger W"
3. "Instala X para mejorar Y"
