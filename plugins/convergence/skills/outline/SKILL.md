---
name: convergence-outline
description: "Vertical structure outline with phases and checkpoints. Use after /convergence-design approval. Produces a ~2-page outline showing phases, file changes, signatures, and verification steps. Enforces vertical slicing — each phase is end-to-end testable."
---

# Structure Outline

Produce a ~2-page structure outline — the "C header file" for the implementation. Not the exact code, but the phases, types, signatures, and verification checkpoints.

## The Rule

```
EVERY PHASE MUST BE A VERTICAL SLICE — END-TO-END AND TESTABLE.
```

Models default to horizontal plans (all DB, then all services, then all frontend). This produces 1,200+ lines with nothing testable until the end. Fight this explicitly.

## When to Use

- After `/convergence-design` approval for multi-phase features
- Skip for single-file changes or bug fixes

## Process

### Step 1 — Load Context

Read the approved design document. Optionally load the research document for reference.

### Step 2 — Break Into Vertical Phases

Each phase must:
- Touch all layers needed for that slice (model + service + controller + view if needed)
- Produce something testable when complete
- Be independent enough that if the next phase fails, this phase's work still stands

**Vertical (correct):**
```
Phase 1: Mock API endpoint + wire frontend for happy path
Phase 2: Real database + service for happy path
Phase 3: Error handling + edge cases
Phase 4: Authorization + security
```

**Horizontal (wrong — do not do this):**
```
Phase 1: Database migration (all tables)
Phase 2: All service classes
Phase 3: All API endpoints
Phase 4: All frontend views
Phase 5: All tests
```

### Step 3 — Detail Each Phase

For each phase, list:
1. **Files to change** — specific paths
2. **New types/signatures** — what's being added (not full implementation, just the shape)
3. **Verification checkpoint** — what command to run and what output to expect

### Step 4 — Write Outline

Write to `docs/convergence/outline/YYYY-MM-DD-<topic>-outline.md`.

**Format:**
```markdown
# Outline: [Feature Name]
Date: YYYY-MM-DD
Design: [link to design doc]

## Phase 1: [Name — what this slice delivers]
**Files:**
- `path/to/model.rb` — add [field/method]
- `path/to/controller.rb` — add [action]
- `path/to/view.html` — add [element]

**New signatures:**
- `Model#method_name(arg: Type) -> ReturnType`
- `Controller#action`

**Verify:**
```
[exact command to run]
[expected output or pass criteria]
```

## Phase 2: [Name]
...

## Phase 3: [Name]
...
```

**Constraints:**
- Under 80 lines — this is an outline, not a plan
- No implementation code — just shapes and signatures
- Every phase has a verification checkpoint

### Step 5 — Human Review

Ask the human to review the phase order and structure.

> "Outline written to `<path>`. Does the phase order make sense? Want to swap, merge, or add any phases?"

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| All database first, then all services | Horizontal — nothing testable until the end | Vertical slices touching all needed layers |
| 200-line outline | Too detailed — just write the code | Under 80 lines, shapes only |
| Skipping verification checkpoints | No way to catch problems between phases | Every phase needs a "run this, expect that" |
| "Phase 5: Write all tests" | Tests should be part of each phase, not a final phase | Tests are written during implementation per phase |
| One giant phase | Defeats the purpose of incremental verification | Break into slices small enough to verify independently |
