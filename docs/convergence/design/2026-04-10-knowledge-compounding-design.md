# Design: Knowledge Compounding + Debug Enhancements
Date: 2026-04-10

## Current State

Convergence has 8 skills, 3 agents, and zero institutional learning. Every session starts from zero. Past bugs, root causes, architectural decisions, and gotchas are lost unless the human remembers them.

Artifacts exist at `docs/convergence/<phase>/YYYY-MM-DD-<topic>.md` for research, design, outline, review, architecture, and security. No `learnings/` directory exists.

The debug skill has 4 phases (investigate → analyze patterns → hypothesis → fix) with a 3-failure escalation to the human. It lacks causal chain gating, failure-type classification, and defense-in-depth checks.

Existing skills reference each other with short names (`/tdd`, `/debug`) instead of the registered `/convergence-<name>` form. This is a known bug to fix alongside this work.

## Desired End State

After solving a non-trivial bug or completing a feature, convergence captures what was learned in a structured, searchable format. Before starting new work, relevant past learnings surface automatically. The debug skill catches more root causes and fewer symptoms.

## Patterns to Follow

- Convergence artifact pattern (dated markdown in `docs/convergence/`) — CONFIRMED
- CE's `ce:compound` core idea (capture + surface loop) — CONFIRMED, stripped to lean style
- CE's YAML frontmatter for searchable metadata — CONFIRMED
- Summit finding: "Make correction easy" (Erin Ahmed) — CONFIRMED, drives the pre-filled draft approach
- CE's overlap detection (check for duplicates before writing) — CONFIRMED, simplified to human decision
- ~~CE's session history correlation~~ — REJECTED: too heavy, depends on tooling
- ~~CE's auto-memory integration~~ — REJECTED: orthogonal to convergence's static artifact model
- ~~CE's multi-mode execution (full/lightweight/enhanced)~~ — REJECTED: one mode, keep it simple
- ~~CE's parallel subagent dispatch~~ — REJECTED: instruction budget

## Approach

### Deliverable 1: `/convergence-compound` skill

**Trigger:** Manual invocation, nudged by other skills (Option B from design discussion).

- `/convergence-debug` suggests `/convergence-compound` when root cause was non-obvious (3+ hypotheses or architectural escalation)
- `/convergence-review` suggests `/convergence-compound` when must-fix findings revealed surprising issues

**Skill behavior:**

1. Read recent context: `git log` (last 5-10 commits), `git diff`, and any convergence artifacts from session (debug findings, review doc, design doc)
2. Infer and draft the full learning: title, what happened, root cause, fix, rule, and frontmatter metadata (problem_type, module, severity, tags)
3. Check for overlap: grep `docs/convergence/learnings/` for matching tags/module. If match found, show human: "This looks related to [existing learning]. Update that one, or create new?"
4. Present draft to human: "Here's what I captured. Change anything that's wrong, or approve."
5. Human corrects or approves
6. Write artifact to `docs/convergence/learnings/YYYY-MM-DD-<slug>.md`

**Artifact format:**

```markdown
---
problem_type: bug | architecture | performance | pattern | gotcha
module: <which part of the system>
severity: critical | high | medium | low
tags: [searchable, keywords]
---

# Learning: [Title]
Date: YYYY-MM-DD

## What Happened
[The problem or situation — facts only]

## Root Cause
[Why it happened — the actual cause, not symptoms]

## Fix
[What was done — file paths, approach]

## Rule
[The generalizable takeaway — one sentence if possible]
```

### Deliverable 2: `learnings-researcher` agent

**Dispatched by:**
- `/convergence-research` at the start of codebase exploration (before investigating questions)
- `/convergence-debug` at Phase 1 before root cause investigation begins

**Input:** Topic string or error description.

**Behavior:**
1. Grep `docs/convergence/learnings/` for matching keywords in frontmatter (tags, module, problem_type) and body
2. Read matched files, score relevance
3. Return compressed findings: file path, rule, and enough context to decide relevance
4. Under 50 lines — supplementary context, not main research
5. If nothing relevant, say so in one line

**Tools:** Grep, Glob, Read (same as research-agent — no Bash needed).

### Deliverable 3: Debug skill enhancements

Three additions to `/convergence-debug`, total ~6 instructions:

**Causal chain gate (Phase 2 addition):**
Before proposing any fix, explain the full chain from trigger to symptom. Every link must be accounted for — no "somehow X leads to Y." If a link is uncertain, state a prediction that must also be true if the link holds, then test the prediction.

**Smart escalation table (Phase 4 enhancement):**
When 3 hypotheses fail, classify the failure type:
- Hypotheses point to different subsystems → likely a design/architecture problem, suggest `/convergence-architecture`
- Evidence contradicts itself → wrong mental model, step back and re-read from scratch
- Works locally, fails in CI/prod → environment problem, compare configs
- Fix works but prediction was wrong → symptom fix only, real cause still active

**Defense-in-depth check (Phase 4 addition):**
After confirming root cause fix, grep for the same pattern in other files. If found, flag to the human: "Same pattern exists in [files]. Worth fixing there too?"

### Deliverable 4: Cross-reference fixes

Update all existing skills to use `/convergence-<name>` prefix when referencing other convergence skills. Update CLAUDE.md skill router if needed.

## Alternatives Considered

- **Full CE `ce:compound` port**: Rejected — 530 lines, 3 modes, parallel subagent dispatch. Blows instruction budget.
- **Human answers all questions from scratch**: Rejected — too much friction, people won't use it. Pre-filled drafts with correction is lower effort.
- **Mandatory `/convergence-compound` after every feature**: Rejected — adds friction to small changes that don't produce learnings worth capturing. Nudge-based is better.
- **Learnings-researcher as standalone skill**: Rejected — it's a supporting agent, not a user-facing workflow. Dispatched by other skills automatically.

## Resolved Decisions

- Lean convergence style, not CE heavy style — strip to core capture/surface loop
- Trigger via nudge from debug/review (Option B) — not mandatory, not manual-only
- Skill pre-fills draft from git context, human corrects — make correction easy
- Overlap detection via human decision — grep for matches, ask human, no auto-merge
- Agent dispatched by research and debug — the two moments past learnings save most time
- Debug enhancements included — causal chain gate, smart escalation, defense-in-depth
- All cross-references use `/convergence-<name>` prefix

## Open Questions

None — all decisions resolved.
