---
name: forge-run
description: Execute a Forge subtask (Linear issue) or spec (Linear project) by spawning Claude Code in a git worktree with a tmux session and allocated port. Use when the user says "run spec", "execute task", "forge run", "start working on", or wants to spawn an agent for a specific capability.
argument-hint: [linear-issue-id | linear-project-id]
---

# Forge Run

Thin entry point that dispatches to the Linear-native task lifecycle in the **forge-task** skill. Forge is full Linear — a Spec is a Linear project and a Subtask is a Linear issue.

## Dispatch

| User gave…                                   | Run                                                             |
|----------------------------------------------|-----------------------------------------------------------------|
| A Linear issue id (e.g. `ENG-123`)           | `forge-task` → `flows/play-task.md`                             |
| A Linear project id / name (the spec)        | `forge-task` → `flows/run-spec.md`                              |
| Nothing                                      | Ask: "Which subtask (issue) or spec (project) should I run?"    |

Do NOT reimplement the worktree / tmux / port logic here. Read `forge-task/SKILL.md` and follow the matching flow file. All Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`).

## Lifecycle (reference)

```text
backlog → in_progress → in_review → done
```

State transitions happen in Linear via MCP at each step. See `forge-task/SKILL.md` for the full mapping and rules.

## Rules

- **Never work off local `.forge/specs/*.md`.** That format is deprecated — Linear is the source of truth.
- **Delegate to forge-task.** This skill's only job is to resolve what the user meant and hand off.
- **Parallel is the default** when a whole spec (project) is requested, capped at `max_parallel_tasks` from `~/.forge/config.json`.
