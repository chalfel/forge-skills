# Review PR

Run the non-interactive reviewer on a PR that is already open. Use this when Open PR's reviewer did not run, failed, or the user wants another pass.

## Input

- A `task-id` OR a `pr-number`.

## Steps

### 1. Resolve the PR

- If given `task-id`: fetch PR URL from Linear MCP (`attachments` or stored comment). Fallback: `gh pr list --head feat/<task-id>-*`.
- If given `pr-number`: use it directly and resolve the Linear task from the branch name (`feat/<task-id>-<slug>`).

### 2. Fetch review context

Via Linear MCP:

- Subtask (issue) title + description
- Parent project title + description (the spec)

### 3. Run the reviewer

```bash
gh pr diff <pr-number> | claude -p "$(cat <<'PROMPT'
You are reviewing PR #<pr-number>.

Linear subtask:
  title: <subtask-title>
  description: <subtask-description>

Spec context (Linear project):
  title: <project-title>
  description: <project-description>

Review the diff piped on stdin against:
  - the task's done-when / subtasks
  - architectural fit and existing patterns
  - obvious bugs, missing tests, security issues

For each concrete issue, post:
  gh pr review <pr-number> --comment -b "<finding with file:line>"

Submit a single final review at the end:
  --approve               if nothing blocking
  --request-changes -b "<summary>"   otherwise

Be concise. Prefer file:line references over general advice.
PROMPT
)"
```

This runs synchronously — the user asked for a review now. Log to `~/.forge/runs/<task-id>-review.log`.

### 4. Report

Return the reviewer's final decision (approved / changes requested) and a count of comments posted. Do NOT change Linear status — that transition belongs to Task Done (after merge) or to a human deciding to re-run.
