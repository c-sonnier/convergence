# Outline: Convergence Plugin Marketplace
Date: 2026-04-13
Design: `docs/convergence/design/2026-04-13-plugin-marketplace-design.md`

## Phase 1: Bootstrap marketplace with one skill
Prove the whole install flow works end-to-end with minimal content before mass-moving files.

**Files:**
- `.claude-plugin/marketplace.json` — new; marketplace manifest with one plugin entry
- `plugins/convergence/.claude-plugin/plugin.json` — new; plugin manifest
- `plugins/convergence/skills/research/SKILL.md` — `git mv` from `skills/research/SKILL.md`

**New shapes:**
- `marketplace.json`: `{ name: "csonnier", owner, metadata, plugins: [{ name: "convergence", source: "./plugins/convergence", description }] }`
- `plugin.json`: `{ name: "convergence", version: "1.0.0", author, license: "MIT", homepage, repository, keywords }`

**Verify:**
```
claude plugin validate .
# Expect: validation passes, no errors
/plugin marketplace add ./
/plugin install convergence@csonnier
/convergence-research
# Expect: skill available and runs
```

## Phase 2: Port remaining 9 skills
All skills ship via the plugin; `skills/` at repo root is emptied.

**Files:**
- `plugins/convergence/skills/{architecture,compound,debug,design,implement,outline,review,security,tdd}/SKILL.md` — `git mv` from `skills/<name>/SKILL.md`
- `skills/` directory — deleted after all 10 moved

**Verify:**
```
claude plugin validate .
/plugin marketplace update
# Expect: all 10 /convergence-<name> skills available (research + 9 ported)
```

## Phase 3: Port 4 agents
Agents ship with the plugin.

**Files:**
- `plugins/convergence/agents/{research-agent,review-agent,security-agent,learnings-researcher}.md` — `git mv` from `.claude/agents/<name>.md`
- `.claude/agents/` directory — deleted after all 4 moved

**Verify:**
```
claude plugin validate .
/plugin marketplace update
# Expect: agents visible in plugin's agent list (check via /plugin or similar)
# Dispatch check: run /convergence-research on a sample topic — research-agent dispatches without error
```

## Phase 4: Port safety hook, delete root .claude/
Hook ships inside the plugin. Repo root `.claude/` directory removed entirely.

**Files:**
- `plugins/convergence/hooks/hooks.json` — new; contents migrated from `.claude/settings.json`
- `.claude/settings.json` — deleted
- `.claude/` — deleted (empty after Phase 3 + this)

**New shapes:**
- `hooks.json`: `{ PreToolUse: [{ matcher: "Bash", hooks: [{ type: "command", command: "..." }] }] }`

**Verify:**
```
claude plugin validate .
/plugin marketplace update
# In a test shell inside Claude Code, attempt: rm -rf some-test-dir
# Expect: "WARN: Destructive command detected" appears on stderr before prompt
```

## Phase 5: Update setup.sh and README
Developer mode continues working; docs lead with marketplace install.

**Files:**
- `setup.sh` — update `CONVERGENCE_DIR` path references from `skills/` to `plugins/convergence/skills/` and `.claude/agents/` to `plugins/convergence/agents/`
- `README.md` — rewrite `## Install` to lead with marketplace commands; add `## Developer mode` section referencing `setup.sh`

**Verify:**
```
./setup.sh
ls -la ~/.claude/skills/convergence-research
# Expect: symlink resolves to plugins/convergence/skills/research
# Verify README: install commands copy-paste cleanly into a fresh Claude Code session
```
