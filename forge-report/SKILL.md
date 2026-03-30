---
name: forge-report
description: Generate executive status reports from Forge data. Creates presentation-ready reports for leadership, stakeholders, or standups. Use when the user says "report", "status report", "executive summary", "report for the boss", "weekly update", "sprint report", "standup", "what did we accomplish", or needs a summary for non-technical stakeholders.
argument-hint: [optional period like "this week", "last 7 days", "march", or focus area]
---

# Forge Report — Executive Status Report

Generate a clean, professional status report from Forge specs, QG, and git history. Designed to be shared with leadership, stakeholders, or used in standups.

## Input

The user provides: `$ARGUMENTS`

If no arguments, generate a report for the current state. If a period is given (e.g. "this week", "march"), scope the report to that timeframe.

## Process

### 1. Gather Data

Read:
- `.forge/specs/*.md` — all specs with status, tasks, priorities
- `.forge/qg/roadmap.md` — strategic alignment
- `.forge/inbox.md` — upcoming ideas
- `git log --since="X" --oneline` — recent activity (if period given)
- Agent dashboard state (if available)

### 2. Calculate Metrics

```
Total specs: X
Total tasks: X

Completed:    X specs, X tasks
In Progress:  X specs, X tasks
Blocked:      X tasks (list reasons)
Backlog:      X specs, X tasks

Completion rate: X%
```

If period given, also calculate:
- Tasks completed in period
- Specs completed in period
- New specs created in period
- Velocity (tasks/week)

### 3. Generate Report

Format as a clean, executive-friendly document:

```markdown
# Status Report — [Project Name]
**Date:** [today]
**Period:** [scope]
**Author:** [from git config]

---

## Executive Summary

[2-3 sentences: what was accomplished, what's in progress, any blockers or risks]

## Progress Overview

| Metric | Value |
|--------|-------|
| Specs completed | 3/12 |
| Tasks completed | 15/47 |
| Completion | 32% |
| In progress | 8 tasks across 4 specs |
| Blocked | 2 tasks |

## Completed This Period

### Users can login with GitHub ✓
- Backend OAuth flow, frontend button, account linking, E2E tests
- Branch: feat/github-oauth — ready for merge

### Billing service refactor ✓
- Extracted BillingService, payment gateway interface, integration tests
- Branch: feat/billing — merged

## Currently In Progress

### Admin Dashboard (4/6 tasks done)
- **Running:** Audit log service (agent active, 45min elapsed)
- **Blocked:** Analytics tab (waiting on audit log service)
- **ETA:** 2 remaining tasks, both parallelizable after current completes

### Upload images (1/4 tasks done)
- **Running:** File type validation
- **Next:** Error messages, size limit update
- **Priority:** P1

## Blockers & Risks

- **Audit log service** blocked by RBAC middleware (dependency)
- **LGPD compliance** — defined in business rules but no spec created yet
- **No QA tests** for 3 completed specs (technical debt)

## Roadmap Alignment

### Now (in progress)
- ✅ Dogfooding — active
- ✅ Skills — 10/10 complete
- 🔄 Focus view — implemented, testing
- ⬜ Auto-commit — spec created, not started

### Next (upcoming)
- Break project from 1 prompt
- CLI update
- Public skills repo

## Key Decisions Needed

- [ ] Should we prioritize LGPD compliance before new features?
- [ ] Admin dashboard scope: include analytics in v1 or defer?

## Next Steps

1. Complete admin dashboard (2 tasks remaining)
2. Start upload images spec (P1)
3. Create spec for LGPD compliance
```

### 4. Adapt Tone

**For leadership/executives:**
- Focus on outcomes, not technical details
- Use percentages and completion metrics
- Highlight blockers that need their input
- Include "Key Decisions Needed" section

**For standup/team:**
- More technical, include branch names
- Show what each agent is working on
- Include code-level blockers

**For stakeholders/clients:**
- Focus on user-facing capabilities
- Use non-technical language
- Emphasize "users can now do X"

### 5. Output Options

After generating, offer:
- "Want me to save this to `.forge/reports/`?"
- "Should I create a PDF?" (if document-skills available)
- "Want a shorter version for Slack/email?"

## Rules

- **No jargon for executives.** "Auth flow" → "Login with GitHub feature"
- **Lead with outcomes.** What users can do now that they couldn't before.
- **Be honest about blockers.** Don't hide problems, frame them as decisions needed.
- **Include velocity** when period data is available — shows trends.
- **Celebrate wins.** Completed specs deserve recognition.
- **Actionable next steps.** End with clear priorities, not vague plans.
- **Keep it scannable.** Tables > paragraphs. Bullets > prose.
