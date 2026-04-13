# Task Done

Close out a task after the PR is merged. This flow is destructive (removes worktree, kills tmux) — only run after confirming the merge.

## Input

- A `task-id`.

## Steps

### 1. Confirm the merge

Ask the user once, unless they already said "merged":

> "PR for `<task-id>` is merged?"

Optionally verify:

```bash
gh pr view <pr-number> --json state,mergeCommit -q '.state + " " + .mergeCommit.oid'
```

If state is not `MERGED`, abort.

### 2. Update Linear

Via MCP:

- Set status to `done`.
- Add a comment: `Merged in <short-sha>.`

### 3. Release the port

```bash
bash <skill-dir>/scripts/ports.sh release <task-id>
```

### 4. Remove the worktree

```bash
bash <skill-dir>/scripts/worktree.sh remove <task-id>
```

This runs `git worktree remove --force <path>` and deletes the state entry. The branch on the remote is not touched (GitHub will have auto-deleted it if the repo is configured that way).

### 5. Destroy the tmux window

```bash
bash <skill-dir>/scripts/tmux.sh kill <task-id>
```

Kills only the `forge-<task-id>` window. The shared `forge` session stays up if other tasks are running.

### 6. Verify clean state

For sanity, confirm `<task-id>` is no longer a key in any of:

- `~/.forge/ports.json`
- `~/.forge/sessions.json`
- `~/.forge/worktrees.json`

If a residual entry exists (script failed mid-way), report it and stop — do not pretend cleanup succeeded.

## Output

- `<task-id>` → done (Linear)
- Port `<N>` released
- Worktree removed
- tmux window killed
