---
name: forge-run
description: Execute Forge subtasks and specs. Spawns Claude Code in a git worktree with an allocated port and a tmux window, drives the Linear task lifecycle, opens PRs, and cleans up. Use when the user says "play task", "inicia task", "próxima task", "run spec", "open PR", "abre PR", "finaliza task", "task done", or mentions Forge in a do-the-work context.
argument-hint: [linear-issue-id | linear-project-id | flow-name]
---

# Forge Run

Drive the Forge task lifecycle on Linear.

- **Source of truth:** Linear (Team = Product, Project = Spec, Issue = Subtask).
- **Executor:** Claude Code inside each worktree.
- **Local env:** tmux windows + git worktrees in `.worktrees/<issue-id>`.

Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`). Never ask the user for data you can fetch from Linear.

## Which flow to run

| Trigger                                                        | Flow       | Reference              |
|----------------------------------------------------------------|------------|------------------------|
| "play task", "inicia task", "próxima task", "start task"       | Play Task  | flows/play-task.md     |
| "run spec", "roda a spec", "run project"                       | Run Spec   | flows/run-spec.md      |
| "abre PR", "open PR", "push task"                              | Open PR    | flows/open-pr.md       |
| "finaliza task", "task done", after merge confirmation         | Task Done  | flows/task-done.md     |

For review, use the sibling skill `forge-review`.

Read the matching reference file before acting — it has the exact steps, MCP calls and shell commands. Do NOT duplicate that logic here.

## Linear mapping

| Linear       | Forge              |
|--------------|--------------------|
| Team         | Product / Workspace|
| Initiative   | Roadmap horizon    |
| Project      | Spec               |
| Issue        | Subtask            |

Status lifecycle: `backlog → in_progress → in_review → done`.

## Local state (`~/.forge/`)

| File             | Purpose                                                                   |
|------------------|---------------------------------------------------------------------------|
| `config.json`    | Linear token, `default_team_id`, `max_parallel_tasks`, `port_range`       |
| `ports.json`     | `issue-id → port`                                                         |
| `sessions.json`  | `issue-id → tmux target` (e.g. `forge:forge-ENG-123`)                     |
| `worktrees.json` | `issue-id → { path, branch }`                                             |

If `~/.forge/config.json` does not exist, `forge-init` creates it. Do not fabricate defaults silently.

## Shared scripts

Flows delegate all local-env mutation to the scripts in `scripts/`. Invoke them with an absolute path. Do NOT reimplement their logic inline.

- `scripts/ports.sh` — allocate / release / list ports in `~/.forge/ports.json`
- `scripts/worktree.sh` — create / remove / look up worktrees in `~/.forge/worktrees.json`
- `scripts/tmux.sh` — spawn / kill the two-pane `forge-<issue-id>` window

Each script is idempotent, writes atomically, and requires `jq`, `git`, and `tmux` on PATH. `forge-review` references the same scripts when it needs a worktree context.

## KB injection (lazy)

The KB lives in Linear (project `KB` inside the team, issues labeled `kb:*`). Do NOT prebake KB content into `CLAUDE.md`. The generated `CLAUDE.md` only tells the child agent which team / project / labels to query via the Linear MCP when it actually needs the info.

## Rules

- **Linear is source of truth.** If local state disagrees, re-fetch.
- **One worktree + one port + one tmux window per subtask.** No reuse.
- **Parallel is default for Run Spec**, capped at `max_parallel_tasks`.
- **Update Linear at every transition** (`in_progress`, `in_review`, `done`).
- **Stop on allocation failure.** Port exhausted / dirty worktree / tmux conflict → report, do not force.
- **Branch is fixed:** `feat/<issue-id>-<slug>`.
- **Never write local `.forge/specs/*.md` or `.forge/kb/*.md`.** Both are deprecated.
