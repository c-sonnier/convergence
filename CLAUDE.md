# Convergence

A consolidated set of skills, agents, and workflows for Claude Code. Distilled from 6 open-source repos and validated against findings from the Coding Agents Summit 2026.

## Design Constraints

- **Instruction budget**: Every skill stays under 35 instructions. LLMs reliably follow ~150-200 total; keep active skill instructions under 60 per session.
- **Static artifacts**: Every workflow phase writes output to a file. Survives compaction, enables session resumption.
- **Human in the loop**: Workflows surface assumptions for human correction before writing code. No automated decision pipelines.
- **Verify the code**: Review actual code, not plans. Run commands and read output before claiming success.
- **Vertical slicing**: Plans follow end-to-end slices with checkpoints, not horizontal layers.

## Skill Router

When the user's request matches a skill, invoke it. Do not load multiple workflow skills simultaneously.

### Workflow Skills (sequential phases for features)

| Trigger | Skill | Use When |
|---------|-------|----------|
| `/research` | `convergence:research` | Starting a new feature. Produces objective codebase research |
| `/design` | `convergence:design` | After research. Alignment discussion with human (~200 lines) |
| `/outline` | `convergence:outline` | After design approval. Vertical structure with checkpoints |
| `/implement` | `convergence:implement` | After outline approval. Execute phases with verification |
| `/review` | `convergence:review` | After implementation. Code review on actual diff |

### Utility Skills (standalone, invoke when needed)

| Trigger | Skill | Use When |
|---------|-------|----------|
| `/debug` | `convergence:debug` | Any bug, test failure, or unexpected behavior |
| `/tdd` | `convergence:tdd` | Writing new features or fixing bugs with tests |
| `/security` | `convergence:security` | Security audit before shipping |
| `/architecture` | `convergence:architecture` | Architecture analysis, health check, onboarding |

### Typical Combinations

- **Small feature**: `/design` > `/implement` > `/review`
- **Large feature**: `/research` > `/design` > `/outline` > `/implement` > `/review`
- **Bug fix**: `/debug` > `/tdd`
- **Pre-ship**: `/review` + `/security`
- **Codebase health**: `/architecture`

## Agents

Agents are dispatched by skills, not invoked directly. Each runs in its own context window.

- **Research Agent** — Ticket-blind codebase explorer. Dispatched by `/research`.
- **Review Agent** — Code quality reviewer. Defaults to "NEEDS WORK." Dispatched by `/review`.
- **Security Agent** — Vulnerability scanner. Dispatched by `/security`.

## Artifact Locations

Skills write artifacts to these paths (create directories as needed):

| Phase | Path |
|-------|------|
| Research | `docs/convergence/research/YYYY-MM-DD-<topic>.md` |
| Design | `docs/convergence/design/YYYY-MM-DD-<topic>-design.md` |
| Outline | `docs/convergence/outline/YYYY-MM-DD-<topic>-outline.md` |
| Review | `docs/convergence/reviews/YYYY-MM-DD-<topic>-review.md` |
| Architecture | `docs/convergence/architecture/YYYY-MM-DD-analysis.md` |
| Security | `docs/convergence/security/YYYY-MM-DD-audit.md` |
