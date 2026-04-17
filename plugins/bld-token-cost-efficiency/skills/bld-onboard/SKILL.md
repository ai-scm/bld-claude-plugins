---
name: bld-onboard
description: 'Full onboarding for bld-token-cost-efficiency plugin. Use when user says "/bld-onboard", "setup plugin", "configure efficiency plugin", "first time setup", or just installed the plugin.'
license: MIT
allowed-tools: Bash, Read
---

# BLD Onboard — Setup Completo del Plugin de Eficiencia

Configura todas las dependencias, herramientas y verificaciones en un solo paso.
Punto de entrada recomendado para usuarios nuevos del plugin.

## Step 1: Verificar e instalar jq

```bash
if command -v jq &>/dev/null; then
  echo "jq: OK ($(jq --version))"
else
  echo "jq: NO ENCONTRADO — Instalando..."
  if command -v apt-get &>/dev/null; then
    sudo apt-get install -y jq 2>&1 | tail -3
  elif command -v brew &>/dev/null; then
    brew install jq 2>&1 | tail -3
  elif command -v yum &>/dev/null; then
    sudo yum install -y jq 2>&1 | tail -3
  else
    echo "ERROR: No se pudo detectar gestor de paquetes. Instala jq manualmente."
  fi
  command -v jq &>/dev/null && echo "jq instalado: $(jq --version)" || echo "FALLO: jq no instalado (hooks no funcionarán)"
fi
```

Si jq no se pudo instalar, advierte que los hooks no funcionarán pero continúa.

## Step 2: Instalar RTK

Ejecuta internamente los pasos del skill `/rtk-setup`:
1. Verificar si RTK ya está instalado
2. Detectar OS
3. Instalar via curl
4. Inicializar hooks globales con `rtk init -g`
5. Verificar instalación

Si RTK ya está instalado, muestra la versión y omite la instalación.

## Step 3: Analizar contexto del proyecto

Ejecuta internamente los pasos del skill `/context-diet`:
1. Medir CLAUDE.md, rules, skills
2. Medir plugins activos
3. Estimar carga base de tokens
4. Generar recomendaciones

## Step 4: Verificar salud de la sesión

Ejecuta internamente los pasos del skill `/session-hygiene`:
1. Estado del caché read-once
2. Estado de RTK
3. Verificar dependencias
4. Recomendación de modelo

## Step 5: Verificar git-commit skill

```bash
echo "=== Git Commit Skill ===" && ls plugins/bld-token-cost-efficiency/skills/git-commit/SKILL.md 2>/dev/null && echo "git-commit: OK (disponible via plugin)" || echo "git-commit: disponible como /git-commit"
```

Confirma que el skill de conventional commits está disponible.

## Step 6: Escaneo rápido del repositorio

Ejecuta internamente los pasos del skill `/token-scan` para dar una calificación
inicial de la configuración del repositorio.

## Step 7: Resumen final

Presenta una tabla compacta:

| Componente | Estado | Notas |
|------------|--------|-------|
| jq | OK / FALLO | Requerido para hooks |
| RTK | OK (vX.X) / No instalado | Ahorro 60-90% tokens |
| Hooks activos | log-filter, read-once, session-context | Automáticos via plugin |
| Context diet | X bytes base / ~Y tokens | Ver recomendaciones |
| Session hygiene | OK / Issues | Ver detalles |
| git-commit | OK | Commits convencionales |
| Token scan | [A-F] | Nota general del repo |

Mensaje final:
> "Setup completo. Skills disponibles: `/token-audit`, `/context-diet`, `/session-hygiene`, `/opusplan`, `/rtk-setup`, `/token-scan`, `/git-commit`, `/bld-onboard`"
