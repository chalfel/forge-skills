---
name: forge-run
description: Execute a Forge spec or task by spawning an AI agent in a git worktree. Use when the user says "run spec", "execute task", "forge run", "start working on", or wants to spawn an agent for a specific capability.
argument-hint: [spec name or task name]
---

# Forge Run

Spawn an AI agent to implement a Forge spec or task.

## Task Lifecycle

```text
todo → in_progress → in_review → done
                         ↓
                  changes_requested → in_progress → in_review → ...
```

- **todo**: ready to be picked up (if deps are met)
- **in_progress**: an agent is actively working
- **in_review**: PR created, awaiting review
- **changes_requested**: review completed, changes needed — runnable again
- **done**: approved/merged

## Process

### 1. Find the Spec

Read `.forge/specs/*.md` to find the spec matching `$ARGUMENTS`.

If no arguments, list all specs with their status and ask which one to run.

### 2. Identify Ready Tasks

A task is **ready** if:
- Status is `todo` OR `changes_requested`
- All dependencies (`<!-- deps: -->`) have status `done`

Show the user which tasks are ready and which are blocked.

### 3. Create Worktree

For each ready task, choose the branch base carefully:

#### Independent task (no task deps, or deps already merged to main)
```bash
git worktree add .worktrees/{branch-slug} -b {branch-name}
```

#### Dependent task (stacked PR flow)
If a task depends on another task that is being implemented in its own branch/PR and has **not** landed on main yet, use a **stacked branch** based on the dependency branch instead of main.

```bash
git worktree add .worktrees/{branch-slug} {dependency-branch} -b {branch-name}
```

Branch name comes from the spec's `<!-- branch: -->` + task slug.

This creates a PR stack similar to Graphite-style stacked diffs.

### 4. Load Context

Gather:
- KB from `.forge/kb/*.md`
- Spec description (what exists, what's missing)
- Task done-when criteria
- Agent system prompt (from `.forge/config.md` if specified)
- **Review feedback** (if status is `changes_requested`, include the review notes in the prompt)

If `.forge/.obsidian/` exists, tell the child agent to preserve YAML frontmatter and `[[wikilinks]]` in any KB/spec markdown it touches.

### 5. Choose Runtime and Spawn Agent

- **If running inside pi, or the user explicitly wants pi, prefer `pi` + `tmux` self-spawn**
- **Otherwise, fall back to `claude`**

#### 5a. pi mode (preferred when available)

Spawn panes or windows in tmux. Inject Forge context through `--append-system-prompt` and `@file` references.

#### 5b. claude fallback

```bash
cd {worktree-path} && claude --append-system-prompt '{context}' --add-dir '{.forge/}' '{task prompt}'
```

### 6. Update Status

Mark the task as `in_progress` in the spec file.

### 7. Create a PR and update status to in_review

When the agent finishes, it must:

```bash
git add -A
git commit -m "feat: {task summary}"
git push -u origin {branch-name}
gh pr create --fill
```

Then the agent (or orchestrator) updates the task metadata:
- `<!-- status: in_review -->`
- `<!-- pr: {PR URL} -->`

For stacked PRs, use `--base {dependency-branch}`.

PR expectations:
- One PR per task/worktree branch
- PR body should mention the spec file path, task name, outcome, and validation
- If push or PR creation fails, report the blocker clearly

## Review Flow (forge-review)

After a task reaches `in_review`:

1. The Forge review skill (`/skill:forge-review` in Pi) finds tasks with status `in_review`
2. Reviews the PR diff (via `gh pr diff` or branch comparison)
3. Writes review feedback into the task under `**Review feedback:**`
4. Sets status to `changes_requested` or `done`
5. The user can then run the Forge run skill again — tasks with `changes_requested` are treated as ready
6. The child agent receives the review feedback in its prompt context

## Task Metadata

Tasks support these metadata comments:
- `<!-- status: todo|in_progress|in_review|changes_requested|done -->`
- `<!-- parallelizable: yes|no -->`
- `<!-- deps: Task A, Task B -->`
- `<!-- repo: web|backend -->`
- `<!-- pr: https://github.com/org/repo/pull/123 -->`

## Rules

- **Never run blocked tasks.** Show why they're blocked instead.
- **Inject KB always.** The agent must have project context.
- **One worktree per task.** Never run two tasks in the same worktree.
- **Parallel is default.** If multiple tasks are ready, spawn all of them.
- **Use stacked branches/PRs for task dependencies.**
- **When using pi, prefer tmux self-spawn.**
- **Be explicit about runtime choice.**
- **Create a PR at the end.** Use `gh pr create` from the task branch.
- **Update status to `in_review` after PR creation.** Include PR URL in task metadata.
- **Include review feedback in prompt** when re-running `changes_requested` tasks.
- **If `.forge/.obsidian/` exists, preserve Obsidian-friendly markdown.**
