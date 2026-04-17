---
name: rtk-setup
description: 'Install and configure RTK (Rust Token Killer) for Claude Code. Use when user says "/rtk-setup", "install rtk", "configure rtk", "setup rtk", or asks how to install RTK.'
license: MIT
allowed-tools: Bash
---

# RTK Setup — Instalación de Rust Token Killer

RTK filtra y comprime output de comandos antes de que llegue al contexto de Claude.
Ahorro estimado: 60-90% en tokens de operaciones dev.

## Step 1: Verificar si RTK ya está instalado

```bash
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH" && command -v rtk && rtk --version || echo "RTK_NOT_INSTALLED"
```

Si ya está instalado, informa la versión y salta al Step 4.

## Step 2: Detectar sistema operativo

```bash
uname -s
```

- **Linux** o **Darwin** (macOS): continúa al Step 3
- **Otro**: informa que RTK requiere Linux o macOS

## Step 3: Instalar RTK

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

Se instala en `~/.local/bin`. Si falla, sugiere alternativas:
- Homebrew: `brew install rtk`
- Cargo: `cargo install --git https://github.com/rtk-ai/rtk`

Verifica que el PATH incluya `~/.local/bin`:

```bash
export PATH="$HOME/.local/bin:$PATH" && rtk --version
```

## Step 4: Inicializar hooks globales

```bash
rtk init -g
```

Esto configura el hook PreToolUse en `~/.claude/settings.json` que reescribe
comandos Bash automáticamente (git status → rtk git status).

## Step 5: Verificar instalación completa

```bash
rtk --version && rtk gain
```

Muestra al usuario:
- Versión instalada
- Que el hook está activo (reiniciar Claude Code si es nueva instalación)

## Troubleshooting

- **PATH no actualizado**: `export PATH="$HOME/.local/bin:$PATH"` y agregar a `~/.bashrc`
- **Name collision (Rust Type Kit)**: Si `rtk gain` falla, tiene el paquete incorrecto. Usar `cargo install --git https://github.com/rtk-ai/rtk`
- **jq requerido**: Los hooks del plugin necesitan `jq`. Instalar: `sudo apt install jq` o `brew install jq`
