# Design: Multi-Config Install for setup.sh
Date: 2026-04-13

## Current State

Two Claude Code configs share the same convergence repo via symlinks:

- `gsd` alias → uses default `~/.claude/`
  - `~/.claude/skills/`: 9 convergence skills symlinked to repo (missing `convergence-compound`)
  - `~/.claude/agents/`: 3 convergence agents symlinked (missing `convergence-learnings-researcher`)
  - Also contains `fizzy` (unrelated, hand-placed)
- `gsd-work` alias → uses `CLAUDE_CONFIG_DIR=~/.claude-work`
  - `~/.claude-work/skills/`: same 9 skills (missing `convergence-compound`)
  - `~/.claude-work/agents/`: same 3 agents (missing `convergence-learnings-researcher`)

`setup.sh` hard-codes `$HOME/.claude/skills` and `$HOME/.claude/agents`. The `SKILLS` and `AGENTS` arrays already include `compound` and `learnings-researcher`, so both would install if setup.sh were re-run — but it only targets one config dir.

The `~/.claude-work/` skills were set up manually at some earlier point and have drifted behind.

## Desired End State

- `setup.sh` respects `CLAUDE_CONFIG_DIR` env var, defaulting to `$HOME/.claude`
- Running `./setup.sh` installs to `~/.claude/` (default)
- Running `CLAUDE_CONFIG_DIR=~/.claude-work ./setup.sh` installs to `~/.claude-work/`
- Both configs end up with all 10 skills and 4 agents symlinked to the repo
- README documents the dual-install pattern

## Patterns to Follow

- **Env var config switching** (found in `~/.zshrc` alias `gsd-work`) — CONFIRMED. Matches Claude Code's own convention.
- **Symlinks into config dirs** (found in both `~/.claude/skills/` and `~/.claude-work/skills/`) — CONFIRMED. Edit-once propagation.
- ~~**Merging settings.json**~~ — REJECTED: out of scope, messier than directory symlinks.

## Approach

Modify `setup.sh` to derive `SKILLS_DIR` and `AGENTS_DIR` from `CLAUDE_CONFIG_DIR` (default `$HOME/.claude`). Print the target dir at the top so the user sees which config they're installing into. Update README with a one-liner showing the dual install.

### Alternatives Considered

- **Flag-based (`--config-dir`)**: more explicit but diverges from the `CLAUDE_CONFIG_DIR` convention already in use. Rejected.
- **Auto-install to both when `~/.claude-work/` exists**: clever but surprising. Explicit env var is clearer. Rejected.
- **Separate `setup-work.sh` script**: duplicates logic. Rejected.

## Resolved Decisions

- **Config dir via env var**: `CLAUDE_CONFIG_DIR`, default `$HOME/.claude` — matches the `gsd-work` alias pattern
- **Settings.json propagation**: out of scope — focused change, JSON merging is a separate problem
- **Re-running for second dir**: manual (`CLAUDE_CONFIG_DIR=~/.claude-work ./setup.sh`) — explicit, no magic

## Open Questions

None. Ready for outline.

## Files to Change

- `setup.sh` — read `CLAUDE_CONFIG_DIR`, derive skill/agent paths, echo target
- `README.md` — add a line in the Install section showing the dual-install command

## Out of Scope

- Syncing `fizzy` or other non-convergence skills between configs
- Merging `.claude/settings.json` into either config
- Auto-detecting and installing to all `~/.claude*` dirs
