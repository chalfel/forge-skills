---
name: forge-report
description: Generate status reports from Forge data. Business-first for stakeholders, with optional technical appendix. Use when the user says "report", "status report", "executive summary", "report for the boss", "weekly update", "sprint report", "standup", "what did we accomplish", or needs a summary for stakeholders.
argument-hint: [optional period like "this week", "last 7 days", "march", or focus area]
---

# Forge Report — Business-First Status Report

Generate a professional status report that leads with **business impact and strategic outcomes**, not technical details. Technical info is available as an appendix for whoever needs it.

## Input

The user provides: `$ARGUMENTS`

If no arguments, generate for current state. If period given, scope to that timeframe.

## Process

### 1. Gather Data

Read:
- `.forge/specs/*.md` — all specs with status, tasks, priorities
- `.forge/kb/business.md` — product vision, personas, core rules (to frame outcomes)
- `.forge/kb/roadmap.md` — strategic alignment
- `.forge/kb/architecture.md` — only for technical appendix
- `.forge/inbox.md` — upcoming ideas
- `git log --since="X" --oneline` — recent activity (if period given)

### 2. Translate Specs to Business Outcomes

This is the KEY step. For every spec, translate from technical to business language:

| Technical (DON'T lead with this) | Business (Lead with THIS) |
|---|---|
| "Implemented OAuth with GitHub" | "Users can now sign in with one click using GitHub, reducing onboarding friction" |
| "Extracted BillingService" | "Payment processing is now modular, enabling us to add new payment providers faster" |
| "Added file type validation" | "Users are protected from uploading invalid files, reducing support tickets" |
| "Migrated env X to Y" | (Don't mention — irrelevant to stakeholders) |
| "Refactored auth middleware" | "Security infrastructure improved, preparing for compliance requirements" |

Read `.forge/kb/business.md` to understand what the company cares about and frame outcomes accordingly.

### 3. Generate Report

```markdown
# Status Report — [Project Name]
**Date:** [today]
**Period:** [scope]

---

## Executive Summary

[2-3 sentences framed around business goals. What capabilities were delivered? What's the impact on users/revenue/growth?]

Example: "This period we delivered social login and streamlined the payment infrastructure. Users can now sign up 60% faster with GitHub login. The modular payment system positions us to launch PagSeguro support next month, opening the Brazilian market."

## Business Impact

### Delivered

#### Users can sign in with GitHub ✓
Users now have a frictionless sign-up option. This directly supports our Q1 goal of reducing onboarding drop-off. Expected impact: fewer abandoned registrations, faster time-to-first-value.

#### Payment infrastructure modernized ✓
We can now integrate new payment providers in days instead of weeks. This unblocks our Latin America expansion plan (PagSeguro, MercadoPago).

### In Progress

#### Admin Dashboard (65% complete)
Management team will be able to monitor user activity, manage roles, and view audit logs. Audit logging is being implemented now. Expected delivery: this week.

#### Image upload improvements (25% complete)
Users will be able to upload files up to 20MB with clear validation messages. Reduces the #1 support ticket category ("upload failed").

### Blocked — Needs Decision

- **Data privacy compliance (LGPD):** Defined as a business requirement but no work started. Do we prioritize this before new features?
- **Admin analytics scope:** Should we include analytics charts in v1 or ship a simpler version first?

## Strategic Alignment

### Roadmap Progress
- ✅ **Social login** — delivered, aligned with "reduce onboarding friction" goal
- ✅ **Payment modularity** — delivered, enables LATAM expansion
- 🔄 **Admin tools** — in progress, enables self-service for management team
- ⬜ **Data compliance** — not started, legal requirement

### What's Next
1. Complete admin dashboard (management team needs this)
2. Image upload improvements (top support ticket category)
3. Data compliance assessment (legal requirement)

---

## Technical Appendix

<details>
<summary>Click to expand technical details</summary>

### Completed Specs
- `github-oauth.md` — 4/4 tasks done, branch merged
- `billing-service.md` — 3/3 tasks done, branch merged

### In Progress
- `admin-dashboard.md` — 4/6 tasks, audit log service running
- `upload-images.md` — 1/4 tasks, file validation in progress

### Blocked Tasks
- Analytics dashboard tab → depends on: audit log service
- E2E tests → depends on: frontend + backend completion

### Metrics
| Metric | Value |
|--------|-------|
| Specs completed | 3/12 |
| Tasks completed | 15/47 |
| Completion rate | 32% |
| Active agents | 2 |
| Velocity | 8 tasks/week |

</details>
```

### 4. Framing Guidelines

**Always connect to business context:**
- Read `business.md` for company goals, personas, KPIs
- Every completed spec should answer: "So what? Why does this matter for the business?"
- If you can't explain the business impact, it goes in the technical appendix only

**Hierarchy of what stakeholders care about:**
1. What users can do now that they couldn't before
2. How it connects to company goals (growth, revenue, retention, compliance)
3. What decisions they need to make
4. What's coming next
5. (Distant last) How it was built technically

**Never lead with:**
- Branch names, file names, or code changes
- Internal refactors with no user-facing impact
- Environment changes, dependency updates, config changes
- Technical debt cleanup (unless it directly enables a business goal)

**Do mention non-technical items:**
- What infrastructure changes mean for the business (speed, reliability, new capabilities)
- Risk reduction from security or compliance work
- Time saved from automation or tooling improvements

### 5. Output Options

After generating, offer:
- "Want me to save this to `.forge/reports/`?"
- "Should I create a PDF?" (if document-skills available)
- "Want a shorter version for Slack/email?"
- "Want just the business section without the technical appendix?"

## Rules

- **Business first, always.** Technical details are an appendix, not the main event.
- **Frame as user outcomes.** "Users can now X" not "We implemented Y"
- **Connect to strategy.** Every item should link to a business goal from the KB.
- **Decisions, not problems.** Don't say "blocked" — say "needs a decision on X"
- **Honest about risks.** Frame them as choices: "If we delay compliance, risk is X. If we prioritize it, we delay Y."
- **Celebrate business wins.** Not "merged PR" but "capability delivered"
- **Scannable.** Headers, bullets, bold keywords. Busy execs skim.
- **No vanity metrics.** "15 tasks done" means nothing. "3 new user capabilities delivered" means everything.
