# Design: Convergence Plugin Marketplace
Date: 2026-04-13

Research: `docs/convergence/research/2026-04-13-plugin-marketplace.md`

## Current State

Convergence is distributed via `setup.sh`, a 65-line bash script that symlinks:

- `skills/<name>/SKILL.md` → `$CLAUDE_CONFIG_DIR/skills/convergence-<name>`
- `.claude/agents/<name>.md` → `$CLAUDE_CONFIG_DIR/agents/convergence-<name>.md`

10 skills, 4 agents, 1 inline `PreToolUse` hook in `.claude/settings.json`. The `convergence-` prefix is already in each `SKILL.md` frontmatter. Repo lives at `github.com/c-sonnier/convergence`.

No `.claude-plugin/` directory exists today.

## Desired End State

Users install convergence through the Claude Code plugin system:

```
/plugin marketplace add c-sonnier/convergence
/plugin install convergence@csonnier
```

One marketplace (`csonnier`) lists one plugin (`convergence`) that bundles all 10 skills, 4 agents, and the safety hook. Contributors wanting live-edit symlinks still use `setup.sh`.

Final repo layout:

```
convergence/
  .claude-plugin/
    marketplace.json
  plugins/
    convergence/
      .claude-plugin/
        plugin.json
      skills/                (10 skill dirs, moved from root)
      agents/                (4 agent .md files, moved from .claude/agents/)
      hooks/
        hooks.json           (moved from .claude/settings.json)
  docs/
  CLAUDE.md
  LICENSE
  README.md                  (marketplace install first, setup.sh second)
  setup.sh                   (updated to point at new paths; developer mode)
```

`.claude/` at the repo root is deleted (contents moved into the plugin).

## Patterns to Follow

- **Single-plugin bundle** — all components ship together — CONFIRMED
- **Layout B (files inside plugin dir)** — matches docs walkthrough, avoids cache-copy exclusion risk — CONFIRMED
- **Relative-path plugin source** (`./plugins/convergence`) — marketplace and plugin in one repo — CONFIRMED
- **`strict: true` (default)** — `plugin.json` is the authority; marketplace entry just points at it — CONFIRMED
- **`convergence-` prefix preserved via SKILL.md frontmatter** — travels with the files automatically — CONFIRMED
- **setup.sh as developer-mode install** — symlinks for fast edit loop; end users use marketplace — CONFIRMED
- **Ship hook as part of plugin** — safety hook becomes default for everyone who installs — CONFIRMED

## Approach

Create a marketplace manifest at `.claude-plugin/marketplace.json` pointing at a single relative-path plugin. Move existing skills, agents, and the hook into `plugins/convergence/` with a proper `plugin.json`. Update `setup.sh` to point at the new paths. Rewrite README's Install section to lead with marketplace install.

### Marketplace manifest

`.claude-plugin/marketplace.json`:

```json
{
  "name": "csonnier",
  "owner": {
    "name": "Chris Sonnier"
  },
  "metadata": {
    "description": "Chris Sonnier's Claude Code plugins",
    "version": "1.0.0"
  },
  "plugins": [
    {
      "name": "convergence",
      "source": "./plugins/convergence",
      "description": "Consolidated skills, agents, and workflows for Claude Code. 10 skills + 4 agents + 1 safety hook."
    }
  ]
}
```

### Plugin manifest

`plugins/convergence/.claude-plugin/plugin.json`:

```json
{
  "name": "convergence",
  "description": "Consolidated skills, agents, and workflows distilled from 6 open-source repos",
  "version": "1.0.0",
  "author": {
    "name": "Chris Sonnier"
  },
  "homepage": "https://github.com/c-sonnier/convergence",
  "repository": "https://github.com/c-sonnier/convergence",
  "license": "MIT",
  "keywords": ["workflow", "tdd", "code-review", "research", "design"]
}
```

With `strict: true` (default), Claude Code auto-discovers skills under `skills/`, agents under `agents/`, and hooks from `hooks/hooks.json` within the plugin directory. No explicit path declarations needed in either manifest.

### File moves

- `skills/*` → `plugins/convergence/skills/*` (10 skill dirs)
- `.claude/agents/*.md` → `plugins/convergence/agents/*.md` (4 agents)
- `.claude/settings.json` (hook block) → `plugins/convergence/hooks/hooks.json` (top-level `hooks` key)
- `.claude/` directory deleted

### setup.sh update

Point source paths at the new `plugins/convergence/` subdirectory. The `convergence-` install prefix logic stays the same — still prepended at symlink target name.

### README update

Lead with marketplace install:

```markdown
## Install

/plugin marketplace add c-sonnier/convergence
/plugin install convergence@csonnier

## Developer mode (live-edit symlinks)

For contributors editing convergence itself:
git clone ... && cd convergence && ./setup.sh
```

### Alternatives Considered

- **Layout A1 (plugin source `./`, whole repo is the plugin)**: Rejected because it copies `docs/`, README, LICENSE, etc. into every user's plugin cache. Permanent ~200KB+ waste per install.
- **Layout A2 (symlinks inside `plugins/convergence/` back to root)**: Rejected. Undocumented whether Claude Code's plugin cache copy preserves symlink targets. Risky gamble vs. one-time file move.
- **Multi-plugin split (workflow + utility)**: Rejected. Skills are designed to compose; CLAUDE.md routes between them. Users wanting granularity can `/plugin disable` after install.
- **Marketplace name `convergence`**: Rejected. `/plugin install convergence@convergence` is awkward. `@csonnier` reads naturally and leaves namespace room.
- **Delete setup.sh**: Rejected. Marketplace installs *copy* files into cache, so repo edits don't take effect until `/plugin marketplace update`. Symlinks via setup.sh give contributors an instant edit loop.
- **Exclude hook from plugin (keep opt-in)**: Rejected. Hook is a core value-add per README. Shipping by default makes the Claude Code + convergence combination safer without requiring users to manually copy settings.

## Resolved Decisions

- **Single plugin vs. multi-plugin**: Single plugin `convergence` — skills compose; split loses that.
- **File layout**: Layout B (move files under `plugins/convergence/`) — avoids cache-copy exclusion and matches docs walkthrough.
- **setup.sh**: Keep, reframe as developer mode in README — preserves live-edit loop for contributors.
- **Hook distribution**: Ship inside plugin at `plugins/convergence/hooks/hooks.json` — safer default, honors README's framing.
- **Marketplace name**: `csonnier` — scopes by owner, reads naturally, leaves namespace room.
- **Plugin name**: `convergence` — matches repo identity.
- **Install source**: `c-sonnier/convergence` GitHub shorthand — confirmed from git remote.
- **Version**: `1.0.0` for both marketplace and plugin — first marketplace release of mature content.
- **License**: `MIT` — matches existing LICENSE.
- **strict mode**: `true` (default) — plugin.json is authority.
- **Repo `.claude/` dir**: Delete entirely after moving contents — the plugin install handles everything; avoids duplicate hook firing for contributors working in this repo with convergence installed globally.

## Open Questions

None at this time. Ready for outlining if approved.

## Out of Scope

- Publishing to any npm registry (we're using relative-path source within the same git repo).
- Private-marketplace auth tokens (repo is public).
- Pre-populated seed directory for CI/containers (users can follow docs if they need this).
- Changing skill or agent internals — this is a distribution change only.
- `CLAUDE.md` at the repo root — only loaded when contributors work inside this repo; marketplace users don't see it.
