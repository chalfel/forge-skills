# Open PR

Push a task's branch, create the PR, and spawn a non-interactive reviewer.

## Input

- A `task-id`. Resolve worktree path and branch from `~/.forge/worktrees.json`.

Abort if there is no entry — the task was never played.

## Steps

### 1. Commit pending changes

```bash
cd <worktree-path>
if ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A
  git commit -m "<task-title>"
fi
```

If there are no commits ahead of `main` at all, stop — nothing to PR.

### 2. Push the branch

```bash
git push -u origin <branch>
```

Retry up to 4× with exponential backoff (2s, 4s, 8s, 16s) only on network errors. Do not retry on auth / non-fast-forward failures.

### 3. Create the PR

```bash
gh pr create \
  --title "<task-title>" \
  --body "$(printf '%s\n\nLinear: %s\n' '<task description>' '<linear-issue-url>')"
```

Capture the PR URL and number from the output.

### 4. Update Linear

Via MCP:

- Set status to `in_review`.
- Add a comment: `PR opened: <pr-url>`.

### 5. Spawn the reviewer (non-interactive)

Run in the background; the reviewer posts comments via `gh pr review`:

```bash
gh pr diff <pr-number> | claude -p "$(cat <<'PROMPT'
You are reviewing a Forge task PR.

Linear task:
  title: <task-title>
  description: <task-description>
  subtasks: <subtasks>

Spec (milestone) context:
  <milestone description>

Review the diff piped on stdin against:
  - the task's done-when / subtasks
  - architectural fit and existing patterns
  - obvious bugs, missing tests, security issues

For each concrete issue, post:
  gh pr review <pr-number> --comment -b "<finding with file:line>"

When done, submit a single final review:
  gh pr review <pr-number> --approve           # if nothing blocking
  gh pr review <pr-number> --request-changes -b "<summary>"   # otherwise

Be concise. Prefer specific file:line references over general advice.
PROMPT
)" &
```

Log the reviewer's stdout/stderr to `~/.forge/runs/<task-id>-review.log` (create the dir if missing).

## Output

Report:

- PR URL
- Reviewer pid + log path
- Linear status now `in_review`
