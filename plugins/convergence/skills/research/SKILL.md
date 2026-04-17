---
name: convergence-research
description: "Objective codebase exploration. Use before designing a new feature or change. Produces a compressed, fact-only research document. The research context never sees the ticket — a separate step generates questions, this skill answers them."
---

# Codebase Research

Explore the codebase to produce a compressed, objective research document.

## The Rule

```
RESEARCH IS FACTS, NOT OPINIONS.
```

If the output contains "should," "could," "recommend," or "I suggest" — delete it and rephrase as a fact about what exists.

## When to Use

- Before `/convergence-design` on any non-trivial feature
- When onboarding to an unfamiliar area of the codebase
- When you need to understand how something works before changing it

## Process

### Step 1 — Generate Questions (separate from research)

Before researching, generate 3-7 targeted questions from the ticket or feature description. These questions should cause the research to touch all relevant parts of the codebase.

Example: For "add endpoint to reticulate splines across tenants":
- How do endpoints work in this codebase? Trace a request through the stack.
- Where is spline logic? What models, services, and tests touch splines?
- How does multi-tenancy work? How are tenant boundaries enforced?

**Write questions only. Do not start researching yet.**

### Step 1.5 — Check Past Learnings

Before researching, dispatch the `learnings-researcher` agent with the topic description. If relevant learnings exist in `docs/convergence/learnings/`, include them as context alongside the codebase research. Past learnings are supplementary — they don't replace codebase exploration.

### Step 2 — Research (ticket-blind, in parallel)

Dispatch one `research-agent` per question **in parallel** — a single message with multiple Agent tool calls, not sequential dispatches. Opus 4.7 spawns fewer subagents by default, so the fan-out must be explicit. Each agent gets one question and returns compressed findings under 100 lines.

Each agent explores the codebase using native tools (grep, glob, read). Do not use RAG or vector search.

For each question, record:
1. **File paths** — where the relevant code lives
2. **Function signatures** — public API of the code you found
3. **Data flow** — how data moves through the relevant code
4. **Existing patterns** — how similar functionality works today
5. **Config and dependencies** — relevant configuration, gems, packages
6. **Code health signals** — file sizes, method counts, test coverage
7. **Recent history** — `git log` for touched files (who, why, when)

### Step 3 — Compile

Write a research document to `docs/convergence/research/YYYY-MM-DD-<topic>.md`.

**Format:**
```markdown
# Research: [Topic]
Date: YYYY-MM-DD

## Questions Investigated
1. [Question]
2. [Question]

## Findings

### [Question 1 Summary]
[Facts: file paths, signatures, data flow, patterns]

### [Question 2 Summary]
[Facts: file paths, signatures, data flow, patterns]

## Existing Patterns
[How similar things are done in this codebase]

## Code Health
[File sizes, complexity, churn, test coverage for areas we'll touch]

## Dependencies
[Relevant gems, packages, config that affects this area]
```

**Constraints:**
- Under 500 lines — compress, don't dump
- No opinions, no implementation suggestions
- No "should" or "could" — only "is" and "does"
- Follow references: if function A calls B, read B too

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| "Research this: we need to add X" | Goal contaminates research with opinions | Generate questions first, then research ticket-blind |
| Raw file dumps | Not research — just noise | Compress to relevant facts |
| "I recommend..." | Opinion, not fact | "The codebase currently does X via Y" |
| Skipping git history | Misses context on why code is the way it is | Check recent commits for touched files |
| Using only grep | Misses the connective tissue | Follow references: read callers and callees |
