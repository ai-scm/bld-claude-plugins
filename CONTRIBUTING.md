# Contributing to bld-claude-plugins

Guide for creating and submitting plugins to the Blend Claude Code marketplace.

---

## Table of Contents

- [Plugin Structure](#plugin-structure)
- [Step-by-Step: Create a Plugin](#step-by-step-create-a-plugin)
- [Plugin Manifest (`plugin.json`)](#plugin-manifest)
- [Creating Skills](#creating-skills)
- [Creating Hooks](#creating-hooks)
- [Creating Commands](#creating-commands)
- [Marketplace Registration](#marketplace-registration)
- [Testing Your Plugin](#testing-your-plugin)
- [Validation](#validation)
- [Submission Process](#submission-process)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Reference](#reference)

---

## Plugin Structure

Every plugin lives under `plugins/<plugin-name>/` and follows this layout:

```
plugins/your-plugin-name/
  .claude-plugin/
    plugin.json              # Required: plugin manifest
  hooks/
    hooks.json               # Optional: hook event registration
    your-hook.sh             # Optional: hook scripts (must be executable)
  skills/
    your-skill/
      SKILL.md               # Optional: skill definitions
  commands/
    your-command.md           # Optional: slash commands
  agents/
    your-agent.md             # Optional: autonomous agents
  README.md                   # Required: plugin documentation
```

**Auto-discovery:** Claude Code automatically discovers `hooks/hooks.json`, `skills/*/SKILL.md`, `commands/*.md`, and `agents/*.md` at the plugin root. You do not need to register these paths in `plugin.json`.

---

## Step-by-Step: Create a Plugin

### 1. Create the directory

```bash
mkdir -p plugins/your-plugin-name/.claude-plugin
mkdir -p plugins/your-plugin-name/skills/your-skill
mkdir -p plugins/your-plugin-name/hooks
```

### 2. Create the manifest

```bash
cat > plugins/your-plugin-name/.claude-plugin/plugin.json << 'EOF'
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "Brief description of what your plugin does.",
  "author": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "repository": "https://github.com/ai-scm/bld-claude-plugins",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
EOF
```

### 3. Add your skills, hooks, or commands

See the sections below for each component type.

### 4. Write your README

Document what your plugin does, how to use it, and any dependencies.

### 5. Register in the marketplace

Add your plugin to `.claude-plugin/marketplace.json` (see [Marketplace Registration](#marketplace-registration)).

### 6. Validate and test

```bash
claude plugin validate .
```

---

## Plugin Manifest

The `plugin.json` file is the only **required** file for a plugin.

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "What this plugin does in one sentence.",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  },
  "repository": "https://github.com/ai-scm/bld-claude-plugins",
  "license": "MIT",
  "keywords": ["tag1", "tag2", "tag3"]
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier. Use kebab-case (`my-plugin`, not `My Plugin`). |
| `version` | Yes | Semver (`MAJOR.MINOR.PATCH`). Bump MINOR for new features, PATCH for fixes. |
| `description` | Yes | One-line description. Shown in `/plugin` discovery UI. |
| `author` | Yes | Object with `name` (required) and `email` (optional). |
| `repository` | No | URL to the source repository. |
| `license` | No | SPDX license identifier (e.g., `MIT`, `Apache-2.0`). |
| `keywords` | No | Array of strings for search/discovery. |

---

## Creating Skills

Skills are the most common plugin component. They define workflows that users invoke with slash commands.

### File: `skills/your-skill/SKILL.md`

```markdown
---
name: your-skill
description: 'Brief trigger description. Use when user says "/your-skill", "keyword", or asks about topic.'
license: MIT
allowed-tools: Bash, Read, Edit, Write
---

# Your Skill Name

Brief description of what this skill does.

## Step 1: First action

\```bash
echo "Run this command"
\```

Explain what Claude should do with the result.

## Step 2: Next action

\```bash
echo "Another command"
\```

## Step 3: Present results

Show results in a compact table or summary.
```

### SKILL.md Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Skill identifier (used in `/skill-name` command). |
| `description` | Yes | Must include trigger phrases: `"Use when user says..."`. |
| `license` | No | SPDX identifier. |
| `allowed-tools` | No | Comma-separated list: `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`. |

### Skill Guidelines

- **Max 150 lines** — Skills load fully into context (~4 chars = 1 token). A 150-line skill is ~1,500 tokens.
- **Use `## Step N:` headings** — Claude follows these sequentially.
- **Include trigger phrases** in description — this is how Claude knows when to activate the skill.
- **Bash code blocks** — Claude executes these. Make them copy-paste safe.
- **Handle missing dependencies gracefully** — Check before using tools like `jq`, `rtk`, `python3`.
- **Avoid reading files in skills about context** — Use `Bash` commands (`wc`, `stat`, `du`) to measure without consuming tokens.

### Token Budget Reference

| Skill Size | Tokens When Activated | Use For |
|------------|----------------------|---------|
| <=50 lines | ~500 | Simple automations |
| 50-100 lines | ~1,000 | Standard workflows |
| 100-150 lines | ~1,500 | Complex multi-step flows |
| >150 lines | 1,500+ | **Avoid** — split into referenced docs |

---

## Creating Hooks

Hooks intercept Claude Code events (tool calls, session start) to modify behavior transparently.

### File: `hooks/hooks.json`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/your-hook.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/session-hook.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### Hook Events

| Event | When | Matcher | Use For |
|-------|------|---------|---------|
| `PreToolUse` | Before a tool executes | Tool name (`Bash`, `Read`, `Edit`, etc.) | Filtering, rewriting, blocking |
| `PostToolUse` | After a tool executes | Tool name | Logging, validation, notifications |
| `SessionStart` | Once per session | None needed | Context injection, setup checks |

### Hook Script Protocol

**Input:** JSON via stdin.

```json
{
  "tool_name": "Bash",
  "tool_input": { "command": "npm test" }
}
```

**Output:** JSON via stdout (for PreToolUse only).

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "Rewritten by hook",
    "updatedInput": { "command": "npm test 2>&1 | tail -40" }
  }
}
```

**Exit Codes:**

| Code | Meaning |
|------|---------|
| `0` | Allow (optionally with modified input via stdout JSON) |
| `2` | Block execution (stderr message shown to Claude) |
| Other | Pass through unchanged |

### Hook Script Template

```bash
#!/usr/bin/env bash
# your-hook.sh — PreToolUse hook description
set -euo pipefail

# Require jq for JSON parsing
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(jq -r '.tool_name // empty' <<< "$INPUT")

# Only process specific tools
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

COMMAND=$(jq -r '.tool_input.command // empty' <<< "$INPUT")

# Your filtering/rewriting logic here
# ...

# Output rewritten command
jq -c --arg cmd "$NEW_CMD" \
  '.tool_input.command = $cmd | {
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "allow",
      "permissionDecisionReason": "your-hook: description",
      "updatedInput": .tool_input
    }
  }' <<< "$INPUT"
```

### Important Notes

- **Always use `${CLAUDE_PLUGIN_ROOT}`** for file paths in `hooks.json`. Plugins install to a cache directory (`~/.claude/plugins/cache/...`), not the repository path.
- **Scripts must be executable:** `chmod +x hooks/*.sh`.
- **Always check for `jq`** and exit 0 gracefully if missing.
- **SessionStart hooks** can inject `additionalContext` — this is the plugin equivalent of a `.claude/rules/` file.

---

## Creating Commands

Commands are slash commands that provide instructions to Claude.

### File: `commands/your-command.md`

```markdown
---
description: 'What this command does'
allowed-tools: Bash, Read
---

Instructions for Claude when the user runs /your-command.

You can include $ARGUMENTS to capture user input:
The user said: $ARGUMENTS
```

Commands differ from skills: commands are **instructions for Claude**, skills are **documented workflows**.

---

## Marketplace Registration

After creating your plugin, register it in `.claude-plugin/marketplace.json`:

```json
{
  "name": "bld-claude-plugins",
  "metadata": {
    "description": "Blend's Claude Code plugin marketplace."
  },
  "owner": {
    "name": "Blend",
    "email": "ai-scm@blend.com"
  },
  "plugins": [
    {
      "name": "existing-plugin",
      "...": "..."
    },
    {
      "name": "your-plugin-name",
      "description": "What your plugin does.",
      "version": "1.0.0",
      "author": { "name": "Your Name" },
      "source": "./plugins/your-plugin-name",
      "category": "productivity",
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

### Marketplace Entry Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Must match `plugin.json` name. kebab-case only. |
| `description` | Yes | Shown in marketplace discovery. |
| `version` | Yes | Must match `plugin.json` version. |
| `author` | Yes | Object with `name`. |
| `source` | Yes | Relative path from marketplace root (e.g., `./plugins/your-plugin`). |
| `category` | No | One of: `productivity`, `development`, `design`, `testing`, `devops`. |
| `tags` | No | Array of strings for discovery. |

---

## Testing Your Plugin

### 1. Validate marketplace structure

```bash
claude plugin validate .
```

This checks: `marketplace.json` schema, `plugin.json` schema, SKILL.md frontmatter, `hooks.json` syntax.

### 2. Test hooks locally

```bash
# Test a PreToolUse hook
echo '{"tool_name":"Bash","tool_input":{"command":"npm test"}}' | bash plugins/your-plugin/hooks/your-hook.sh

# Test a SessionStart hook
echo '{}' | bash plugins/your-plugin/hooks/session-hook.sh
```

### 3. Test via local marketplace

```bash
# Add your local directory as a marketplace
/plugin marketplace add ./

# Install and test the plugin
/plugin install your-plugin@bld-claude-plugins
```

### 4. Verify skills appear

After installation, your skills should appear in Claude Code's `/skills` list and respond to their trigger phrases.

---

## Validation

Before submitting, ensure:

- [ ] `claude plugin validate .` passes with no errors
- [ ] All `.sh` files are executable (`chmod +x`)
- [ ] All SKILL.md files are under 150 lines
- [ ] All SKILL.md files have valid YAML frontmatter (`name`, `description`)
- [ ] Frontmatter descriptions include trigger phrases (`"Use when..."`)
- [ ] Hook scripts check for `jq` and exit 0 gracefully if missing
- [ ] Hook scripts use `${CLAUDE_PLUGIN_ROOT}` for file paths
- [ ] `plugin.json` version matches `marketplace.json` version
- [ ] Plugin name is kebab-case
- [ ] README.md documents all skills, hooks, and dependencies

---

## Submission Process

1. **Fork** this repository
2. **Create** your plugin under `plugins/your-plugin-name/`
3. **Register** it in `.claude-plugin/marketplace.json`
4. **Validate** with `claude plugin validate .`
5. **Submit** a pull request with:
   - Clear description of what the plugin does
   - Why it belongs in the Blend marketplace
   - Test evidence (validation output, usage examples)

### PR Template

```markdown
## New Plugin: your-plugin-name

### What it does
Brief description.

### Components
- N skills: /skill-1, /skill-2
- N hooks: hook-1 (event), hook-2 (event)

### Validation
claude plugin validate . output: PASSED

### Testing
Tested locally with /plugin marketplace add ./ and verified skills/hooks work.
```

---

## Best Practices

### Do

- Keep skills focused — one skill, one job
- Handle missing dependencies gracefully (check, skip, suggest install)
- Use `SessionStart` hooks for context injection (plugin equivalent of rules)
- Write trigger phrases in skill descriptions for discoverability
- Document everything in your README
- Use bash code blocks in skills for Claude to execute
- Test hooks with piped JSON before publishing

### Don't

- Don't make skills over 150 lines (they load fully into context)
- Don't hardcode absolute paths in hooks (use `${CLAUDE_PLUGIN_ROOT}`)
- Don't assume tools are installed (`jq`, `rtk`, `python3`) — always check
- Don't put secrets or credentials in plugin files
- Don't duplicate functionality that Claude Code provides natively
- Don't use `$schema` in `marketplace.json` (validation rejects it)

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Validation fails with "Unrecognized key" | Extra fields in JSON | Remove unrecognized fields (e.g., `$schema`) |
| Skills don't appear after install | Cache stale | `rm -rf ~/.claude/plugins/cache` and reinstall |
| Hooks don't fire | Script not executable | `chmod +x hooks/*.sh` |
| Hook outputs malformed JSON | Missing `jq` or bad escaping | Test with `echo '{}' \| bash hook.sh` and validate JSON output |
| `${CLAUDE_PLUGIN_ROOT}` not resolved | Using outside hooks.json | This variable only works in `hooks.json` command fields |
| Plugin name collision | Name already exists | Use a unique prefix (e.g., `bld-your-plugin`) |

---

## Reference

- [Claude Code Plugins Documentation](https://docs.anthropic.com/en/docs/claude-code/plugins)
- [Plugin Marketplace Guide](https://docs.anthropic.com/en/docs/claude-code/plugin-marketplaces)
- [Plugins Reference (Schemas)](https://docs.anthropic.com/en/docs/claude-code/plugins-reference)
- [Plugin Settings](https://docs.anthropic.com/en/docs/claude-code/plugin-settings)
- Official example: `anthropics/claude-plugins-official`
