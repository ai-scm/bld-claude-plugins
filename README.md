# bld-claude-plugins

[![Marketplace](https://img.shields.io/badge/claude--code-marketplace-7c3aed)](https://github.com/ai-scm/bld-claude-plugins)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Plugins](https://img.shields.io/badge/plugins-1-blue.svg)](#plugins)
[![Version](https://img.shields.io/badge/version-1.2.0-orange.svg)](#bld-token-cost-efficiency)

Blend's Claude Code plugin marketplace. Curated tools for token efficiency, developer productivity, and standardized workflows.

> **Security note:** Plugins execute code on your machine with your user privileges. Only install plugins from sources you trust.

---

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add ai-scm/bld-claude-plugins

# Install a plugin
/plugin install bld-token-cost-efficiency@bld-claude-plugins

# Run onboarding
/bld-onboard
```

---

## Plugins

### bld-token-cost-efficiency `v1.2.0`

> Reduce Claude Code token consumption by 60-90% through automated output filtering, session caching, and optimized workflows.

**3 hooks** | **8 skills** | Category: `productivity`

| Component | Type | Description |
|-----------|------|-------------|
| `log-filter` | Hook (PreToolUse) | Filters verbose test/build/lint output before reaching context. **80-92% savings.** |
| `read-once` | Hook (PreToolUse) | Blocks redundant re-reads of unchanged files (>1KB) per session. **40-80% savings.** |
| `session-context` | Hook (SessionStart) | Injects token best practices + RTK installation nudge. |
| `/bld-onboard` | Skill | Full onboarding: dependencies, tools, analysis, verification. |
| `/token-audit` | Skill | Session token usage and savings snapshot. |
| `/token-scan` | Skill | Repository config audit with A-F report card. |
| `/context-diet` | Skill | Analyze and optimize context window consumption. |
| `/session-hygiene` | Skill | Session health check: cache, RTK, deps, model recommendation. |
| `/opusplan` | Skill | Hybrid Opus (planning) + Sonnet (execution) workflow. |
| `/rtk-setup` | Skill | Install and configure RTK (Rust Token Killer). |
| `/git-commit` | Skill | Conventional Commits with intelligent staging and safety protocol. |

[Full documentation](plugins/bld-token-cost-efficiency/README.md)

---

## Installation Methods

### Option A: Manual (any user)

```
/plugin marketplace add ai-scm/bld-claude-plugins
```

Then browse and install with `/plugin`.

### Option B: Project-level (team)

Add to your project's `.claude/settings.json` so team members get prompted automatically:

```json
{
  "extraKnownMarketplaces": {
    "bld-claude-plugins": {
      "source": {
        "source": "github",
        "repo": "ai-scm/bld-claude-plugins"
      }
    }
  }
}
```

Optionally auto-enable specific plugins:

```json
{
  "enabledPlugins": {
    "bld-token-cost-efficiency@bld-claude-plugins": true
  }
}
```

### Option C: Enterprise (org-wide)

In **Claude.ai > Admin Settings > Claude Code > Managed Settings**, add the same `extraKnownMarketplaces` JSON. All org members receive the marketplace automatically.

---

## Creating Your Own Plugin

Want to contribute a plugin to this marketplace? See [CONTRIBUTING.md](CONTRIBUTING.md) for the complete guide.

**Quick overview:**

```
plugins/
  your-plugin-name/
    .claude-plugin/
      plugin.json          # Plugin manifest (required)
    hooks/
      hooks.json           # Hook registration (optional)
      your-hook.sh         # Hook scripts
    skills/
      your-skill/
        SKILL.md           # Skill definition (optional)
    README.md              # Plugin documentation (required)
```

---

## Prerequisites

| Dependency | Required | Purpose | Install |
|------------|----------|---------|---------|
| `jq` | Yes (for hooks) | JSON parsing in hook scripts | `apt install jq` / `brew install jq` |
| `rtk` | Optional | Token-optimized CLI proxy (60-90% savings) | `/rtk-setup` or [rtk-ai/rtk](https://github.com/rtk-ai/rtk) |
| `python3` | Optional | Enhanced plugin analytics | Usually pre-installed |

---

## Repository Structure

```
bld-claude-plugins/
  .claude-plugin/
    marketplace.json         # Marketplace catalog (lists all plugins)
  plugins/
    bld-token-cost-efficiency/
      .claude-plugin/
        plugin.json          # Plugin manifest
      hooks/                 # Auto-discovered by Claude Code
      skills/                # Auto-discovered by Claude Code
      README.md
  CONTRIBUTING.md            # Guide for plugin authors
  LICENSE
  README.md                  # This file
```

---

## License

MIT - See [LICENSE](LICENSE) for details.

Individual plugins may have their own licenses specified in their `plugin.json`.
