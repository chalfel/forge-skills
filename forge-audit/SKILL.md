---
name: forge-audit
description: Audit the codebase against the Linear KB (knowledge base issues in the team's KB project) and the roadmap (Linear initiatives + projects). Detects drift between documented plans and actual implementation. Use when the user says "audit", "what's implemented", "check progress", "drift check", "compare code vs KB", or wants to verify alignment between plans and reality.
argument-hint: [optional focus area — e.g. "architecture", "business", "roadmap"]
---

# Forge Audit — KB vs Codebase (Linear-native)

Compare Linear (KB + Specs + Roadmap) against the actual codebase. The KB is stored as issues in the team's `KB` project (labels `kb:*`). Specs are Linear projects. Roadmap horizons are the four Forge initiatives (`Now / Next / Later / Vision`).

All Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`). Use `default_team_id` from `~/.forge/config.json`.

## Input

The user provides: `$ARGUMENTS`.

- No arguments → full audit (architecture, business, roadmap, specs).
- `architecture` | `business` | `roadmap` | `specs` → scope to that area.

## Process

### 1. Load Linear state

Via MCP:

- KB issues in the `KB` project, grouped by `kb:*` label.
- All projects in the team (these are the Specs), with their state and subtask (issue) progress.
- All initiatives (`Now / Next / Later / Vision`) and which projects are under each.

### 2. Scan the codebase

Use Glob and Grep to verify each claim in the KB:

**Architecture (`kb:architecture`):**
- Stack claimed → check `package.json` / `Cargo.toml` / `go.mod` / `pyproject.toml` match.
- Patterns claimed ("repository pattern", "CQRS", etc.) → grep for actual usage.
- Constraints ("no GraphQL", "all APIs REST") → verify no violations.
- Modules/directories listed → confirm they exist.

**Business (`kb:business`):**
- Rules ("users must verify email") → check if validation exists in code.
- Pricing/tier limits → check if enforced.

**Roadmap (initiatives):**
- Projects under `Now` → cross-reference with actual activity (recent commits, in-progress issues).
- Projects marked complete in Linear → verify feature exists in code.
- Features shipped that are not represented in any initiative.

**Specs (projects):**
- Projects marked `completed` → verify the code actually implements them.
- Subtask issues marked `done` → check for implementation.
- Done-when criteria in subtask descriptions → try to verify each one.

### 3. Generate the report

```markdown
# Forge Audit Report

## Architecture Alignment
### Verified
- [x] Stack: NestJS + Prisma + PostgreSQL (confirmed in package.json)
- [x] Repository pattern (found in src/repositories/)

### Drift Detected
- [!] KB says "Redis for caching" but no Redis dependency found
- [!] KB lists "src/modules/notifications" but directory doesn't exist

### Not Verifiable
- [?] "Max 200ms response time" — needs runtime testing

## Business Rules Alignment
### Implemented
- [x] Email verification required (auth.guard.ts:23)
- [x] Free tier limited to 3 projects (plan.guard.ts:15)

### Missing
- [ ] "LGPD compliance" — no data deletion endpoint found
- [ ] "Rate limiting on API" — no middleware found

## Roadmap vs Reality
### Now (should be active)
- [x] "Social login" — Linear project `Now`: 4/4 subtasks done, code confirms
- [!] "Auto-commit" — Linear project active but no recent commits in 2 weeks

### Shipped but not on roadmap
- [!] Linear import — fully implemented, not represented in any initiative

## Specs Health
### Completed but unverified
- Linear project "billing-service" — marked completed, code changes confirmed

### Stale
- "upload-images" — active, but no git activity in 2 weeks

## Summary
| Area | Aligned | Drift | Missing | Stale |
|------|---------|-------|---------|-------|
| Architecture | 8 | 2 | 1 | 0 |
| Business | 4 | 0 | 3 | 0 |
| Roadmap | 3 | 1 | 2 | 0 |
| Specs | 5 | 0 | 0 | 1 |
```

### 4. Suggest actions

- "Update KB issue `<title>` (label `kb:architecture`) to remove Redis reference or add Redis."
- "Create Linear project under `Now` for LGPD compliance (missing from business rules)."
- "Move `Linear import` feature into the appropriate initiative — it is shipped but untracked."
- "Investigate stall on `upload-images` — no commits in 2 weeks."

### 5. Offer to fix

Ask: "Want me to update the Linear KB with what I found?" If yes, update the relevant KB issues (via MCP) to match reality — append dated sections, never overwrite.

## Rules

- **Linear is the source of truth.** No `.forge/specs/*.md` or `.forge/kb/*.md` anywhere.
- **Be specific.** Don't say "some patterns are missing" — say which ones and cite `file:line`.
- **Distinguish drift from intentional evolution.** If reality diverged, it might be a valid decision; ask before "fixing" the KB.
- **Check git history** for stale detection (`git log --since="2 weeks ago" -- <path>`).
- **Audit only what exists.** If the KB project is empty, say so and suggest `forge-intake` / `forge-persona` / `forge-business-plan` to populate it.
- **Be constructive.** The goal is alignment, not blame.
