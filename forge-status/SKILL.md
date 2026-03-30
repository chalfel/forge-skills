---
name: forge-status
description: Show the status of all Forge specs and tasks. Use when the user says "forge status", "show specs", "what's the progress", "what needs to be done", or wants an overview of the project state.
argument-hint: [optional filter like "blocked" or spec name]
---

# Forge Status

Show an overview of all specs and tasks in the project.

## Process

### 1. Read All Specs

Read all `.forge/specs/*.md` files and parse them.

### 2. Calculate Metrics

For each spec:
- Total tasks, done, in_progress, todo, blocked
- Blocked = todo + has deps not yet done
- Ready = todo + deps all done (or no deps)

Global:
- Total specs, total tasks
- Done tasks / total
- Specs by status (todo, in_progress, done)

### 3. Display Overview

Format as a clear summary:

```
Forge Status — {project name}

Focus (top 3 priority):
  P0  Fix auth bug                    ████████░░  4/5 tasks
  P1  Upload images                   ██░░░░░░░░  1/5 tasks
  P1  Billing refactor                ██████░░░░  3/5 tasks

Overview: 12 specs | 47 tasks | 23 done | 8 in progress | 12 todo | 4 blocked

Blocked tasks:
  E2E tests (github-oauth) — waiting on: Backend OAuth, Frontend login
  Integration tests (billing) — waiting on: Payment gateway

Ready to run:
  Frontend login button (github-oauth) — parallelizable
  Payment gateway interface (billing) — parallelizable
```

### 4. If filter provided

- `$ARGUMENTS` = "blocked" → show only blocked tasks with their deps
- `$ARGUMENTS` = spec name → show detail of that spec
- `$ARGUMENTS` = "ready" → show only tasks ready to run

## Rules

- **Always show Focus first** (top 3 by priority + date)
- **Highlight actionable items** (ready tasks, blocked reasons)
- **Keep it scannable** — use progress bars and counts
