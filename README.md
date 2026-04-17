# bld-claude-plugins

Blend's Claude Code plugin marketplace.

## Plugins

### bld-token-cost-efficiency (v1.0.0)

Token-saving hooks and skills for Claude Code sessions.

**Hooks:**
- **log-filter** — Filters verbose test/build/lint output before it reaches Claude's context. Saves 80-92% tokens.
- **read-once** — Blocks redundant re-reads of unchanged files within a session. Saves 40-80% tokens.

**Skills:**
- `/token-audit` — Shows token usage and savings snapshot for the current session.
- `/opusplan` — Hybrid Opus→Sonnet planning workflow: Opus plans, Sonnet executes.

## Installation

Add this marketplace to your project's `.claude/settings.json`:

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

Then use `/plugin` in Claude Code to browse and install plugins.

## Prerequisites

- **jq** — Required by hooks for JSON parsing (graceful no-op if missing)
- **rtk** — Optional, enhances token-audit skill with detailed savings metrics
