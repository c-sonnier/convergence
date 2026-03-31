---
name: convergence-architecture
description: "Architecture analysis with quantified quality gates. Use for codebase health checks, onboarding, or before major refactors. Detects layer violations, scores callbacks, finds god objects via churn x complexity, and checks code quality thresholds."
---

# Architecture Analysis

Analyze codebase architecture using layered design principles and quantified quality gates.

## When to Use

- Onboarding to an unfamiliar codebase
- Before a major refactor
- Periodic health check (quarterly recommended)
- When a file keeps growing and you suspect a god object

## Process

### Step 1 — Map to Layers

Map the codebase to four architecture layers:

```
Presentation  — Controllers, views, components, helpers, presenters, serializers
Application   — Services, operations, policies, forms, queries
Domain        — Models, value objects, domain events
Infrastructure — Active Record, APIs, file storage, mailers, jobs
```

**Core rule:** Lower layers must never depend on higher layers. Data flows top-to-bottom only.

### Step 2 — Detect Layer Violations

Scan for upward dependencies:

| Violation | Example | Fix |
|-----------|---------|-----|
| Model uses Current | `Current.user` in model | Pass user as explicit parameter |
| Service accepts request | `param :request` in service | Extract value object from request |
| Controller has business logic | Pricing calculations in action | Extract to service or model |
| Model sends notifications | `after_create :send_email` | Move to service or use events |
| Job contains domain logic | Complex calculations in job | Extract to service, job only orchestrates |

### Step 3 — Score Callbacks

For each callback in the codebase, score 1-5:

| Score | Type | Example | Action |
|-------|------|---------|--------|
| 5 | Transformer | `before_validation :normalize_email` | Keep — pure data transformation |
| 4 | Maintainer | `before_save :update_cached_count` | Keep — internal consistency |
| 3 | Timestamp | `before_create :set_published_at` | Acceptable — time-based assignment |
| 2 | Background trigger | `after_commit :enqueue_indexing` | Consider extracting to service |
| 1 | Operation | `after_create :send_welcome_email` | Extract immediately — side effect |

Anything scoring 1-2 is a candidate for extraction to a service, controller, or event-driven pattern.

### Step 4 — Detect God Objects

Find candidates using churn x complexity:

```bash
# High churn files (last 6 months)
git log --format=format: --name-only --since="6 months ago" -- "*.rb" | sort | uniq -c | sort -rn | head -20
```

For each high-churn file, check complexity:

| Metric | Warning | Critical |
|--------|---------|----------|
| Lines of code | >250 | >500 |
| Public methods | >15 | >30 |
| Associations | >10 | >20 |
| Callbacks | >5 | >10 |
| Concerns included | >5 | >10 |

High churn + high complexity = god object. Map its responsibility clusters to plan decomposition.

### Step 5 — Check Quality Gates

| Metric | Target | Hard Limit |
|--------|--------|-----------|
| Class lines | <200 | — |
| Method lines | <10 | <20 |
| Public methods per class | <15 | — |
| Method parameters | <3 | — |
| Nesting depth | <2 | — |

**Detection patterns:**
- Classes > 200 lines: `wc -l app/models/*.rb | sort -rn`
- Methods > 20 lines: scan files with high line counts
- Query logic in controllers: grep for `.where`, `.joins`, `.order` in controllers
- Query logic in views: grep for `Model.find`, `Model.where` in views

### Step 6 — Specification Test

For key classes, check: "Does this class have responsibilities beyond its layer?"

1. List all responsibilities the class handles
2. Map each to a layer (Presentation / Application / Domain / Infrastructure)
3. Anything not in this class's primary layer is a violation candidate

If a test file needs `context` blocks for responsibilities outside the class's layer, the code has misplaced logic.

### Step 7 — Write Report

Write to `docs/convergence/architecture/YYYY-MM-DD-analysis.md`.

Only include sections with meaningful findings. Skip sections with no violations.

**Format:**
```markdown
# Architecture Analysis
Date: YYYY-MM-DD

## Layer Violations
[Violations found with file paths and fix recommendations]

## Callback Scores
[Callbacks scoring 1-2 with extraction recommendations]

## God Object Candidates
[High churn + high complexity files with responsibility clusters]

## Quality Gate Violations
[Files exceeding thresholds]

## Recommendations
[Prioritized by impact, with gradual adoption paths]
```

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| Reporting "no violations" for every section | Noise, not signal | Skip sections with no findings |
| Big-bang refactor recommendation | Too risky, never happens | Gradual adoption with escape hatches |
| Flagging every callback | Not all callbacks are bad | Score them — only flag 1-2 |
| Ignoring existing patterns | Breaks consistency | Recommend patterns that fit the codebase |
