---
name: convergence-compound
description: "Capture what was learned after solving a bug or completing a feature. Reads recent git context, drafts a structured learning, and asks the human to correct or approve. Writes searchable artifacts to docs/convergence/learnings/."
---

# Compound Learning

After solving a non-trivial problem, capture what was learned so it compounds over time.

## The Rule

```
THE AGENT DRAFTS. THE HUMAN CORRECTS.
```

Pre-fill every field from available context. The human's job is to fix what's wrong, not write from scratch.

## When to Use

- After `/convergence-debug` finds a non-obvious root cause
- After `/convergence-review` surfaces surprising findings
- After completing any work where the root cause, fix, or pattern wasn't obvious
- When nudged by another skill ("Consider running `/convergence-compound`")

## Process

### Step 1 — Gather Context

Read recent work artifacts:

```bash
git log --oneline -10
git diff HEAD~3..HEAD --stat
```

Also check for convergence artifacts from this session:
- `docs/convergence/reviews/` — recent review findings
- `docs/convergence/research/` — research context
- Debug output if visible in conversation

### Step 2 — Draft the Learning

From the gathered context, draft a complete learning with all fields:

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

**Inference guidance:**
- `problem_type`: bug if it was broken, architecture if structural, performance if slow, pattern if a reusable approach, gotcha if a non-obvious trap
- `module`: infer from the files changed
- `tags`: extract from error messages, framework names, pattern names
- `Rule`: the hardest field — generalize beyond this specific instance. "Always X when Y" or "Never X because Y" format works well. This field will often be wrong. That's fine — the human correcting it is the highest-value moment.

### Step 3 — Check for Overlap

Before writing, search for existing learnings with similar content:

```bash
grep -rl "<primary-tag>" docs/convergence/learnings/ 2>/dev/null
grep -rl "<module>" docs/convergence/learnings/ 2>/dev/null
```

If matches are found, read them and present to the human:

> "This looks related to [existing learning title] (`path`). Should I update that one or create a new learning?"

If no matches or the human chooses "create new," proceed to Step 4.

### Step 4 — Present for Correction

Show the full draft to the human:

> "Here's what I captured from this work. Change anything that's wrong, or approve to save."

Wait for the human to review. They may:
- Approve as-is
- Correct specific fields (especially `Rule` — this is expected)
- Reject entirely (rare — respect it, don't push)

### Step 5 — Write Artifact

Write to `docs/convergence/learnings/YYYY-MM-DD-<slug>.md`.

Create the `docs/convergence/learnings/` directory if it doesn't exist.

Confirm:

> "Learning saved to `<path>`. This will surface next time `/convergence-research` or `/convergence-debug` runs in a related area."

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| Asking the human to write from scratch | Too much friction, they won't do it | Pre-fill everything, ask for corrections |
| Vague rule ("be careful with X") | Not actionable in future | Specific: "Always check X before Y because Z" |
| Capturing obvious things | Noise drowns out signal | Only capture what was non-obvious or surprising |
| Skipping overlap check | Creates duplicates that dilute search | Always grep before writing |
| Long narrative in What Happened | Future reader needs facts fast | Keep each section to 2-4 lines |
