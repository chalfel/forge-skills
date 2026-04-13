# Play Task

Start working on a single Linear task.

## Input

- A Linear task id (e.g. `ENG-123`) or enough context to resolve one.
- If nothing given, list the top of the default project's backlog via Linear MCP and ask which to play.

## Steps

### 1. Fetch the subtask from Linear

Via the Linear MCP server (`https://mcp.linear.app/sse`), fetch:

- Issue (the subtask): title, description, state, labels
- Parent project (the "spec"): id, name, description, any stack hints in the description

A Linear project is the Forge Spec; a Linear issue inside that project is the Forge Subtask we are about to play.

Abort if the issue is not in `backlog` status (ask the user to confirm if it is `in_progress` already — may be a resume).

### 2. Allocate a port

```bash
PORT=$(bash <skill-dir>/scripts/ports.sh allocate <task-id>)
```

If the script exits non-zero, the port range is exhausted. Report and stop.

### 3. Create the worktree + branch

Build a slug from the task title (lowercase, ascii-only, dashes):

```bash
slug=$(printf '%s' "<task-title>" \
  | iconv -t ascii//translit 2>/dev/null \
  | tr '[:upper:]' '[:lower:]' \
  | tr -cs 'a-z0-9' '-' \
  | sed 's/^-//; s/-$//')
branch="feat/<task-id>-$slug"
bash <skill-dir>/scripts/worktree.sh create <task-id> "$branch"
```

The script creates `<repo-root>/.worktrees/<task-id>` on `$branch` based off the current HEAD of `main`.

### 4. Generate `CLAUDE.md` in the worktree

Write `<worktree>/CLAUDE.md` in this exact order:

```markdown
# <subtask title>

<subtask description from Linear>

## Spec Context
**<project title>** — Linear: <project-url>

<project description>

## Stack
<detected stack summary — from package.json / Cargo.toml / go.mod / pyproject.toml, etc.>

## Runtime
Allocated port: <PORT>
```

Detect the stack by reading manifests at the repo root. Keep it to 3-6 lines.

### 5. Generate `setup.sh` and `run.sh`

Both go at the worktree root, `chmod +x` them.

`setup.sh` installs dependencies for the detected stack (e.g. `pnpm install`, `cargo build`, `go mod download`, `uv sync`).

`run.sh` must export `PORT=<PORT>` before starting the dev server:

```bash
#!/usr/bin/env bash
set -euo pipefail
export PORT=<PORT>
# start dev server on $PORT for the detected stack
```

If you cannot confidently infer the run command, leave a TODO comment and tell the user.

### 6. Spawn the tmux window

```bash
bash <skill-dir>/scripts/tmux.sh spawn <task-id> <worktree-path>
```

This creates window `forge-<task-id>` in session `forge` with:

- Left pane (70%): `claude`
- Right pane (30%): `./setup.sh && ./run.sh`

### 7. Update Linear

Via MCP:

- Set the issue status to `in_progress`.
- Add a comment: `Forge started — branch \`feat/<task-id>-<slug>\`, port <PORT>.`

## Output

Report one block to the user:

- Task id + title
- Branch + worktree path
- Allocated port
- tmux target (e.g. `forge:forge-ENG-123`) — user can attach with `tmux attach -t forge`
