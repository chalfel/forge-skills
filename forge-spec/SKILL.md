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

### 2. Scan the Codebase
Use Glob and Grep to understand:
- What modules/files already exist related to this capability
- What patterns are used (frameworks, conventions)
- What infrastructure can be reused

### 3. Generate the Spec

Create a file at `.forge/specs/{slug}.md` in this exact format:

```markdown
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

### 4. Determine E2E Tests

After generating the tasks, evaluate whether the capability has **user-facing flows that can be automated end-to-end**. A capability qualifies for E2E tests when it involves:
- UI interactions (clicks, form submissions, navigation)
- Multi-step user flows (signup → dashboard, checkout → confirmation)
- Critical business paths (payment, authentication, data creation)

If the capability qualifies, add a dedicated E2E test task to the spec:

```markdown
### Task: E2E tests for [capability name]
<!-- status: todo -->
<!-- parallelizable: no -->
<!-- deps: [all implementation tasks] -->

**Done when:**
- E2E test covers the Demo scenario described above
- Test runs green in CI
- Test follows existing e2e patterns in the codebase (file location, naming, helpers)
```

#### Playwright video recording

If the project uses **Playwright** for E2E tests, the test task MUST include video recording configured with `retain-on-failure` so failed test runs produce a video for debugging. The test file must follow this pattern:

```typescript
import { test, expect } from '@playwright/test';

test.use({
  video: {
    mode: 'retain-on-failure',
    size: { width: 1280, height: 720 },
  },
});

test.describe('[Capability name]', () => {
  test('[Demo scenario description]', async ({ page }) => {
    // Steps that reproduce the Demo described in the spec
  });
});
```

And `playwright.config.ts` should have a baseline video config:

```typescript
export default defineConfig({
  use: {
    video: 'retain-on-failure',
  },
});
```

**Video files are saved to the `test-results/` directory** and are only kept for failed tests, keeping CI artifacts lean.

#### Detection rules
- **Playwright detected** → look for `playwright.config.ts`, `@playwright/test` imports, or a `e2e/`/`tests/` directory with `.spec.ts` files.
- **Cypress detected** → follow existing Cypress patterns instead.
- **No E2E framework detected** → recommend Playwright as default and include a setup task before the E2E test task.
- **No UI (pure API/CLI)** → skip the E2E test task. The "Done when" criteria on implementation tasks are sufficient.

### 5. Offer to Split (if large)
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
