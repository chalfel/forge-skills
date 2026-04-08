---
name: forge-spec
description: Create or generate a Forge spec (AI-native task definition). Use when the user wants to define a new capability, break it into parallelizable tasks, or generate a spec from a product idea. Triggers on "create spec", "new spec", "forge spec", "break this into tasks", or when working with .forge/specs/ files.
argument-hint: [capability or product idea in natural language]
---

# Forge Spec Generator

You are creating a Forge spec — an AI-native task definition that will be handed to AI agents in isolated git worktrees.

## Input

The user provides: `$ARGUMENTS`

If no arguments, ask: "What capability should users have that they don't have yet?"

## Process

### 1. Read the KB (if exists)
Read `.forge/kb/*.md` files to understand architecture and business constraints. Every spec must respect these.

Also check whether `.forge/.obsidian/` exists.
- If it exists, the project is in **Obsidian mode**.
- In Obsidian mode, add YAML frontmatter to new spec files and use `[[wikilinks]]` when referencing related KB docs or specs in prose.

### 2. Scan the Codebase
Use Glob and Grep to understand:
- What modules/files already exist related to this capability
- What patterns are used (frameworks, conventions)
- What infrastructure can be reused

### 3. Generate the Spec

Create a file at `.forge/specs/{timestamp}-{slug}.md` in this exact format:

```markdown
---
tags: [forge, spec, todo]
priority: medium
created: {today's date}
---

# [Capability — what the user can do]
<!-- status: todo -->
<!-- priority: medium -->
<!-- created: {today's date} -->
<!-- branch: forge/{random-adj}-{random-noun}-{random-3digits} -->

**What exists:** [Brief summary of current state]

**What's missing:** [Gap between current state and desired capability]

**Demo:** [How to demonstrate this capability when done. What does the user see/do? This must be a user-facing demonstration, not a technical validation.]

### Task: [Short task name]
<!-- status: todo -->
<!-- parallelizable: yes -->
<!-- deps: none -->

**Done when:**
- [Observable, testable outcome]
- [Observable, testable outcome]

### Task: [Another task]
<!-- status: todo -->
<!-- parallelizable: no -->
<!-- deps: First task name -->

**Done when:**
- [Observable, testable outcome]
```

If the project is **not** in Obsidian mode, omit the YAML frontmatter block and keep the rest of the format unchanged.

### 4. Offer to Split (if large)
If the capability touches 3+ repos or has clearly independent parts, offer to split into 2-3 separate spec files.

## Rules

- **Every spec MUST have a Demo.** If you can't demo it to a stakeholder, it's not a spec — it's a tech chore. Fold tech-only work into a spec that HAS a demo. Example: don't make a spec for "refactor billing" — make it "users can pay with PagSeguro" and include the refactor as a task within it.
- **Demo = user-facing.** "Run a curl command" is not a demo. "User clicks Login with GitHub and sees their dashboard" is a demo.
- **2-5 tasks per spec.** More than 5 = split into multiple specs.
- **Focus on WHAT, not HOW.** No code snippets, no file-by-file plans.
- **Done-when must be verifiable.** Each item should be testable.
- **Respect the KB.** Architecture and business rules are constraints.
- **Mark parallelizable tasks.** Tasks without deps should run simultaneously.
- **If multi-repo workspace**, assign `<!-- repo: folder-name -->` to each task.
- **Keep under 20 lines** per task. If longer, it's too detailed.
- **Flag unknowns.** If something needs a product decision, call it out.
- **If `.forge/.obsidian/` exists, preserve Obsidian compatibility.** Add frontmatter, keep filenames stable, and prefer `[[wikilinks]]` in narrative text.
