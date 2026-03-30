---
name: forge-audit
description: Audit the codebase against the KB (knowledge base). Compares what's defined in architecture, business rules, and roadmap with what's actually implemented. Use when the user says "audit", "what's implemented", "check progress", "compare code vs qg", "what's missing from the KB", "drift check", or wants to verify alignment between plans and reality.
argument-hint: [optional focus area — e.g. "architecture", "business rules", "roadmap"]
---

# Forge Audit — KB vs Codebase Reality Check

You are auditing the codebase to check what's actually implemented vs what's defined in the KB (Quartel General / knowledge base). This catches drift between plans and reality.

## Input

The user provides: `$ARGUMENTS`

If no arguments, audit everything. If a focus area is given (e.g. "architecture", "business"), audit only that.

## Process

### 1. Read the KB

Read all files in `.forge/kb/`:
- `architecture.md` — stack, patterns, constraints
- `business.md` — product rules, personas, vision
- `roadmap.md` — what's in Now/Next/Later/Vision
- Any other docs

### 2. Read the Specs

Read all `.forge/specs/*.md` to understand what's planned and what status each has.

### 3. Scan the Codebase

Use Glob and Grep to verify each claim in the KB:

**Architecture audit:**
- Stack defined? → Check package.json, Cargo.toml, go.mod match
- Patterns defined (e.g. "repository pattern")? → Grep for actual usage
- Constraints (e.g. "no GraphQL")? → Verify no violations
- Modules listed? → Check they exist
- Diagrams accurate? → Spot check main flows

**Business audit:**
- Core rules defined (e.g. "users must verify email")? → Check if validation exists in code
- Pricing rules? → Check if limits are enforced
- Personas? → Check if relevant features exist

**Roadmap audit:**
- "Now" items → Cross-reference with specs status
- Are there specs for all "Now" items?
- Are any "Now" items actually done but not updated?
- Are there implemented features not in the roadmap?

**Spec audit:**
- Specs marked "done" → Verify the code actually implements them
- Specs marked "in_progress" → Check for partial implementation
- Done-when criteria → Try to verify each one

### 4. Generate Report

Output a structured report:

```
# Forge Audit Report

## Architecture Alignment

### Verified
- [x] Stack: NestJS + Prisma + PostgreSQL (confirmed in package.json)
- [x] Repository pattern (found in src/repositories/)
- [x] REST API only (no GraphQL found)

### Drift Detected
- [!] KB says "Redis for caching" but no Redis dependency found
- [!] KB lists "src/modules/notifications" but directory doesn't exist

### Not Verifiable
- [?] "Max 200ms response time" — needs runtime testing

## Business Rules Alignment

### Implemented
- [x] Email verification required (found in auth.guard.ts:23)
- [x] Free tier limited to 3 projects (found in plan.guard.ts:15)

### Missing
- [ ] "LGPD compliance" — no data deletion endpoint found
- [ ] "Rate limiting on API" — no rate limiter middleware found

## Roadmap vs Reality

### Now (should be in progress)
- [x] "Dogfooding" — .forge/ exists with specs (active)
- [ ] "Skills" — only 3 of 7 skills have implementation
- [!] "Auto-commit" — spec exists but status is still "todo"

### Implemented but not in Roadmap
- [!] Linear import — fully implemented but not tracked anywhere
- [!] Live diffs — implemented but not in any roadmap horizon

## Specs Health

### Done but unverified
- billing-service.md — marked done, code changes confirmed in src/services/billing

### Stale
- upload-images.md — status "in_progress" but no git activity in 2 weeks

## Summary

| Area | Aligned | Drift | Missing | Stale |
|------|---------|-------|---------|-------|
| Architecture | 8 | 2 | 1 | 0 |
| Business | 4 | 0 | 3 | 0 |
| Roadmap | 3 | 1 | 2 | 0 |
| Specs | 5 | 0 | 0 | 1 |
```

### 5. Suggest Actions

After the report, suggest concrete actions:
- "Update `.forge/kb/architecture.md` to remove Redis reference or add Redis"
- "Create spec for LGPD compliance (missing from business rules)"
- "Move Linear import to roadmap under 'Now — completed'"
- "Update upload-images.md status or investigate stall"

### 6. Offer to Fix

Ask: "Want me to update the KB with what I found?" If yes, update the relevant KB files to match reality (add missing items, mark completed items, remove outdated references).

## Rules

- **Be specific.** Don't say "some patterns are missing" — say which ones and where.
- **Reference line numbers.** When you find something in code, cite the file and line.
- **Distinguish drift from intentional.** If something changed, it might be a valid evolution.
- **Don't audit what doesn't exist.** If KB is empty, say so and offer to populate it.
- **Check git history** for stale specs — use `git log --since="2 weeks ago" -- path` to detect activity.
- **Be constructive.** The goal is alignment, not blame.
