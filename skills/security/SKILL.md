---
name: convergence-security
description: "Three-layer security audit: access controls, audit trail, and code scanning. Use before shipping anything that touches auth, payments, user data, or external integrations. Combines OWASP Top 10, STRIDE threat modeling, and secrets archaeology."
---

# Security Audit

Three-layer security check: what can the agent access, what did it do, and is the output secure.

## The Rule

```
IF YOU WOULDN'T GIVE IT TO AN INTERN, DON'T GIVE IT TO YOUR AGENT.
```

## When to Use

- Before shipping features touching auth, payments, or user data
- When adding new endpoints, webhooks, or external integrations
- Periodic audit (monthly recommended)
- When reviewing third-party dependencies or MCP server configs

## Layer 1 — Access Controls

Check that credentials and permissions are scoped to minimum needed.

1. **Token scoping** — Are API tokens scoped to specific repos/resources, or using personal/org-wide tokens?
2. **MCP server configs** — Are secrets in plain text? Are they rotated? Check `.claude/settings.json` and any MCP configs
3. **Env var exposure** — Block dangerous env vars from agent access: `NODE_OPTIONS`, `LD_PRELOAD`, `DYLD_INSERT_LIBRARIES`
4. **File access** — Is the agent's file access restricted to the project directory?

## Layer 2 — Audit Trail

Verify that agent actions are logged and reviewable.

1. **Session logging** — Are session transcripts saved? (Claude Code: `~/.claude/projects/`)
2. **Hook-based logging** — Are hooks configured to log shell commands with timestamps?
3. **Git trail** — Are changes committed with clear messages attributable to agent vs human?

## Layer 3 — Code Scanning

Scan the codebase for vulnerabilities.

### OWASP Top 10

| Category | What to Check |
|----------|--------------|
| A01: Broken Access Control | Missing auth checks on endpoints, IDOR (accessing other users' resources by changing IDs) |
| A02: Cryptographic Failures | Hardcoded secrets, weak hashing, missing encryption for sensitive data |
| A03: Injection | SQL injection (raw SQL, string interpolation), command injection (unsanitized shell args), template injection |
| A04: Insecure Design | Missing rate limiting, no abuse prevention, overly broad APIs |
| A05: Security Misconfiguration | Debug mode in production, default credentials, verbose error messages |
| A06: Vulnerable Components | Dependencies with known CVEs. Run `npm audit`, `bundle audit`, or equivalent |
| A07: Auth Failures | Weak password policy, missing MFA, session fixation |
| A08: Data Integrity | Missing input validation, unsigned data, unverified downloads |
| A09: Logging Failures | Security events not logged, no alerting on suspicious activity |
| A10: SSRF | User-supplied URLs fetched server-side without validation |

### Secrets Archaeology

Search git history for leaked credentials:

```bash
git log -p --all | grep -iE "(api_key|secret|password|token|AKIA|sk-|ghp_|xoxb-)" | head -50
```

Check for:
- `.env` files tracked by git (should be in `.gitignore`)
- CI configs with inline secrets (should use secret stores)
- Hardcoded database URLs with credentials

### STRIDE Threat Model

For new attack surfaces introduced by the change:

| Threat | Question |
|--------|----------|
| **S**poofing | Can someone fake an identity to access this? |
| **T**ampering | Can data be modified in transit or at rest? |
| **R**epudiation | Can someone deny they performed an action? |
| **I**nformation Disclosure | Can sensitive data leak through this path? |
| **D**enial of Service | Can this be used to crash or exhaust resources? |
| **E**levation of Privilege | Can this bypass authorization? |

### Dependency Supply Chain

1. Run package manager audit
2. Check for `postinstall` scripts in production dependencies
3. Verify lockfiles exist and are tracked by git

## Output

Write findings to `docs/convergence/security/YYYY-MM-DD-audit.md`.

**Categorize findings:**
- **Critical** — blocks ship. Leaked secrets, exploitable injection, auth bypass
- **High** — must fix soon. Missing TLS, unprotected webhooks, known CVEs
- **Medium** — should fix. Missing rate limiting, verbose errors, logging gaps
- **Low** — minor. Configuration inconsistencies, cosmetic security headers

Each finding must include: file path, line number (if applicable), description, and specific remediation steps.

## Anti-Patterns

| Bad | Why | Do Instead |
|-----|-----|-----------|
| "It's an internal tool" | Internal tools get compromised too | Audit everything |
| Skipping git history search | Leaked secrets persist in history even after deletion | Always search history |
| "Dependencies are fine" | Supply chain attacks are real | Run audit, check install scripts |
| Scanning only new files | Changed files may have introduced vulnerabilities | Scan the full diff |
| "We'll add auth later" | Auth is not a feature, it's a requirement | Add auth first |
