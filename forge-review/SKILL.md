---
name: forge-review
description: Review Forge tasks that have PRs open. Use when the user says "review", "forge review", "check the PR", or wants to review agent work. Triggers on tasks with status in_review.
argument-hint: [task name or spec name]
---

# Forge Review

Review completed agent work against the spec's done-when criteria.

## Task Lifecycle Context

```text
todo → in_progress → in_review → done
                         ↓
                  changes_requested → in_progress → in_review → ...
```

## Process

### 1. Find Tasks in Review

Scan `.forge/specs/*.md` for tasks with `<!-- status: in_review -->`.

### 2. Get the Diff

For each task in review:
- If `<!-- pr: URL -->` exists, use `gh pr diff {number}`
- Otherwise, use `git diff main...{branch}`

### 3. Review Against Spec

Compare the diff against:
- The task's **done-when** criteria
- KB constraints (architecture, business rules)
- Code quality and existing patterns

### 4. Write Review Feedback

If changes are needed, append to the task:

```markdown
**Review feedback:**
- Fix the hero CTA link — points to /register but should point to /login
- EN translation missing for the new pricing subtitle
- Remove unused import in pricing.tsx
```

Then set:
- `<!-- status: changes_requested -->`

If approved:
- `<!-- status: done -->`

If `.forge/.obsidian/` exists, preserve any YAML frontmatter already present in the spec file and avoid breaking `[[wikilinks]]`.

### 5. Re-run with Feedback

After review, the user can run the Forge run skill again (`/skill:forge-run` in Pi).
Tasks with `changes_requested` are treated as ready.
The child agent receives the review feedback in its prompt.

## Rules

- **Review against done-when criteria.** Not personal preference.
- **Be specific and actionable.** Every feedback item should be implementable.
- **Use the diff, not assumptions.** Base review on actual changes.
- **Set status clearly.** Either `done` or `changes_requested`.
- **Include PR URL in metadata** when available: `<!-- pr: URL -->`
- **If `.forge/.obsidian/` exists, preserve Obsidian-friendly markdown structure.**
