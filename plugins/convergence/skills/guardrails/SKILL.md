---
name: convergence-guardrails
description: "Define and codify project-level architectural invariants, scope boundaries, and non-negotiable rules. Produces ARCHITECTURE.md — the persistent constraint file that shapes every AI interaction. Use once per project or when architectural drift is detected."
---

# Architectural Guardrails

Define the rules that constrain every future code change. AI follows architectural constraints if you write them down — it won't invent them for you.

## The Rule

```
THE HUMAN DEFINES THE ARCHITECTURE. THE AGENT CODIFIES IT.
```

This skill produces constraints, not analysis. For analysis, use `/convergence-architecture` first.

## When to Use

- Starting a new project (before any feature work)
- After `/convergence-architecture` reveals structural problems
- When architectural drift is detected during review
- When onboarding AI to an existing codebase with established patterns

## Process

### Step 1 — Assess Current State

Check for existing architectural artifacts:

```bash
cat ARCHITECTURE.md 2>/dev/null
grep -i "architecture\|invariant\|constraint" CLAUDE.md 2>/dev/null
```

If an architecture analysis exists in `docs/convergence/architecture/`, read it. If not, do a quick structural scan:

```bash
find . -type f -name "*.rb" -o -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" | head -50
```

Map the codebase to its primary components and their relationships.

### Step 2 — Identify Invariants

Ask the human to define the non-negotiable rules for this codebase. Guide with targeted questions, **one at a time**:

1. **Component boundaries** — "Which components should never depend on each other?"
2. **State ownership** — "Where does state live? What is allowed to mutate it?"
3. **Data flow direction** — "How should data move between layers? Top-down only?"
4. **Extension pattern** — "When adding a new [view/endpoint/module], should it require modifying existing ones?"
5. **Concurrency rules** — "Are there threading or async constraints?" (skip if not applicable)
6. **Data modeling** — "Should structured data stay typed, or is flattening to strings/arrays acceptable?"

Not every question applies to every project. Skip what's irrelevant. The goal is 3-10 concrete rules, not an exhaustive specification.

### Step 3 — Define Scope Boundaries

Ask the human:

> "What is this project NOT? What features or directions are explicitly rejected?"

Record:
- **Target users** — who this is for
- **Supported scope** — what it does (named, specific)
- **Rejected scope** — what it deliberately does NOT do
- **Rejection criteria** — how to evaluate future feature requests

Frame as: "Velocity makes everything feel cheap. These boundaries exist because complexity budget is finite even when line budget isn't."

### Step 4 — Draft Rules

Write each invariant as a concrete, enforceable rule. Not vague principles — specific constraints that can be checked against code.

**Good rules:**
- "Each view implements the View interface and does NOT access other views' state"
- "All async data arrives via typed message variants on the main loop"
- "Adding a new endpoint MUST NOT require modifying existing endpoint files"
- "Never flatten structured data into positional arrays — use typed structs"

**Bad rules (too vague — rewrite these):**
- "Keep code clean"
- "Follow best practices"
- "Use good architecture"
- "Be careful with state"

### Step 5 — Write ARCHITECTURE.md

Write to `ARCHITECTURE.md` in the project root.

**Format:**
```markdown
# Architecture

## Invariants

Rules that apply to every code change. Violating these requires explicit human approval.

- [Rule 1]
- [Rule 2]
- [Rule 3]

## Component Boundaries

[Which components exist, how they relate, what depends on what]

## Data Flow

[How data moves through the system — direction, typed vs untyped, sync vs async]

## Scope

### This project IS
[Specific, named scope]

### This project is NOT
[Explicitly rejected directions]

### Feature rejection criteria
[How to evaluate "should we add X?"]
```

Keep it under 60 lines. This file is loaded by other skills — bloat costs instruction budget.

### Step 6 — Update CLAUDE.md

Check if CLAUDE.md already references ARCHITECTURE.md. If not, add a single directive:

```markdown
## Architecture
Read ARCHITECTURE.md before modifying code. Do not violate the invariants defined there without explicit human approval.
```

Place it near the top of the project-specific CLAUDE.md so it's visible early.

### Step 7 — Human Review

Present the full ARCHITECTURE.md for approval:

> "ARCHITECTURE.md written. Review the invariants and scope boundaries — these will constrain every future code change. Anything to add, remove, or reword?"

## Key Principles

- **Concrete over vague** — "Each X implements interface Y" beats "use good patterns"
- **3-10 rules** — fewer than 3 isn't constraining enough, more than 10 won't be followed
- **Under 60 lines** — this is a constraint file, not a design doc
- **The shortest path insight** — AI picks the easiest path from prompt to working code; these rules change which path is easiest

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| Writing rules without asking the human | Agent doesn't know the architecture — human does | Ask questions, codify answers |
| Vague principles ("keep it clean") | Can't be checked against code | Specific: "X must not depend on Y" |
| 30+ rules | Won't be followed — instruction budget is finite | Prioritize to 3-10 |
| Skipping scope boundaries | Velocity will expand scope without them | Always define what you're NOT building |
| Never updating | Architecture evolves | Re-run when drift is detected or after major features |
| Putting full architecture docs in CLAUDE.md | Wastes instruction budget on every interaction | ARCHITECTURE.md + one-line reference |
