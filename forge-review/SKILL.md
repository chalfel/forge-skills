---
name: forge-review
description: Review a Forge subtask PR against its Linear spec (project) context. Use when the user says "review", "forge review", "check the PR", or wants to review agent work. Targets Linear issues currently in `in_review`.
argument-hint: [linear-issue-id | pr-number]
---

# Forge Review

Thin entry point. Forge is full Linear — reviews run against a Linear project (the Spec) and its issue (the Subtask). All review logic lives in **forge-task**.

## Dispatch

- If the user gave a `linear-issue-id` OR a `pr-number`, run `forge-task` → `flows/review-pr.md`.
- If the user said just "review" with no argument, list Linear issues whose state is `in_review` (via Linear MCP) and ask which one.

Do NOT reimplement the reviewer. Read `forge-task/flows/review-pr.md` — it fetches the subtask + project context from Linear, pipes `gh pr diff` into a non-interactive `claude -p` run, and has the child agent post comments via `gh pr review`.

## Rules

- **Review against Linear data.** The Spec is the Linear project description; the subtask's done-when lives in the Linear issue description. Never invent criteria.
- **Do not change Linear status here.** Reviewer only comments and submits `--approve` / `--request-changes`. `done` happens in `forge-task` → `flows/task-done.md` after merge.
- **Be specific and actionable.** Every comment should cite `file:line` where possible.
- **Log output** to `~/.forge/runs/<issue-id>-review.log`.
