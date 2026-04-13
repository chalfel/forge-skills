---
name: forge-report
description: Generate status reports from Linear (initiatives, projects, KB). Business-first for stakeholders, with optional technical appendix. Use when the user says "report", "status report", "executive summary", "report for the boss", "weekly update", "sprint report", "standup", "what did we accomplish", or needs a summary for stakeholders.
argument-hint: [optional period like "this week", "last 7 days", or a specific initiative/project name]
---

# Forge Report — Business-First Status Report (Linear-native)

Generate a professional report that leads with **business impact and strategic outcomes**. Technical detail is an appendix.

All data is pulled from Linear (team = product) via the Linear MCP server (`https://mcp.linear.app/sse`). Team comes from `default_team_id` in `~/.forge/config.json`.

## Input

`$ARGUMENTS` = optional period (`this week`, `last 7 days`, `march`, ...) or focus area (an initiative name or a project name).

## Process

### 1. Gather Linear data

Via MCP, for the configured team:

- **Initiatives**: `Now / Next / Later / Vision` — for strategic framing.
- **Projects (Specs)** by state (`backlog / started / completed`), grouped by initiative. Include subtask progress (total / done / in-progress / in-review).
- **KB issues** with `kb:business`, `kb:business-plan`, `kb:persona` — to frame outcomes around product vision.
- **Recent activity** — issues updated in the given period (comments, state changes).

If a period is given, scope "Delivered" to projects completed in that window and "In Progress" to anything with activity in that window.

### 2. Translate specs to business outcomes

This is the KEY step. For every completed or active project, translate from technical to business language:

| Technical (DON'T lead with this)  | Business (Lead with THIS)                                                                 |
|-----------------------------------|-------------------------------------------------------------------------------------------|
| "Implemented OAuth with GitHub"   | "Users can now sign in with one click using GitHub, reducing onboarding friction"        |
| "Extracted BillingService"        | "Payment processing is modular, enabling faster addition of new providers"               |
| "Added file type validation"      | "Users are protected from uploading invalid files, reducing support tickets"             |
| "Refactored auth middleware"      | "Security infrastructure improved, preparing for compliance requirements"                |
| "Migrated env X to Y"             | (Don't mention — irrelevant to stakeholders)                                             |

Use `kb:business` content to understand what the company cares about (personas, revenue, compliance, growth).

### 3. Generate report

```markdown
# Status Report — <Team / Product>
**Date:** <today>
**Period:** <scope>

---

## Executive Summary
<2-3 sentences framed around business goals. What capabilities were delivered? Impact on users/revenue/growth?>

## Business Impact

### Delivered
#### <Capability name> ✓
<User-facing outcome, 1-2 sentences>. <Link to strategic goal, 1 sentence>.

### In Progress
#### <Capability name> (<X>% complete)
<What the user will be able to do>. <Expected delivery>.

### Blocked — Needs Decision
- **<Topic>:** <Question that needs a stakeholder decision>

## Strategic Alignment

### Roadmap Progress
- ✅ **<Now project>** — delivered, aligned with "<goal>"
- 🔄 **<Now project>** — in progress
- ⬜ **<Next project>** — not started
- 💡 **<Later / Vision project>** — direction-setting only

### What's Next
1. <Top priority>
2. <Second priority>
3. <Third priority>

---

## Technical Appendix
<details>
<summary>Click to expand</summary>

### Completed Projects (Specs)
- <Linear project name> — <N>/<M> subtasks done, branches merged

### In Progress
- <Linear project name> — <N>/<M> subtasks, status

### Blocked Subtasks
- <subtask title> → blocked by: <other subtask>

### Metrics
| Metric                | Value   |
|-----------------------|---------|
| Projects completed    | 3/12    |
| Subtasks completed    | 15/47   |
| Completion rate       | 32%     |
| Active agents (local) | 2       |
| Velocity              | 8/week  |

</details>
```

### 4. Framing guidelines

**Always connect to business context:**
- Read KB `kb:business` and `kb:business-plan` for company goals, personas, KPIs.
- Every completed project should answer: "So what? Why does this matter for the business?"
- If you cannot explain the business impact, it belongs in the technical appendix only.

**Hierarchy of what stakeholders care about:**
1. What users can do now that they couldn't before
2. How it connects to company goals (growth, revenue, retention, compliance)
3. What decisions they need to make
4. What's coming next
5. (Distant last) How it was built technically

**Never lead with:**
- Branch names, file names, code changes
- Internal refactors with no user-facing impact
- Environment / dependency / config changes
- Technical debt cleanup (unless it directly enables a business goal)

### 5. Output options

After generating, offer:

- "Save to Linear as a team update / post?" (if MCP supports it)
- "Export as PDF?" (if document-skills available)
- "Shorter version for Slack/email?"
- "Just the business section, no technical appendix?"

## Rules

- **Business first, always.** Technical details are an appendix.
- **Frame as user outcomes.** "Users can now X" not "We implemented Y".
- **Connect to strategy.** Every item should link to a goal from `kb:business` or an initiative.
- **Decisions, not problems.** Don't say "blocked" — say "needs a decision on X".
- **Scannable.** Headers, bullets, bold keywords. Busy execs skim.
- **No vanity metrics.** "15 subtasks done" means nothing. "3 new user capabilities delivered" means everything.
- **Never read `.forge/`**. All content is Linear-native.
