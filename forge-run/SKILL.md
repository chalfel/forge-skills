---
name: forge-run
description: Execute a Forge spec or task by spawning an AI agent in a git worktree. Use when the user says "run spec", "execute task", "forge run", "start working on", or wants to spawn an agent for a specific capability.
argument-hint: [spec name or task name]
---

# Forge Run

Spawn an AI agent to implement a Forge spec or task.

## Process

### 1. Find the Spec

Read `.forge/specs/*.md` to find the spec matching `$ARGUMENTS`.

If no arguments, list all specs with their status and ask which one to run.

### 2. Identify Ready Tasks

A task is ready if:
- Status is `todo`
- All dependencies (<!-- deps: -->) have status `done`

Show the user which tasks are ready and which are blocked.

### 3. Create Worktree

For each ready task:
```bash
git worktree add .worktrees/{branch-slug} -b {branch-name}
```

Branch name comes from the spec's `<!-- branch: -->` + task slug.

### 4. Load Context

Gather:
- QG from `.forge/qg/*.md`
- Spec description (what exists, what's missing)
- Task done-when criteria
- Agent system prompt (from `.forge/config.md` if specified)

### 5. Spawn Agent

Open a new terminal in the worktree and run:
```bash
cd {worktree-path} && claude --append-system-prompt '{qg + agent context}' --add-dir '{.forge/}' '{task prompt}'
```

### 6. Update Status

Mark the task as `in_progress` in the spec file.

## Rules

- **Never run blocked tasks.** Show why they're blocked instead.
- **Inject QG always.** The agent must have project context.
- **One worktree per task.** Never run two tasks in the same worktree.
- **Parallel is default.** If multiple tasks are ready, spawn all of them.
