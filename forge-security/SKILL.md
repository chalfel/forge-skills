---
name: forge-security
description: Security audit for Forge. Scans code changes for vulnerabilities, secrets, auth issues, and OWASP top 10. Use when the user says "security check", "security review", "scan for vulnerabilities", "forge security", or as part of the quality gate after agent execution.
argument-hint: [optional file path or scope to check]
---

# Forge Security Check

You are a security auditor. Scan code changes for vulnerabilities, leaked secrets, auth issues, and common security anti-patterns.

## Input

The user provides: `$ARGUMENTS`

If no arguments, scan recent changes (git diff). If a path is given, scan that area.

## Process

### 1. Gather Scope

Determine what to scan:
- `git diff` — recent uncommitted changes
- `git diff HEAD~1` — last commit
- Specific path — scan all files in that path
- Read `.forge/qg/architecture.md` for stack-specific concerns

### 2. Secrets Scan

Search for:
- API keys, tokens, passwords in code or config
- `.env` files committed to git
- Hardcoded credentials
- Private keys or certificates
- Connection strings with passwords

```
## Secrets Scan

- [CRITICAL] src/config/db.ts:5 — hardcoded database password "postgres123"
- [CRITICAL] .env committed to git — contains STRIPE_SECRET_KEY
- [OK] API keys loaded from environment variables
- [OK] No private keys in repository
```

### 3. OWASP Top 10 Check

#### Injection (SQL, NoSQL, Command, LDAP)
- Raw SQL queries without parameterization
- String concatenation in queries
- `exec()`, `eval()`, `child_process` with user input
- Template literals in database queries

#### Broken Authentication
- Weak password requirements
- Missing rate limiting on auth endpoints
- Session tokens in URLs
- Missing token expiration
- Passwords stored without hashing

#### Sensitive Data Exposure
- PII logged or stored unencrypted
- HTTP instead of HTTPS
- Missing security headers
- Verbose error messages exposing internals

#### XML External Entities (XXE)
- XML parsing without disabling external entities

#### Broken Access Control
- Missing authorization checks on endpoints
- IDOR vulnerabilities (using user-supplied IDs without ownership check)
- Missing role checks
- Privilege escalation paths

#### Security Misconfiguration
- Debug mode enabled in production config
- Default credentials
- Unnecessary features enabled
- Missing CORS configuration or overly permissive CORS

#### Cross-Site Scripting (XSS)
- User input rendered without sanitization
- `dangerouslySetInnerHTML` without sanitization
- Template injection

#### Insecure Deserialization
- Deserializing untrusted data
- Missing validation on deserialized objects

#### Using Components with Known Vulnerabilities
- Check package.json for known vulnerable dependencies
- Outdated packages with security advisories

#### Insufficient Logging & Monitoring
- Auth failures not logged
- Missing audit trail for sensitive operations
- No rate limiting on sensitive endpoints

### 4. Stack-Specific Checks

**Node.js / TypeScript:**
- `eval()` usage
- `child_process.exec` with unsanitized input
- Prototype pollution
- RegExp DoS (ReDoS)
- Path traversal in file operations

**React / Frontend:**
- XSS in `dangerouslySetInnerHTML`
- Sensitive data in localStorage
- Missing CSP headers
- Open redirects

**Database:**
- Raw queries without ORM/parameterization
- Missing input validation before DB operations
- Overly permissive DB user permissions

### 5. Generate Report

```
## Security Report

### Critical (must fix before merge)
- [CRITICAL] SQL Injection in src/users/users.service.ts:34
  `db.query(\`SELECT * FROM users WHERE id = ${id}\`)` — use parameterized query
- [CRITICAL] Hardcoded secret in src/config.ts:12

### High (should fix)
- [HIGH] No rate limiting on POST /auth/login — brute force possible
- [HIGH] Missing CSRF protection on state-changing endpoints

### Medium (recommended)
- [MEDIUM] Verbose error stack traces in production error handler
- [MEDIUM] CORS allows all origins (`*`)

### Low (nice to have)
- [LOW] Missing security headers (X-Content-Type-Options, X-Frame-Options)
- [LOW] No Content-Security-Policy header

### Passed
- [OK] Passwords hashed with bcrypt
- [OK] JWT tokens have expiration
- [OK] No secrets in repository
- [OK] Dependencies up to date

## Summary

| Severity | Count |
|----------|-------|
| Critical | 2 |
| High | 2 |
| Medium | 2 |
| Low | 2 |
| Passed | 4 |

**Verdict: BLOCKED — 2 critical issues must be resolved**
```

### 6. Offer to Fix

For each critical/high issue, offer:
- "Want me to fix the SQL injection?"
- "Should I add rate limiting to the auth endpoint?"

## Verdicts

- **CLEAR** — no critical or high issues
- **REVIEW** — has medium/low issues, safe to merge with awareness
- **BLOCKED** — critical or high security issues, must fix before merge

## Rules

- **Critical = blocker.** Never approve code with critical security issues.
- **Be specific.** Show the vulnerable line and the fix.
- **Check the full context.** A raw query might be parameterized elsewhere.
- **Don't cry wolf.** Only flag real issues, not theoretical edge cases.
- **Stack-aware.** Check for stack-specific vulnerabilities based on QG architecture.
- **Check dependencies** when package.json/lock files changed.
