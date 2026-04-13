---
name: forge-status
description: Show the status of all Forge specs (Linear projects) and subtasks (Linear issues). Use when the user says "forge status", "show specs", "what's the progress", "what needs to be done", or wants an overview of project state.
argument-hint: [optional filter like "blocked", "ready", or a project name]
---

# Forge Status

Overview of all Linear projects (Specs) and their issues (Subtasks) for the configured team/workspace.

All data comes from the Linear MCP server (`https://mcp.linear.app/sse`). Local state (`~/.forge/*.json`) is only used to cross-reference which subtasks have a live worktree / tmux window.

## Process

### 1. Fetch projects + issues

Via Linear MCP:

- List projects for the default team (from `~/.forge/config.json` → `default_team`; if absent, ask).
- For each project, fetch its issues with: id, title, state, priority, blocker relations, assignee.

### 2. Compute metrics

Per project (spec):

- total / done / in_progress / in_review / todo / blocked counts
- **blocked** = state is `backlog|todo` AND has unresolved `blocked by` relations to non-`done` issues
- **ready** = state is `backlog|todo` AND no unresolved `blocked by` relations

Global:

- total projects, total issues, completion %
- count of issues currently running locally (cross-reference `~/.forge/sessions.json`)

### 3. Display overview

```text
Forge Status — <team name>

Focus (top 3 priority projects):
  P0  Fix auth bug                    ████████░░  4/5 subtasks
  P1  Upload images                   ██░░░░░░░░  1/5 subtasks
  P1  Billing refactor                ██████░░░░  3/5 subtasks

Overview: 12 specs | 47 subtasks | 23 done | 8 in review | 4 in progress | 8 todo | 4 blocked
Running locally: 3 subtasks (forge tmux session)

Blocked subtasks:
  E2E tests (github-oauth) ← blocked by: Backend OAuth, Frontend login
  Integration tests (billing) ← blocked by: Payment gateway

Ready to play:
  Frontend login button (github-oauth) — parallelizable
  Payment gateway interface (billing) — parallelizable
```

### 4. If filter provided

- `$ARGUMENTS = "blocked"` → only blocked subtasks with their blockers
- `$ARGUMENTS = "ready"` → only ready subtasks (good candidates for `play task` / `run spec`)
- `$ARGUMENTS = "running"` → only subtasks with a live worktree/tmux
- `$ARGUMENTS = <project name>` → detail for that spec: description + subtask table

## Rules

- **Linear is the source of truth.** Do not read any `.forge/specs/*.md` — that format is deprecated.
- **Always show Focus first** (top 3 projects by priority + recency).
- **Highlight actionable items** — ready subtasks and blocker chains.
- **Cross-reference local state** for "running locally" indicators, but never trust it over Linear.
- **Keep it scannable** — progress bars and counts, not walls of text.
