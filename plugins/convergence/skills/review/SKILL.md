---
name: convergence-review
description: "Code review on the actual diff against the base branch. Use after implementation or when asked to review a PR. Two-stage review: correctness (did we build the right thing?) then quality (did we build it right?). Defaults to NEEDS WORK until evidence proves readiness."
---

# Code Review

Review the actual code diff against the base branch. Not the plan, not the outline — the code.

## The Rule

```
DEFAULT VERDICT: NEEDS WORK.
Change only with clear evidence of readiness.
```

## When to Use

- After `/convergence-implement` completes
- When asked to review a PR or diff
- Before merging any branch

## Process

### Step 0 — Get the Diff

```bash
git diff <base-branch>...HEAD
```

Read the full diff. If the design document exists, load it for reference.

### Stage 1 — Correctness

Does this implement what was designed?

1. Check each resolved design decision against the code
2. Verify all phases from the outline are complete
3. Look for missing requirements (things in the design not in the code)
4. Look for extra requirements (things in the code not in the design)

### Stage 2 — Quality

For every changed file, check:

**Architecture:**
- Layer violations (model depends on controller, service accepts request object)
- Reverse dependencies (lower layer depends on higher layer)
- God object growth (are we making a large file larger?)

**Security:**
- SQL injection (raw SQL, unsanitized interpolation)
- Auth bypass (missing authorization checks on new endpoints)
- XSS (unsanitized user input in views)
- Exposed secrets (hardcoded keys, tokens, passwords)
- OWASP Top 10 for new attack surfaces

**Data Safety:**
- N+1 queries (new associations without eager loading)
- Missing indexes (new foreign keys without indexes)
- Missing validations (new columns without model validations)
- Unsafe migrations (data-modifying migrations without rollback safety)

**Code Quality:**
- Method/class size (method >20 lines, class >200 lines — flag it)
- Naming clarity (does the name reveal intent?)
- Complexity (deep nesting, long conditionals)
- Duplication (copy-pasted logic)

**Tests:**
- Every new code path has a test
- Edge cases covered (empty, nil, boundary values)
- Tests test behavior, not implementation
- No tests that pass for the wrong reason

**Pattern Consistency:**
- Follows existing codebase patterns (or explicitly improves on them)
- No new patterns introduced without justification

### Step 3 — Run Tests

All tests must pass before approving.

```bash
[project test command]
```

Read the output. Count failures. Report actual results.

### Step 4 — Categorize Findings

For each finding:
- **must-fix** — blocks merge. Security issues, broken functionality, missing tests for critical paths
- **should-fix** — tech debt. Won't break anything today but will cause problems later
- **nit** — style preference. Take it or leave it

### Step 5 — Write Review

Write findings to `docs/convergence/reviews/YYYY-MM-DD-<topic>-review.md` and present a summary.

**Format:**
```markdown
# Review: [Feature/PR Name]
Date: YYYY-MM-DD
Branch: [branch name]
Verdict: [APPROVED / NEEDS WORK]

## Correctness
[Design alignment check results]

## Must-Fix
- [ ] `file:line` — [finding]
- [ ] `file:line` — [finding]

## Should-Fix
- [ ] `file:line` — [finding]

## Nits
- `file:line` — [finding]

## Test Results
[Command run, output summary]
```

### Step 6 — Compound Nudge

If the review surfaced surprising must-fix findings (issues the author likely didn't anticipate), suggest: "This review found non-obvious issues. Consider running `/convergence-compound` to capture these as learnings."

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| Reviewing the plan instead of the code | Plans have surprises; code is truth | `git diff base...HEAD` |
| Approving without running tests | "I reviewed the code" is not verification | Run the full suite |
| Only checking the latest commit | PR may have multiple commits with issues | Review the full diff against base |
| Approving because "it looks fine" | Default is NEEDS WORK | Prove readiness with evidence |
| Skipping security checks | "It's an internal tool" | Every endpoint is an attack surface |
| Reviewing only new files | Changed files may have broken patterns | Review all changed files |
