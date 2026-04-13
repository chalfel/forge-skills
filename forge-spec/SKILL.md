---
name: forge-spec
description: Create a Forge spec as a Linear project with subtask-level issues. Use when the user wants to define a new capability, break it into parallelizable subtasks, or turn a product idea into a spec. Triggers on "create spec", "new spec", "forge spec", "break this into tasks", "criar spec", "nova spec", or mentions Forge in the context of defining work.
argument-hint: [capability or product idea in natural language]
---

# Forge Spec — Linear-native Spec Generator

Forge is full Linear. A **Spec is a Linear project**; the work items inside it are **Subtasks** (Linear issues). You do NOT create `.forge/specs/*.md` files anymore.

All Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`).

## Input

The user provides: `$ARGUMENTS`.

If no arguments, ask: "What capability should users have that they don't have yet?"

## Process

### 1. Read the KB

Read `.forge/kb/*.md` to understand architecture and business constraints. Every spec must respect these.

If `.forge/.obsidian/` exists, the project is in **Obsidian mode** — only relevant for KB files you might touch. The spec itself lives in Linear, not on disk.

### 2. Scan the codebase

Use Glob and Grep to understand:

- What modules/files already exist related to this capability
- What patterns / frameworks / conventions are used
- What infrastructure can be reused

### 3. Resolve the target workspace

Pick the Linear workspace/team from `~/.forge/config.json` (`default_team`, `default_project_prefix`). If absent, list teams via Linear MCP and ask.

### 4. Create the Linear project (the Spec)

Via Linear MCP, create a project with:

- **Name:** `<Capability — what the user can do>` (user-facing phrasing)
- **Description (Markdown):**

  ```markdown
  **What exists:** <brief summary of current state>

  **What's missing:** <gap between current state and desired capability>

  **Demo:** <how to demonstrate this capability when done — user-facing, not a curl command>

  ## KB constraints
  - <relevant architecture constraint>
  - <relevant business rule>
  ```

- **State:** `backlog`
- **Lead:** the user (if resolvable)

### 5. Create subtasks (Linear issues) under the project

2–5 issues per project. Each issue = one Forge subtask a Claude Code agent can play.

For each subtask, create an issue with:

- **Title:** short verb-phrase, user-facing where possible
- **Description (Markdown):**

  ```markdown
  **Done when:**
  - <observable, testable outcome>
  - <observable, testable outcome>

  **Parallelizable:** yes|no
  **Depends on:** <other subtask title | none>
  **Repo:** <folder-name if multi-repo workspace | omit>
  ```

- **Project:** the one from step 4
- **State:** `backlog`
- **Labels:** `forge`, plus `parallelizable` if applicable
- **Priority:** inherited from the spec, or explicit if known

Dependencies between subtasks use Linear's native blocking relations (`blocks` / `blocked by`) — do not encode them only in prose.

### 6. Offer to split (if large)

If the capability touches 3+ repos or has clearly independent parts, offer to split into 2–3 separate Linear projects instead of one.

### 7. Output

Report to the user:

- Linear project URL (the Spec)
- List of created subtasks with their Linear issue ids + URLs
- Next step: `play task <issue-id>` or `run spec <project-id>`

## Rules

- **Every spec MUST have a Demo.** If you can't demo it to a stakeholder, it's not a spec — it's a tech chore. Fold tech-only work into a spec that HAS a demo. Example: don't make a spec for "refactor billing" — make it "users can pay with PagSeguro" and include the refactor as a subtask within it.
- **Demo = user-facing.** "Run a curl command" is not a demo. "User clicks Login with GitHub and sees their dashboard" is a demo.
- **2–5 subtasks per spec.** More than 5 = split into multiple projects.
- **Focus on WHAT, not HOW.** No code snippets, no file-by-file plans in Linear.
- **Done-when must be verifiable.** Each item should be testable.
- **Respect the KB.** Architecture and business rules are constraints, surface them in the project description.
- **Use native Linear relations** for dependencies (`blocks` / `blocked by`), not prose.
- **If multi-repo workspace**, record the target repo in the subtask description.
- **Never create local `.forge/specs/*.md`.** Linear is the source of truth.
- **Flag unknowns.** If something needs a product decision, call it out in the description.
