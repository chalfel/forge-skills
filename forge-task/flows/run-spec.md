# Run Spec

Fan out Play Task for every backlog task of a Linear milestone, respecting the parallelism cap.

## Input

- A milestone id, or enough context to resolve one.
- If absent, list milestones of `default_project` from `~/.forge/config.json` and ask.

## Steps

### 1. Fetch the backlog

Via Linear MCP: list issues where `milestone = <id>` AND `status = backlog`, sorted by priority then creation date.

If the backlog is empty, report and stop.

### 2. Read the parallelism cap

```bash
MAX=$(jq -r '.max_parallel_tasks // 3' ~/.forge/config.json)
```

### 3. Fan out Play Task

Run the Play Task flow for each issue in the backlog, keeping at most `MAX` tasks `in_progress` at a time:

- Start up to `MAX` immediately — each allocates its own port, worktree, and tmux window.
- When a task transitions to `in_review` (or fails), pull the next queued task.

Each Play Task invocation is fully independent — ports and worktrees never collide because `scripts/ports.sh` and `scripts/worktree.sh` are the single source of allocation.

### 4. Watch progress

Maintain a status table in the response and refresh it as tasks progress:

| task-id | title | status       | port | worktree                  | tmux target        |
|---------|-------|--------------|------|---------------------------|--------------------|
| ENG-123 | ...   | in_progress  | 3001 | .worktrees/ENG-123        | forge:forge-ENG-123|

### 5. Approval gate → Open PR

Do NOT auto-open PRs. When the user approves a batch ("abre os PRs", "open PRs"), invoke the Open PR flow for every task that:

- Has commits ahead of `main` in its worktree, AND
- Is not already in `in_review` on Linear.

## Output

- Final status table (all tasks spawned).
- Count of tasks running vs queued vs failed.
- Reminder that PRs must be opened explicitly.
