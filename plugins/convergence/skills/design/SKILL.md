---
name: convergence-design
description: "Collaborative alignment discussion with the human. Use after /convergence-research (or directly for smaller features). Produces a ~200-line design document. The human makes all design decisions — the agent surfaces assumptions, patterns, and open questions."
---

# Design Discussion

Produce a ~200-line design document through collaborative dialogue. This is the highest-leverage point in the workflow: catch wrong assumptions here, not in 2,000 lines of code.

## The Rule

```
DO NOT PROCEED TO IMPLEMENTATION UNTIL THE HUMAN APPROVES THE DESIGN.
```

No exceptions. Not even for "simple" changes. Simple changes are where unexamined assumptions cause the most wasted work.

## When to Use

- After `/convergence-research` for larger features
- Directly (without research) for well-understood changes
- Any time you're about to write code that touches multiple files or introduces new patterns

## Process

### Step 1 — Load Context

Read the research document (if one exists) and the ticket/feature description.

### Step 2 — Present Current State

Describe what exists today that's relevant to this change. Be specific: file paths, patterns, data flow. This grounds the discussion in reality.

### Step 3 — Present Desired End State

Describe what the solution should look like when done. Not the steps to get there — the final picture.

### Step 4 — Load Architectural Constraints

If `ARCHITECTURE.md` exists in the project root, read it. Check the proposed feature against:
- **Invariants** — does this feature require violating any? Flag it immediately.
- **Scope boundaries** — does this feature fall within defined scope or outside it?
- **Component boundaries** — does this feature respect ownership rules?

If a violation is necessary, surface it explicitly:

> "This feature would violate invariant X. Should we proceed anyway, or adjust the approach?"

### Step 5 — Surface Patterns

List the patterns found in the codebase that are relevant. Ask the human:

> "Are these the right patterns to follow?"

This is where you catch bad patterns. The codebase may have multiple ways to do the same thing. The human knows which are current and which are legacy.

### Step 6 — Propose Approaches

Present 2-3 approaches with trade-offs. Lead with your recommendation and why. Keep it conversational, not formal.

### Step 7 — Ask Open Questions

Ask questions **one at a time** about things you don't know or ambiguities that need human input. Prefer multiple choice when possible.

Do not batch questions. One per message. Wait for the answer before asking the next.

### Step 8 — Record Decisions

As the human makes decisions, record them in the design document. Each decision gets a one-line rationale.

### Step 9 — Write Design Document

Write to `docs/convergence/design/YYYY-MM-DD-<topic>-design.md`.

**Format:**
```markdown
# Design: [Feature Name]
Date: YYYY-MM-DD

## Current State
[What exists today. File paths, patterns, constraints.]

## Desired End State
[What the solution looks like when done.]

## Patterns to Follow
- [Pattern] (found in path/to/file) — CONFIRMED
- ~~[Pattern]~~ (found in path/to/other) — REJECTED: [reason]

## Approach
[Chosen approach with rationale]

### Alternatives Considered
- [Option B]: [why not chosen]
- [Option C]: [why not chosen]

## Resolved Decisions
- [Decision]: [choice] — [rationale]

## Open Questions
- [Anything still unresolved]
```

### Step 10 — Human Approval

Ask the human to review and approve before proceeding.

> "Design written to `<path>`. Review it and let me know if you want changes before we move to outlining the implementation."

## Key Principles

- **One question at a time** — don't overwhelm
- **Multiple choice preferred** — easier to answer than open-ended
- **YAGNI ruthlessly** — remove unnecessary features from all designs
- **Surface bad patterns** — don't silently follow the wrong pattern
- **Keep under 200 lines** — this is alignment, not specification

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| Writing the design without asking questions | Outsources thinking to the agent | Ask questions, let the human decide |
| Asking 5 questions at once | Overwhelms, gets shallow answers | One at a time |
| "I'll just start coding, it's simple" | Simple changes have hidden assumptions | Write a short design (even 20 lines) and get approval |
| Including implementation details | Design is "where are we going," not "how do we get there" | Save implementation for /convergence-outline |
| Silently following a bad pattern | The human might not know the pattern exists | Surface it and ask |
