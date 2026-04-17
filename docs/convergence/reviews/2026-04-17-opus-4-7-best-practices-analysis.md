# Convergence vs. Opus 4.7 Best Practices

Date: 2026-04-17
Source: https://claude.com/blog/best-practices-for-using-claude-opus-4-7-with-claude-code

## Summary

Convergence aligns well with Anthropic's published Opus 4.7 best practices in most structural ways — upfront task specification, static artifacts that survive compaction, and explicit verification gates map cleanly onto what the blog recommends. The two meaningful gaps are around Opus 4.7's **reduced default subagent spawning** and **adaptive thinking** — Convergence predates both and does not yet give callers concrete language to drive them.

---

## Practice-by-Practice Analysis

### 1. Provide comprehensive task specifications upfront

**Blog guidance:** "Well-specified task descriptions that incorporate intent, constraints, acceptance criteria, and relevant file locations" outperform ambiguity spread across turns.

**Convergence:** Strong alignment.
- `/convergence-design` exists precisely to force intent + constraints into a single ~200-line artifact before code is written (`plugins/convergence/skills/design/SKILL.md:60-91`).
- `/convergence-outline` adds file paths, signatures, and verification commands as a structured spec.
- `/convergence-research` pre-populates the relevant file locations.

**Verdict:** Core workflow is built around this principle.

---

### 2. Minimize user interactions / batch context

**Blog guidance:** "Each user turn adds reasoning overhead; batch questions and provide full context."

**Convergence:** Partial conflict — deliberate.
- `/convergence-design` Step 6 explicitly says: **"Ask questions one at a time ... Do not batch questions"** (`design/SKILL.md:51-55`).
- Rationale is human cognitive load ("One question at a time — don't overwhelm"), not agent efficiency.

**Verdict:** Convergence consciously trades model efficiency for human decision quality. This is defensible for the design phase (where bad batched answers are worse than a few extra turns) but worth noting as an intentional deviation.

---

### 3. Leverage auto mode / set up notifications

**Blog guidance:** Use auto mode (Shift+Tab) for long-running tasks with full upfront context.

**Convergence:** Well-suited but not documented.
- `/convergence-implement` is exactly the kind of phase auto mode was built for — outline is pre-approved, each phase has a verification command, 3-fail escalation is already built in (`implement/SKILL.md:78-82`).
- README does not mention auto mode or completion notifications.

**Verdict:** Gap. README could add a "Running in auto mode" section noting that `/convergence-implement` and `/convergence-review` are safe candidates, while `/convergence-design` is not.

---

### 4. Effort levels (xhigh default, max for hard problems)

**Blog guidance:** Default to `xhigh`; reserve `max` for genuinely hard problems; toggle dynamically.

**Convergence:** Not addressed.
- No skill mentions effort levels.
- Some skills are clearly `max` candidates (`/convergence-architecture`, `/convergence-security`) and others are `medium` candidates (`/convergence-tdd`, `/convergence-compound`), but the repo gives no guidance.

**Verdict:** Gap. A one-column addition to the skills tables in README.md ("Recommended effort") would be a low-cost, high-signal improvement.

---

### 5. Adaptive thinking prompts

**Blog guidance:** Fixed thinking budgets are gone; prompt with "Think carefully and step-by-step ... this problem is harder than it looks" or "Prioritize responding quickly."

**Convergence:** Not addressed.
- `/convergence-debug` and `/convergence-architecture` would benefit from an explicit "think carefully" nudge in their SKILL.md preambles.
- `/convergence-compound` and `/convergence-tdd` could use the "respond quickly" framing.

**Verdict:** Gap. Small prompt additions per skill would align Convergence with Opus 4.7's adaptive thinking model.

---

### 6. Response length matches task complexity — state preferred length explicitly

**Blog guidance:** Opus 4.7 adapts length to complexity; say what you want.

**Convergence:** Strong alignment.
- Research: "Under 500 lines — compress, don't dump" (`research/SKILL.md:86`).
- Design: "Keep under 200 lines" (`design/SKILL.md:105`).
- Research agent: "under 100 lines" (`agents/research-agent.md:17`).
- README's instruction-budget framing reinforces this.

**Verdict:** Already a core Convergence principle.

---

### 7. Model reasons more, calls tools less — explicitly describe when tools should fire

**Blog guidance:** If you want more tool usage, "provide guidance that explicitly describes when and why the tool should be used."

**Convergence:** Partial alignment.
- `/convergence-research` explicitly names tools: "Use grep, glob, and read" and forbids RAG (`research-agent.md:12`).
- `/convergence-implement` mandates running the verification command (`implement/SKILL.md:56-66`).
- Less explicit in `/convergence-debug`, `/convergence-security`, `/convergence-review` about when to actually execute vs. reason.

**Verdict:** Mixed. The skills that most benefit from tool use (research, implement) are covered; others could be tightened.

---

### 8. Fewer subagents spawned by default — request parallel fan-out explicitly

**Blog guidance:** "Explicitly request multiple parallel subagents when fanning out across items or reading multiple files."

**Convergence:** Notable gap.
- `/convergence-research` dispatches subagents but sequentially — questions are researched one by one (`research/SKILL.md:42-53`).
- Agents like `research-agent` and `learnings-researcher` are defined for single-question dispatch.
- No skill says "spawn N subagents in parallel, one per question."

**Verdict:** Biggest actionable gap. `/convergence-research` is exactly the "fanning out across items" case the blog describes. Adding "dispatch one research-agent per question in parallel" would materially improve it on Opus 4.7.

---

## Scorecard

| Practice | Status |
|----------|--------|
| Upfront task specification | Strong |
| Minimize user turns | Intentional deviation (design phase) |
| Auto mode / notifications | Gap — undocumented |
| Effort level guidance | Gap |
| Adaptive thinking prompts | Gap |
| Explicit response length | Strong |
| Explicit tool-use guidance | Mixed |
| Parallel subagents | Gap — actionable |

## Recommended Changes (priority order)

1. **Parallel subagent dispatch in `/convergence-research`** — the cheapest meaningful win; changes one step from sequential to parallel.
2. **Effort-level column in README skill tables** — pure documentation, steers users to the right cost/quality tradeoff.
3. **Auto mode section in README** — identify which skills are auto-safe.
4. **Adaptive thinking preambles** on `/convergence-debug`, `/convergence-architecture`, `/convergence-security` (deeper thinking) and `/convergence-tdd`, `/convergence-compound` (faster).
5. **Keep the one-question-at-a-time rule in design** — this is the right call even if it contradicts the blog; just acknowledge the deviation.
