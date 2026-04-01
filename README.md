# Convergence

A consolidated set of skills, agents, and workflows for [Claude Code](https://claude.ai/code). Distilled from 6 open-source repos and validated against findings from the Coding Agents Summit 2026.

239+ original items → 14 focused tools. Every skill stays under 35 instructions.

## Install

```bash
git clone <repo-url> convergence
cd convergence
./setup.sh
```

This symlinks skills and agents into `~/.claude/skills/` and `~/.claude/agents/`. They'll be available in all your Claude Code sessions.

**Project-level install** (instead of global):

```bash
cd your-project
mkdir -p .claude/skills
ln -s /path/to/convergence/skills/* .claude/skills/
```

## What's Included

### Workflow Skills

Use these sequentially for features. Each phase writes a static artifact file — you can resume from any point.

| Skill | Instructions | Purpose |
|-------|-------------|---------|
| `/convergence-research` | 18 | Objective codebase exploration. Ticket-blind, fact-only |
| `/convergence-design` | 22 | Alignment discussion with the human. ~200 lines. Human decides |
| `/convergence-outline` | 16 | Vertical structure with phases, signatures, checkpoints |
| `/convergence-implement` | 24 | Execute outline phases with TDD and verification |
| `/convergence-review` | 28 | Code review on actual diff. Defaults to NEEDS WORK |

**Typical flows:**

```
Small feature:    /convergence-design → /convergence-implement → /convergence-review
Large feature:    /convergence-research → /convergence-design → /convergence-outline → /convergence-implement → /convergence-review
Bug fix:          /convergence-debug → /convergence-tdd
Pre-ship:         /convergence-review + /convergence-security
```

### Utility Skills

Use standalone, whenever the situation calls for them.

| Skill | Instructions | Purpose |
|-------|-------------|---------|
| `/convergence-debug` | 20 | Systematic root cause investigation. No fixes without understanding |
| `/convergence-tdd` | 14 | Test-driven development. Red-green-refactor |
| `/convergence-security` | 30 | Three-layer security audit: access, logging, scanning |
| `/convergence-architecture` | 22 | Layer analysis, callback scoring, god object detection, quality gates |

### Agents

Dispatched automatically by skills. You don't invoke these directly.

| Agent | Instructions | Dispatched By |
|-------|-------------|---------------|
| Research Agent | 10 | `/convergence-research` — runs ticket-blind in fresh context |
| Review Agent | 12 | `/convergence-review` — skeptical code reviewer |
| Security Agent | 14 | `/convergence-security` — vulnerability scanner |

### Safety Hooks

The `.claude/settings.json` includes a hook that warns before destructive commands (`rm -rf`, `DROP TABLE`, `git push --force`, `git reset --hard`). Copy it to your project's `.claude/settings.json` to enable.

## Design Principles

These aren't just guidelines — they're hard constraints that shaped every skill in this repo.

**Instruction Budget.** Every skill stays under 35 instructions. LLMs reliably follow ~150-200 instructions total. At 35 per skill plus system overhead, you can stack 2-3 skills without degradation.

**Human In The Loop.** Workflows force the agent to surface assumptions for human correction *before* writing code. No automated decision pipelines. The engineer makes design choices on a 200-line doc, not in 2,000 lines of code.

**Static Artifacts.** Every workflow phase writes output to a file. This survives context compaction, enables session resumption, and allows human review without context window dependency.

**Verify The Code.** Review actual code, not plans. "Confidence is not evidence." Run the command, read the output, then make the claim.

**Vertical Slicing.** Plans and implementations follow vertical slices (end-to-end with checkpoints), not horizontal layers (all DB, then all API, then all frontend). Each phase is independently testable.

**Codebase First.** Always scan existing patterns before proposing changes. Research is objective compression of truth — separate "what are we building" from "what exists."

**Security By Default.** Three layers: scoped credentials before starting, audit logging during, vulnerability scanning after.

## Context Budget

Keep your active instruction total under 60 per session. CLAUDE.md, system prompt, and tool definitions use ~80-100 of the ~200 instruction budget. That leaves ~100-120 for skills.

| Combination | Total Instructions |
|------------|-------------------|
| `/convergence-research` alone | 18 |
| `/convergence-design` alone | 22 |
| `/convergence-implement` + `/convergence-tdd` | 38 |
| `/convergence-review` alone | 28 |
| `/convergence-review` + `/convergence-security` | 58 |
| `/convergence-debug` + `/convergence-tdd` | 34 |

## Where It Comes From

Convergence consolidates patterns from 6 open-source repos:

- [superpowers-ruby](https://github.com/lucianghinda/superpowers-ruby) — Verification gates, TDD discipline, systematic debugging, brainstorming
- [gstack](https://github.com/garrytan/gstack) — Safety hooks, QA health scores, security auditing (OWASP + STRIDE), staff-engineer review
- [palkan/skills](https://github.com/palkan/skills) — Layered architecture analysis, callback scoring, god object detection, specification test
- [rails-conventions](https://github.com/ethos-link/rails-conventions) — Codebase-first scanning, code quality gates, fail-fast philosophy
- [counselors](https://github.com/aarondfrancis/counselors) — Multi-model dispatch, read-only enforcement, convergence detection
- [agency-agents](https://github.com/msitarzewski/agency-agents) — Reality Checker (skeptical verification), NEXUS orchestration, agent personas

Every pattern included appears in 3+ repos. Validated against the [Coding Agents Summit 2026](https://www.youtube.com/watch?v=YwZR6tc7qYg) ([detailed findings](docs/summit-findings.html)) from 10 speakers and data from 25T+ tokens across 1.5M developers.

## Docs

The `docs/` directory contains the full analysis chain:

- [analysis.html](docs/analysis.html) — Original comparative analysis of all 6 repos
- [summit-findings.html](docs/summit-findings.html) — Where summit findings contradict or validate the analysis
- [consolidated-toolkit.html](docs/consolidated-toolkit.html) — The convergence design document with rationale for every item

## Adoption Path

Don't install everything at once. Follow the trust ladder:

1. **Start with** `/convergence-review` + `/convergence-debug` + safety hooks — immediate value, no workflow change
2. **Add** `/convergence-design` for complex features — highest leverage single skill
3. **Add** `/convergence-research` + `/convergence-outline` for large features — prevents bias and horizontal plans
4. **Add** `/convergence-tdd` + `/convergence-security` as needed — invoke when the situation calls for it
5. **Add** `/convergence-architecture` for periodic health checks

## License

MIT
