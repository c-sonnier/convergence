# Research: Plugin Marketplace for Convergence
Date: 2026-04-13

Source: https://code.claude.com/docs/en/plugin-marketplaces (fetched 2026-04-13).

## Questions Investigated

1. What does the official Claude Code documentation specify for marketplace.json structure, required fields, and hosting?
2. What plugin types exist in convergence today and how are they organized on disk?
3. How is convergence currently distributed and installed?
4. What is the top-level directory structure of the convergence repo?
5. How do convergence's existing skills, agents, and hooks map to the plugin manifest schema?
6. What git history exists for distribution-related files?

## Findings

### Q1 — Marketplace file specification

A marketplace is defined by `.claude-plugin/marketplace.json` at the repository root. Plugins live in subdirectories (typically `plugins/<name>/`), each containing its own `.claude-plugin/plugin.json`.

**Marketplace schema — required fields:**

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | kebab-case, no spaces. Public-facing (`/plugin install x@<name>`). |
| `owner` | object | `name` (required), `email` (optional). |
| `plugins` | array | List of plugin entries. |

**Optional metadata:** `metadata.description`, `metadata.version`, `metadata.pluginRoot` (base dir prepended to relative plugin sources).

**Reserved marketplace names** (cannot be used by third parties): `claude-code-marketplace`, `claude-code-plugins`, `claude-plugins-official`, `anthropic-marketplace`, `anthropic-plugins`, `agent-skills`, `knowledge-work-plugins`, `life-sciences`. Names that impersonate official marketplaces are also blocked.

**Plugin entry — required fields:** `name` (kebab-case), `source` (string or object).

**Plugin entry — optional fields:** `description`, `version`, `author` (`name`/`email`), `homepage`, `repository`, `license` (SPDX), `keywords`, `category`, `tags`, `strict`, plus component fields `skills`, `commands`, `agents`, `hooks`, `mcpServers`, `lspServers`.

**Plugin source types:**

| Source | Form | Fields |
|--------|------|--------|
| Relative path | string starting with `./` | none. Resolved from marketplace root. No `../`. |
| `github` | object | `repo` (required, `owner/repo`), `ref?`, `sha?` |
| `url` | object | `url` (required, https or git@), `ref?`, `sha?` |
| `git-subdir` | object | `url`, `path` (required), `ref?`, `sha?`. Sparse clone. |
| `npm` | object | `package` (required), `version?`, `registry?` |

**Strict mode:** `strict: true` (default) means `plugin.json` is the authority and the marketplace entry can supplement components. `strict: false` means the marketplace entry is the entire definition and the plugin must not declare conflicting components in its own `plugin.json`.

**Hosting:**
- GitHub (recommended): users add via `/plugin marketplace add owner/repo`.
- Other git hosts: users add via `/plugin marketplace add https://gitlab.com/team/plugins.git`.
- Local path (testing): `/plugin marketplace add ./my-marketplace`.
- Direct URL to `marketplace.json`: works, but relative-path plugin sources will fail (only the JSON is downloaded, not plugin files).
- Private repos: uses git credential helpers for manual ops; auto-updates need `GITHUB_TOKEN`/`GITLAB_TOKEN`/`BITBUCKET_TOKEN` env vars.

**User-facing install commands:**

```
/plugin marketplace add <source>
/plugin install <plugin-name>@<marketplace-name>
/plugin marketplace update [name]
/plugin marketplace remove <name>
/plugin marketplace list
/plugin validate .
```

CLI equivalents exist as `claude plugin marketplace <subcommand>`.

**Validation:** `claude plugin validate .` or `/plugin validate .` checks `plugin.json`, frontmatter, and `hooks/hooks.json`. Common errors include duplicate plugin names, `..` in source paths, and invalid YAML frontmatter.

**Relative-path constraint:** Relative paths only work when the marketplace is added via Git or local path, not via direct URL to `marketplace.json`.

**File resolution:** Plugins are copied to `~/.claude/plugins/cache` on install. Plugins cannot reference files outside their own directory. Use `${CLAUDE_PLUGIN_ROOT}` in hooks and MCP configs to refer to plugin-internal files. Use `${CLAUDE_PLUGIN_DATA}` for state that must survive updates.

**Walkthrough directory structure** (verbatim from docs):

```
my-marketplace/
  .claude-plugin/
    marketplace.json
  plugins/
    quality-review-plugin/
      .claude-plugin/
        plugin.json
      skills/
        quality-review/
          SKILL.md
```

**Walkthrough marketplace.json** (verbatim):

```json
{
  "name": "my-plugins",
  "owner": { "name": "Your Name" },
  "plugins": [
    {
      "name": "quality-review-plugin",
      "source": "./plugins/quality-review-plugin",
      "description": "Adds a /quality-review skill for quick code reviews"
    }
  ]
}
```

**Walkthrough plugin.json** (verbatim):

```json
{
  "name": "quality-review-plugin",
  "description": "Adds a /quality-review skill for quick code reviews",
  "version": "1.0.0"
}
```

**Team-defaults setting** (`.claude/settings.json` in a project):

```json
{
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "your-org/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "code-formatter@company-tools": true
  }
}
```

### Q2 — Convergence components on disk

**Skills** (`skills/<name>/SKILL.md`, 10 total):

```
skills/architecture/SKILL.md
skills/compound/SKILL.md
skills/debug/SKILL.md
skills/design/SKILL.md
skills/implement/SKILL.md
skills/outline/SKILL.md
skills/research/SKILL.md
skills/review/SKILL.md
skills/security/SKILL.md
skills/tdd/SKILL.md
```

Each `SKILL.md` has YAML frontmatter with `name` and `description`. Example from `skills/research/SKILL.md`:

```yaml
---
name: convergence-research
description: "Objective codebase exploration. Use before designing a new feature or change..."
---
```

The frontmatter `name` already carries the `convergence-` prefix.

**Agents** (`.claude/agents/<name>.md`, 4 total):

```
.claude/agents/learnings-researcher.md
.claude/agents/research-agent.md
.claude/agents/review-agent.md
.claude/agents/security-agent.md
```

Each agent file has frontmatter with `name` and `description`. Agent files do not currently carry a `convergence-` prefix in their `name` frontmatter.

**Hooks** (`.claude/settings.json`):

A single `PreToolUse` hook on `Bash` that warns on destructive commands (`rm -rf`, `DROP TABLE`, `git push --force`, `git reset --hard`, etc.). Defined inline in the project `.claude/settings.json`.

**No MCP servers, no LSP servers, no commands defined as flat .md files.**

### Q3 — Current distribution mechanism

Distribution is a shell script: `setup.sh` (65 lines).

Behavior (from `setup.sh:1-64`):
- Resolves install target from `CLAUDE_CONFIG_DIR` env var (default `$HOME/.claude`).
- Creates `$CLAUDE_CONFIG_DIR/skills/` and `$CLAUDE_CONFIG_DIR/agents/`.
- For each skill in `(research design outline implement review debug tdd compound security architecture)`: removes any existing `convergence-<skill>` entry and symlinks `<repo>/skills/<skill>` to `$CLAUDE_CONFIG_DIR/skills/convergence-<skill>`.
- For each agent in `(research-agent review-agent security-agent learnings-researcher)`: symlinks `<repo>/.claude/agents/<agent>.md` to `$CLAUDE_CONFIG_DIR/agents/convergence-<agent>.md`.
- The `convergence-` prefix is applied at the symlink target name, not in the source directory names.

Project-level install instructions in README.md (lines 25-29):

```bash
cd your-project
mkdir -p .claude/skills
ln -s /path/to/convergence/skills/* .claude/skills/
```

### Q4 — Repo top-level structure

```
convergence/
  .claude/
    agents/         (4 agent .md files)
    settings.json   (destructive-command hook)
  docs/
    analysis.html
    consolidated-toolkit.html
    summit-findings.html
    convergence/    (artifacts dir created by skills)
  skills/           (10 skill dirs, each with SKILL.md)
  CLAUDE.md
  LICENSE           (MIT)
  README.md
  setup.sh
```

No existing `.claude-plugin/` directory at any level. No existing `plugin.json` files. No `commands/` directory.

### Q5 — Mapping convergence components to plugin schema

From the marketplace plugin entry schema (`skills`, `agents`, `hooks` fields accept paths relative to the plugin root):

- Skills: SKILL.md files in convergence sit at `skills/<name>/SKILL.md`. The plugin schema's `skills` field expects directories containing `<name>/SKILL.md`, so a single `skills` entry pointing at the plugin's `skills/` directory matches the existing layout.
- Agents: `.claude/agents/<name>.md` is the convergence layout. The plugin schema's `agents` field accepts an array of file paths or directory paths.
- Hooks: convergence's hook is currently inline in `.claude/settings.json`. The plugin schema accepts either inline `hooks` configuration in the marketplace entry or a path to a `hooks/hooks.json` file.

The `convergence-` prefix currently applied at install time by `setup.sh` is not a plugin-system concept. Skill names come from each `SKILL.md` frontmatter; the `convergence-` prefix is already embedded there (verified in `skills/research/SKILL.md:2`).

### Q6 — Git history for distribution files

```
639ba01 feat: support CLAUDE_CONFIG_DIR env var in setup.sh         (most recent)
98c670c docs: add compound-engineering as 7th repo to analysis page
c806249 feat: add knowledge compounding skill, learnings-researcher agent, and debug enhancements
750a20d docs: update README skill names to match convergence- prefix
89b8507 fix: add convergence- prefix to skill names in frontmatter
b13f702 fix: add correct repo URLs and summit video link to README
b266f70 feat: initial release of Convergence
```

Initial release (`b266f70`) added all 10 skills (compound was added later in `c806249`), 3 of the 4 agents (learnings-researcher added in `c806249`), `setup.sh`, `.claude/settings.json`, and the README. Most recent change (`639ba01`) added `CLAUDE_CONFIG_DIR` support to `setup.sh` and is associated with `docs/convergence/design/2026-04-13-multi-config-install-design.md`.

## Existing Patterns

- **Single-prefix namespace.** Every skill is invoked as `/convergence-<name>`; every agent file is named `convergence-<agent>.md` after install. The prefix is added at install time, not stored in the on-disk skill directory names.
- **Symlink-based install.** Source files live in the repo; install creates symlinks into `~/.claude/skills` and `~/.claude/agents`. Editing source files affects the install live.
- **Project-scoped settings file.** `.claude/settings.json` carries one hook; the README documents copying it into a target project.
- **Static artifact directories.** Skills write outputs to `docs/convergence/<phase>/` paths defined in CLAUDE.md.

## Code Health

- README.md (148 lines) documents install, included items, design principles, context budget, and adoption path.
- CLAUDE.md (3,518 bytes) documents the skill router and artifact paths.
- setup.sh is 65 lines, idempotent (removes existing entries before symlinking).
- All 10 skill SKILL.md files have frontmatter `name` of the form `convergence-<skill>`.
- All 4 agent files have frontmatter `name` matching the file basename without `convergence-` prefix.
- `docs/convergence/learnings/` does not exist yet.

## Dependencies

- No package manager or lockfile in the repo.
- Bash (for `setup.sh`); requires `ln`, `mkdir`, `rm`.
- Git (for distribution as a marketplace via GitHub/git URL).
- Claude Code's plugin system requires version that supports `/plugin marketplace add` and `.claude-plugin/marketplace.json`.

## Notes Specific to a Convergence Marketplace

Facts directly relevant to a future design phase:

- **Single-plugin vs. multi-plugin layout.** The marketplace schema permits either: one plugin that bundles all 10 skills and 4 agents, or multiple plugins (e.g., one per workflow group: workflow, utility, agents). Both are valid per the schema.
- **Naming conflict potential.** "convergence" is not in the reserved-name list. A marketplace `name` of `convergence` is currently allowed.
- **Source type for self-hosting.** Hosting the marketplace and plugin in the same repo permits `"source": "./plugins/<name>"` (relative path). Hosting plugins in separate repos requires `github` or `url` source objects.
- **Coexistence with `setup.sh`.** Marketplace install copies plugin files to `~/.claude/plugins/cache`; the existing `setup.sh` symlinks into `~/.claude/skills` and `~/.claude/agents`. Both could coexist on a user's machine, producing two registrations of the same skills under different names.
- **Hook portability.** The current hook lives in the repo's `.claude/settings.json` (project scope). To ship via plugin, it can move to `hooks/hooks.json` inside a plugin directory or be declared inline under `hooks` in the marketplace entry. The hook references no plugin-internal files; `${CLAUDE_PLUGIN_ROOT}` is not needed.
- **Strict mode default.** With `strict: true` (default), each plugin needs its own `plugin.json` and the marketplace entry can supplement. With `strict: false`, the marketplace entry alone defines components and the plugin must not declare its own.
- **Validation tooling.** `claude plugin validate .` is the documented validator and runs against the marketplace root.
