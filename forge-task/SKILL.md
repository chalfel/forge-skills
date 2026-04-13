---
name: forge-task
description: Run the full Forge task lifecycle (play → PR → review → done) with Linear as source of truth, Claude Code as executor, and tmux + git worktrees locally. Use when the user says "play task", "inicia task", "próxima task", "run spec", "abre PR", "open PR", "review PR", "finaliza task", "task done", or mentions Forge.
argument-hint: [linear-task-id | milestone-id | flow-name]
---

# Forge Task

Orchestrate the Forge development lifecycle.

- **Source of truth:** Linear (Project → Milestone → Issue → Sub-issue).
- **Executor:** Claude Code running inside each worktree.
- **Local environment:** tmux windows + git worktrees in `.worktrees/<task-id>`.

Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`). Never ask the user for data you can fetch from Linear.

## Which flow to run

Pick the matching flow from the user's phrasing and read its reference file before acting. Do not duplicate its logic here.

| Trigger                                                        | Flow       | Reference              |
|----------------------------------------------------------------|------------|------------------------|
| "play task", "inicia task", "próxima task", "start task"       | Play Task  | flows/play-task.md     |
| "abre PR", "open PR", "push task"                              | Open PR    | flows/open-pr.md       |
| "run spec", "roda a spec", "run milestone"                     | Run Spec   | flows/run-spec.md      |
| "review PR", "revisa PR", "forge review"                       | Review PR  | flows/review-pr.md     |
| "finaliza task", "task done", after merge confirmation         | Task Done  | flows/task-done.md     |

If the user mentions "Forge" without a clear flow, list the flows and ask which one.

## Linear mapping

| Linear     | Forge     |
|------------|-----------|
| Project    | Produto   |
| Milestone  | Spec      |
| Issue      | Task      |
| Sub-issue  | Subtask   |

Status lifecycle: `backlog → in_progress → in_review → done`.

Update Linear status at every transition. Never change state silently.

## Local state

All persistent state lives under `~/.forge/`:

| File             | Purpose                                                                   |
|------------------|---------------------------------------------------------------------------|
| `config.json`    | Linear token, default project, `max_parallel_tasks`, `port_range`         |
| `ports.json`     | `task-id → port` (allocations in the configured range)                    |
| `sessions.json`  | `task-id → tmux target` (e.g. `forge:forge-ENG-123`)                      |
| `worktrees.json` | `task-id → { path, branch }`                                              |

If `~/.forge/config.json` does not exist, create it with defaults:

```json
{
  "default_project": null,
  "max_parallel_tasks": 3,
  "port_range": [3000, 3999]
}
```

## Shared scripts

Flows delegate all local-env mutation to the scripts in `scripts/`. Invoke them with an absolute path (or from the skill dir). Do NOT reimplement their logic inline.

- `scripts/ports.sh` — allocate / release / list ports in `~/.forge/ports.json`
- `scripts/worktree.sh` — create / remove worktrees, register in `~/.forge/worktrees.json`
- `scripts/tmux.sh` — spawn / kill the two-pane tmux window for a task

All three scripts are idempotent and update `~/.forge/*.json` atomically. They require `jq`, `git`, and `tmux` on PATH.

## Rules

- **Linear is source of truth.** If local state disagrees, re-fetch from Linear.
- **One worktree + one port + one tmux window per task.** Never reuse across tasks.
- **Parallel is the default for Run Spec**, capped at `max_parallel_tasks`.
- **Update Linear at every transition** (`in_progress`, `in_review`, `done`).
- **Stop on allocation failure.** Port exhausted, dirty worktree, tmux conflict → report and halt; never force.
- **Branch name is fixed:** `feat/<task-id>-<slug>`. Never push to a different branch.
- **Reviewer is non-interactive.** `gh pr diff <n> | claude -p "<prompt>"` and it posts via `gh pr review`.
- **Never invent Linear data.** If a field is missing from the MCP response, ask the user or skip.
