# bld-claude-plugins

Blend's Claude Code plugin marketplace.

## Plugins

### bld-token-cost-efficiency (v1.2.0)

Token-saving hooks and skills for Claude Code sessions.

**Quick start** — after installing, run `/bld-onboard` for full setup.

**Hooks:**
- **log-filter** — Filters verbose test/build/lint output. Saves 80-92% tokens.
- **read-once** — Blocks redundant re-reads of unchanged files. Saves 40-80% tokens.
- **session-context** — Injects best practices at session start + RTK nudge.

**Skills:**
- `/bld-onboard` — Full onboarding: installs dependencies, analyzes context, verifies setup.
- `/token-audit` — Token usage and savings snapshot for the current session.
- `/token-scan` — Repository configuration audit with A-F report card.
- `/context-diet` — Analyze and optimize context window consumption.
- `/session-hygiene` — Session health check (cache, RTK, model, deps).
- `/opusplan` — Hybrid Opus→Sonnet planning workflow.
- `/rtk-setup` — Install and configure RTK (Rust Token Killer).
- `/git-commit` — Conventional commits with intelligent staging.

## Installation

```
/plugin marketplace add ai-scm/bld-claude-plugins
/plugin install bld-token-cost-efficiency@bld-claude-plugins
```

Or add to your project's `.claude/settings.json`:

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

## Prerequisites

- **jq** — Required by hooks (graceful no-op if missing)
- **rtk** — Optional, install via `/rtk-setup` for full token tracking
