---
name: convergence-implement
description: "Execute outline phases with verification checkpoints. Use after /convergence-outline approval. Works through each phase sequentially: write tests first, implement, verify, commit. Stops and asks the human if 3+ fix attempts fail on any phase."
---

# Implement

Work through the outline phase by phase. Each phase follows TDD (test first, then implement) and must pass its verification checkpoint before proceeding.

## The Rules

```
1. NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.
2. NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.
3. IF 3+ FIXES FAIL: STOP AND ASK THE HUMAN.
```

## When to Use

- After `/convergence-outline` approval for structured features
- After `/convergence-design` approval when skipping outline (smaller features)
- After `/convergence-debug` identifies a fix (use Phase 4 directly)

## Process

### Phase Loop

For each phase in the outline:

#### Step 1 — Write Tests (RED)

Write tests for this phase's expected behavior. Run them. They must fail because the feature doesn't exist yet.

- One behavior per test
- Clear test names describing expected behavior
- Real code, not mocks (unless external dependency requires it)

If the test passes immediately, it's testing existing behavior. Fix the test.

#### Step 2 — Implement (GREEN)

Write the minimal code to make tests pass.

- Follow the outline's file list and signatures
- Follow existing codebase patterns found during research
- No features not in the outline
- No "while I'm here" improvements

#### Step 3 — Refactor

Clean up without changing behavior. Tests must stay green.

#### Step 4 — Verify Checkpoint

Run the verification command from the outline. Read the full output.

```
BEFORE claiming this phase is complete:
1. IDENTIFY: What command proves this phase works?
2. RUN: Execute the command (fresh, complete)
3. READ: Full output — check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Claim the phase is complete
```

**Red flags — if you catch yourself thinking any of these, STOP:**
- "Should work now"
- "I'm confident it passes"
- "Looks correct"
- "Just this once I can skip verification"

#### Step 5 — Commit

Commit with a descriptive message for this phase. One commit per phase.

#### Step 6 — Fix or Escalate

If the checkpoint fails:
- **Attempt 1-2:** Fix the issue, re-run verification
- **Attempt 3:** STOP. This likely indicates an architectural problem, not a code bug. Ask the human before attempting more fixes

### After All Phases

Run the full test suite. All tests must pass — not just the new ones.

## Common Failure Table

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Phase complete | Checkpoint command: expected output | Code looks right |
| Build succeeds | Build command: exit 0 | Linter passing |
| Bug fixed | Symptom test: passes | Code changed, assumed fixed |
| All done | Full suite: 0 failures | Phase tests pass |

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| Writing code before tests | Can't prove tests catch real issues | RED first, always |
| Implementing all phases then testing | Horizontal — can't isolate failures | Verify after each phase |
| Skipping verification | "Confidence is not evidence" | Run the command, read the output |
| Attempt #4 without asking | 3 failures = wrong architecture | Stop, escalate to human |
| "While I'm here" refactoring | Scope creep, unrelated to outline | Stick to the outline |
| Keeping code written before tests | Biases your tests toward implementation | Delete it, start with tests |
