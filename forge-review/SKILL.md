---
name: forge-review
description: Run a non-interactive Claude Code reviewer on a Forge subtask PR against its Linear spec (project) context. Use when the user says "review", "forge review", "check the PR", "revisa PR", or wants to review agent work. Triggers on Linear issues currently in `in_review` state.
argument-hint: [linear-issue-id | pr-number]
---

# Forge Review

Review a Forge subtask PR against its Linear project description (the Spec) and Knowledge Base, and post findings via `gh pr review`.

All Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`).

## Input

- A `linear-issue-id` (e.g. `ENG-123`) OR a `pr-number`.
- If neither is given, list Linear issues currently in `in_review` (filtered to `default_team_id` from `~/.forge/config.json`) and ask which one.

## Steps

### 1. Resolve the PR

- If given a `linear-issue-id`: fetch the PR URL from Linear (attachments or the comment posted by `forge-run` → `open-pr`). Fallback: `gh pr list --head feat/<issue-id>-*`.
- If given a `pr-number`: resolve the Linear issue from the branch name (`feat/<issue-id>-<slug>`).

### 2. Fetch review context

Via Linear MCP:

- Subtask (issue): title, description, labels
- Parent project (the Spec): title, description
- KB entries likely to matter, picked lazily by label — e.g. `kb:architecture` and `kb:business` always, plus anything the subtask touches (`kb:api-standards`, `kb:design`, ...). Fetch issues in the `KB` project of the same team, filtered by those labels.

### 3. Run the reviewer (non-interactive)

```bash
gh pr diff <pr-number> | claude -p "$(cat <<'PROMPT'
You are reviewing PR #<pr-number>.

Linear subtask:
  title: <subtask-title>
  description: <subtask-description>

Spec context (Linear project):
  title: <project-title>
  description: <project-description>

Relevant KB excerpts (from Linear KB project, fetched lazily):
<kb-excerpts-joined>

Review the diff piped on stdin against:
  - the subtask's done-when criteria
  - spec intent and KB constraints
  - architectural fit / existing patterns
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

Log stdout/stderr to `~/.forge/runs/<issue-id>-review.log` (create the dir if missing).

### 4. Report back to the user

Return the reviewer's final decision (approved / changes requested) and a count of comments posted. Do NOT change Linear status — that transition belongs to `forge-run` → `flows/task-done.md` after merge, or to a human decision.

## Rules

- **Review against Linear data, not assumptions.** The Spec is the Linear project description; the subtask's done-when lives in the Linear issue description.
- **KB is lazy.** Fetch KB issues by label at review time — never assume a cached copy.
- **Be specific and actionable.** Every comment cites `file:line`.
- **Do not transition Linear state.** Only comment and submit `--approve` / `--request-changes`.
- **Log everything** to `~/.forge/runs/<issue-id>-review.log`.
