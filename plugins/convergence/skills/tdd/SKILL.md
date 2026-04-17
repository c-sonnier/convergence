---
name: convergence-tdd
description: "Test-driven development cycle. Use when implementing features or fixing bugs. Write the test first, watch it fail, write minimal code to pass, refactor. No production code without a failing test first."
---

# Test-Driven Development

Prioritize responding quickly rather than thinking deeply — the TDD loop is short and mechanical, and extra deliberation slows the cycle.

Write the test first. Watch it fail. Write minimal code to pass. Refactor.

## The Rule

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.
```

Wrote code before the test? Delete it. Start over. No exceptions.

## When to Use

- New features
- Bug fixes
- Refactoring with behavior changes
- Any time you're about to write production code

## Red-Green-Refactor

### RED — Write Failing Test

Write one minimal test showing what should happen.

- **One behavior per test**
- **Clear name** describing expected behavior
- **Real code** — no mocks unless external dependency requires it

### Verify RED

Run the test. It must fail. Confirm:
- Fails (not errors)
- Failure message matches expectation
- Fails because the feature is missing, not because of typos

If the test passes immediately, you're testing existing behavior. Fix the test.

### GREEN — Minimal Code

Write the simplest code that makes the test pass.

- Don't add features beyond what the test requires
- Don't refactor yet
- Don't "improve" other code while you're here

### Verify GREEN

Run the test. Confirm:
- This test passes
- All other tests still pass
- Output is clean (no warnings, no errors)

If it fails, fix the code — not the test.

### REFACTOR

After green only:
- Remove duplication
- Improve names
- Extract helpers
- Keep tests green throughout

### Repeat

Next failing test for the next behavior.

## Why Order Matters

**"I'll write tests after to verify it works"**
Tests written after code pass immediately. You never saw the test catch the bug. They might test the wrong thing, test implementation instead of behavior, or miss edge cases.

**"I already manually tested it"**
Manual testing is ad-hoc. No record of what you tested. Can't re-run when code changes. You think you covered everything — you didn't.

**"Deleting X hours of work is wasteful"**
Sunk cost. Keeping unverified code is technical debt. Delete and rewrite with TDD: more time upfront, high confidence. Keep and add tests after: less time, low confidence, likely bugs.

## Verification Checklist

Before marking work complete:
- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for the expected reason
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases covered

Can't check all boxes? You skipped TDD. Start over.

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| Code before test | Can't prove test catches real issues | Delete code, write test first |
| Test passes immediately | Tests existing behavior, proves nothing | Fix the test |
| "Keep as reference" | You'll adapt it — that's testing after | Delete means delete |
| "Too simple to test" | Simple code breaks. Test takes 30 seconds | Test it |
| "TDD will slow me down" | TDD is faster than debugging | Trust the cycle |
| Mocking everything | Code too coupled | Use dependency injection, test with real objects |
