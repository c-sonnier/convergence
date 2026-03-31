---
name: convergence-debug
description: "Systematic root cause investigation. Use when encountering any bug, test failure, or unexpected behavior. Four phases: investigate, analyze patterns, hypothesize, fix. No fixes without root cause. If 3+ fixes fail, stop and question the architecture."
---

# Systematic Debugging

Find the root cause before attempting fixes. Random fixes waste time and create new bugs.

## The Rule

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

Use this ESPECIALLY when under time pressure. Systematic debugging is faster than guess-and-check thrashing.

## The Four Phases

Complete each phase before proceeding to the next.

### Phase 1 — Root Cause Investigation

**Before attempting ANY fix:**

1. **Read error messages carefully.** Don't skip past errors. Read stack traces completely. Note line numbers, file paths, error codes. The error message often contains the exact solution.

2. **Reproduce consistently.** Can you trigger it reliably? What are the exact steps? If not reproducible, gather more data — don't guess.

3. **Check recent changes.** `git diff`, recent commits, new dependencies, config changes, environmental differences.

4. **In multi-component systems, add diagnostic logging at each boundary before fixing anything:**
   ```
   For EACH component boundary:
     - Log what enters
     - Log what exits
     - Verify config propagation
   Run once. The evidence shows WHERE it breaks.
   ```

5. **Trace data flow.** Where does the bad value originate? What called this with the bad value? Keep tracing up until you find the source. Fix at source, not at symptom.

### Phase 2 — Pattern Analysis

1. **Find working examples.** Similar working code in the same codebase.
2. **Compare against references.** If implementing a pattern, read the reference completely — don't skim.
3. **Identify every difference** between working and broken, however small. Don't assume "that can't matter."
4. **Understand dependencies.** What other components, settings, environment does this need?

### Phase 3 — Hypothesis and Testing

1. **Form a single hypothesis.** State it clearly: "I think X is the root cause because Y." Write it down.
2. **Test minimally.** Make the smallest possible change to test the hypothesis. One variable at a time.
3. **Evaluate.** Did it work? Yes: proceed to Phase 4. No: form a new hypothesis. Do NOT add more fixes on top.

### Phase 4 — Fix

1. **Create a failing test** that reproduces the bug. Simplest possible reproduction.
2. **Implement a single fix** addressing the root cause. One change. No "while I'm here" improvements.
3. **Verify.** Test passes? Other tests still pass? Issue actually resolved?
4. **If fix doesn't work:**
   - Attempts < 3: Return to Phase 1 with new information
   - **Attempts >= 3: STOP.** This signals an architectural problem, not a code bug. Discuss with the human before attempting more.

## Red Flags — STOP and Return to Phase 1

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "I don't fully understand but this might work"
- "One more fix attempt" (when 2+ have already failed)
- Proposing solutions before tracing data flow

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| "Probably X, let me fix that" | Guessing, not investigating | Phase 1 first |
| Multiple fixes at once | Can't isolate what worked | One variable at a time |
| "Simple issue, skip the process" | Simple bugs have root causes too | Process is fast for simple bugs |
| Fix #4 without asking | 3 failures = architectural problem | Stop, question fundamentals with human |
| Fixing the symptom | Masks the real problem | Trace to source, fix there |
