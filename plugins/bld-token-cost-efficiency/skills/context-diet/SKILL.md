---
name: context-diet
description: 'Analyze and optimize Claude Code context window usage. Use when user says "/context-diet", "optimize context", "context too large", "reduce context", "context usage", or asks about context window optimization.'
license: MIT
allowed-tools: Bash
---

# Context Diet — Análisis de Consumo de Contexto

Mide cuánto contexto base consume tu proyecto y recomienda optimizaciones.

## Step 1: Medir CLAUDE.md y archivos de configuración

```bash
echo "=== CLAUDE.md ===" && wc -c CLAUDE.md 2>/dev/null || echo "No CLAUDE.md encontrado"
echo "" && echo "=== Rules ===" && find .claude/rules/ -name "*.md" -exec wc -c {} + 2>/dev/null || echo "No rules encontradas"
echo "" && echo "=== Skills locales ===" && find .claude/skills/ -name "SKILL.md" -exec wc -c {} + 2>/dev/null || echo "No skills locales"
```

## Step 2: Medir plugins activos

```bash
echo "=== Plugins instalados ===" && cat ~/.claude/plugins/installed_plugins.json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for name, entries in data.get('plugins', {}).items():
    for e in entries:
        print(f\"  {name} (v{e.get('version','?')}, scope={e.get('scope','?')})\")" 2>/dev/null || echo "No plugins instalados"
```

## Step 3: Estimar carga base de tokens

Presenta una tabla con estimaciones (~4 caracteres = 1 token):

| Fuente | Bytes | ~Tokens |
|--------|-------|---------|
| CLAUDE.md | (de Step 1) | bytes/4 |
| Rules (total) | (de Step 1) | bytes/4 |
| Skills locales | (de Step 1) | bytes/4 |
| **Total base** | | |

## Step 4: Recomendaciones

Genera recomendaciones dinámicas basadas en los datos:

- Si CLAUDE.md > 5KB → "Divide CLAUDE.md: mueve secciones a `.claude/rules/` con triggers específicos"
- Si total rules > 10KB → "Demasiadas reglas activas. Las reglas se cargan por path — verifica que los triggers sean específicos"
- Si un SKILL.md > 150 líneas → "Skill demasiado grande. Divide en documentos de referencia"
- Si no hay rules → "Considera mover documentación pesada de CLAUDE.md a rules lazy-loaded"
- Siempre → "Usa `/clear` entre tareas no relacionadas para resetear el contexto"
- Siempre → "Archivos grandes (>1KB) están protegidos por el hook read-once"
