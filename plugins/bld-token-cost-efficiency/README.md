# bld-token-cost-efficiency

[![Version](https://img.shields.io/badge/version-1.2.0-orange.svg)](#changelog)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](../../LICENSE)
[![Hooks](https://img.shields.io/badge/hooks-3-purple.svg)](#hooks)
[![Skills](https://img.shields.io/badge/skills-8-blue.svg)](#skills)
[![Category](https://img.shields.io/badge/category-productivity-yellow.svg)](#)

> Reduce Claude Code token consumption by 60-90% through automated output filtering, intelligent caching, and optimized workflows.

---

## Table of Contents

- [Why This Plugin](#why-this-plugin)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Hooks](#hooks)
- [Skills](#skills)
- [Token Savings Breakdown](#token-savings-breakdown)
- [Dependencies](#dependencies)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Changelog](#changelog)

---

## Why This Plugin

Claude Code sessions consume tokens on every tool call: reading files, running commands, checking git status. Most of this output is verbose boilerplate that Claude doesn't need.

**The problem:**
- `npm test` outputs 200+ lines when Claude only needs the summary
- Reading a file twice in one session doubles the token cost
- No visibility into how many tokens are being wasted

**This plugin solves it with:**
- **Hooks** that filter output automatically before it reaches Claude's context
- **Skills** that give you visibility, diagnostics, and optimization workflows
- **Zero friction** after setup: hooks run transparently on every tool call

---

## Quick Start

```
/bld-onboard
```

The onboarding wizard handles everything:

1. Installs `jq` (required for hooks)
2. Installs RTK (optional, 60-90% additional savings)
3. Analyzes your project's context consumption
4. Runs a health check on your session
5. Scans your repository configuration
6. Verifies all components are working

---

## Installation

### From the marketplace

```
/plugin marketplace add ai-scm/bld-claude-plugins
/plugin install bld-token-cost-efficiency@bld-claude-plugins
```

### From project settings

Add to `.claude/settings.json` for automatic team installation:

```json
{
  "extraKnownMarketplaces": {
    "bld-claude-plugins": {
      "source": {
        "source": "github",
        "repo": "ai-scm/bld-claude-plugins"
      }
    }
  },
  "enabledPlugins": {
    "bld-token-cost-efficiency@bld-claude-plugins": true
  }
}
```

### Update

```
/plugin marketplace update bld-claude-plugins
```

### Uninstall

```
/plugin uninstall bld-token-cost-efficiency@bld-claude-plugins
```

---

## Hooks

Hooks run automatically on every relevant tool call. No manual invocation needed.

### log-filter

| | |
|---|---|
| **Event** | PreToolUse |
| **Matcher** | Bash |
| **Savings** | 80-92% on test/build/lint output |
| **Requires** | `jq` |

Intercepts test, build, and lint commands and adds output filters before execution.

| Command Pattern | Filter Applied |
|----------------|----------------|
| `vitest`, `jest`, `npm test`, `pnpm test` | `2>&1 \| tail -40` (summary at end) |
| `npm run build`, `npx tsc`, `tsc --` | `grep -E '(error\|warning\|FAIL\|PASS)'` |
| `npm run lint`, `npx eslint`, `npx ruff` | `grep -E '(error\|warning\|problem)'` |

Commands with existing pipes (`| tail`, `| head`, `| grep`) are passed through unchanged.

### read-once

| | |
|---|---|
| **Event** | PreToolUse |
| **Matcher** | Read |
| **Savings** | 40-80% on file re-reads |
| **Requires** | `jq` |

Maintains a session-scoped cache (`/tmp/claude-read-cache/session-{PID}`) that tracks which files Claude has already read. If a file hasn't changed since the last read (checked via mtime), the re-read is blocked.

- Files under 1KB are always allowed (too small to cache)
- Modified files are automatically allowed (mtime changed)
- Cache resets when the session ends

### session-context

| | |
|---|---|
| **Event** | SessionStart |
| **Matcher** | None (runs once) |
| **Requires** | None |

Injects token-efficiency best practices into the session context at startup:

- Prefer CLI over MCP tool calls
- Batch parallel tool calls
- Leverage read-once caching
- Use `/clear` between unrelated tasks

Also checks if RTK is installed. If not, adds a suggestion to run `/rtk-setup`.

---

## Skills

### `/bld-onboard` — Full Setup Wizard

Complete onboarding for new users. Orchestrates all other skills in sequence.

| | |
|---|---|
| **Triggers** | `/bld-onboard`, "setup plugin", "first time setup" |
| **Tools** | Bash, Read |

**Steps:** jq install -> RTK install -> context analysis -> session health -> git-commit verify -> repo scan -> summary table.

---

### `/token-audit` — Session Metrics

Snapshot of token usage and savings for the current session.

| | |
|---|---|
| **Triggers** | `/token-audit`, questions about tokens/cost/usage |
| **Tools** | Bash |
| **Requires** | `rtk` (optional; graceful fallback) |

**Output:** Compact table with RTK savings, command history, missed optimization opportunities, and read-once cache statistics.

---

### `/token-scan` — Repository Audit

Scans your repository's Claude Code configuration and generates a report card.

| | |
|---|---|
| **Triggers** | `/token-scan`, "scan config", "audit configuration" |
| **Tools** | Bash, Read |

**Audits:**

| Category | What's Checked | Grade Criteria |
|----------|---------------|----------------|
| CLAUDE.md | Exists, size, sections, conventions | A: <5KB with structure, F: missing |
| Rules | Path triggers, granularity, size | A: specific triggers + <50 lines each |
| Skills | Frontmatter, size, triggers | A: valid format + <150 lines |
| Hooks | Configuration, executability | A: hooks configured + scripts ok |
| Optimization | .gitignore, large files, RTK | A: all optimized, F: nothing in place |

**Output:** A-F report card per category + top 3-5 actionable items.

---

### `/context-diet` — Context Analyzer

Measures how much baseline context your project loads and where to optimize.

| | |
|---|---|
| **Triggers** | `/context-diet`, "optimize context", "context too large" |
| **Tools** | Bash |

**Measures:** CLAUDE.md, `.claude/rules/`, `.claude/skills/`, active plugins. Estimates token load using the ~4 chars/token heuristic.

---

### `/session-hygiene` — Session Health Check

Audits the health of your current session.

| | |
|---|---|
| **Triggers** | `/session-hygiene`, "session tips", "session health" |
| **Tools** | Bash |

**Checks:** read-once cache status, RTK status, jq availability, model recommendation (Opus vs Sonnet vs Haiku by task type).

---

### `/opusplan` — Hybrid Planning Workflow

Use Opus for deep architecture/planning, then hand off to Sonnet for execution.

| | |
|---|---|
| **Triggers** | `/opusplan`, "plan con Opus", architectural decisions |
| **Tools** | Bash, Read, Write, Edit |

**Principle:** Opus thinks (expensive, deep). Sonnet builds (cheap, fast). Only use Opus when planning value justifies cost.

---

### `/rtk-setup` — RTK Installation

Guided installation of RTK (Rust Token Killer), a CLI proxy that compresses command output.

| | |
|---|---|
| **Triggers** | `/rtk-setup`, "install rtk", "configure rtk" |
| **Tools** | Bash |

**Installs via:** `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh`

**Configures:** Global Claude Code hooks via `rtk init -g`.

---

### `/git-commit` — Conventional Commits

Create standardized git commits with intelligent staging and safety protocol.

| | |
|---|---|
| **Triggers** | `/git-commit`, "commit changes", "create commit" |
| **Tools** | Bash |

**Features:**
- Auto-detects commit type and scope from diff
- Conventional Commits format: `<type>[scope]: <description>`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- Safety protocol: never force push, never skip hooks, never amend on failure

---

## Token Savings Breakdown

Estimated savings for a typical 30-minute Claude Code session:

| Operation | Frequency | Without Plugin | With Plugin | Savings |
|-----------|-----------|----------------|-------------|---------|
| `npm test` / `vitest` | 5x | 25,000 | 2,500 | 90% |
| File reads (>1KB) | 20x | 40,000 | 12,000 | 70% |
| `git status` / `git diff` | 15x | 5,000 | 1,000 | 80% |
| Build / typecheck | 3x | 9,000 | 900 | 90% |
| Lint output | 3x | 3,000 | 600 | 80% |
| **Total** | | **~82,000** | **~17,000** | **~79%** |

> With RTK additionally installed, savings increase to 85-92% across all operations.

---

## Dependencies

| Dependency | Required By | Status | Install |
|------------|-------------|--------|---------|
| `jq` | All hooks (log-filter, read-once, session-context) | **Required** | `sudo apt install jq` or `brew install jq` |
| `rtk` | token-audit (enhanced), session-hygiene | **Optional** | `/rtk-setup` |
| `python3` | context-diet (plugin analytics), token-scan (hooks audit) | **Optional** | Usually pre-installed |

All hooks exit gracefully (code 0) if `jq` is missing — they simply become no-ops. Skills with optional dependencies check for availability and skip/fallback when not found.

---

## Configuration

### Hook behavior

Hooks are configured via `hooks/hooks.json` in the plugin directory. After installation, they run automatically — no manual configuration needed.

To **disable** a specific hook without uninstalling the plugin, you can override in your project's `.claude/settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": []
  }
}
```

### Read-once cache

The read-once cache stores data at `/tmp/claude-read-cache/session-{PID}`. It resets automatically when the session ends. To manually clear it:

```bash
rm -rf /tmp/claude-read-cache/
```

### Session context

The best-practice context injected at session start adds ~200 tokens. This is less than a single file read and persists for the entire session.

---

## Architecture

```
bld-token-cost-efficiency/
  .claude-plugin/
    plugin.json                    # Manifest: name, version, author
  hooks/
    hooks.json                     # Event registration (auto-discovered)
    log-filter.sh                  # PreToolUse: Bash output filtering
    read-once.sh                   # PreToolUse: Read deduplication
    session-context.sh             # SessionStart: best practices injection
  skills/
    bld-onboard/SKILL.md           # Orchestrator: full setup wizard
    token-audit/SKILL.md           # Session metrics
    token-scan/SKILL.md            # Repository config audit
    context-diet/SKILL.md          # Context window analysis
    session-hygiene/SKILL.md       # Session health check
    opusplan/SKILL.md              # Opus/Sonnet hybrid workflow
    rtk-setup/SKILL.md             # RTK installation guide
    git-commit/SKILL.md            # Conventional commits
```

### How hooks work

```
Without plugin:

  Claude  --npm test-->  Shell  -->  npm
    ^                                 |
    |       ~5,000 tokens (raw)       |
    +---------------------------------+

With plugin:

  Claude  --npm test-->  Hook  -->  Shell  -->  npm
    ^                     |                      |
    |   ~500 tokens       | filter (tail -40)    |
    +---- (filtered) -----+----------------------+
```

### Portable paths

All hook scripts in `hooks.json` use `${CLAUDE_PLUGIN_ROOT}` instead of absolute paths. This variable resolves to the plugin's cache location at runtime (e.g., `~/.claude/plugins/cache/bld-claude-plugins/bld-token-cost-efficiency/1.2.0/`).

---

## Changelog

### v1.2.0

- **Added** `/bld-onboard` — Full setup orchestrator
- **Added** `/token-scan` — Repository configuration audit with A-F report card
- **Added** `/git-commit` — Conventional Commits with safety protocol

### v1.1.0

- **Added** `/rtk-setup` — RTK installation wizard
- **Added** `/context-diet` — Context window analyzer
- **Added** `/session-hygiene` — Session health check
- **Added** `session-context.sh` — SessionStart hook with best practices + RTK nudge

### v1.0.0

- **Initial release**
- `log-filter.sh` — Bash output filtering (80-92% savings)
- `read-once.sh` — Read deduplication (40-80% savings)
- `/token-audit` — Session token metrics
- `/opusplan` — Hybrid Opus/Sonnet planning workflow
