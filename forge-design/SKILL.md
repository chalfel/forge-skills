---
name: forge-design
description: Generate UI/UX design specs, wireframes, user flows, and design system definitions, saved as Linear KB issues (`kb:design` / `kb:design-system`). Use when the user says "design", "wireframe", "user flow", "UI spec", "design system", "layout", "screen design", "mockup", or wants to define the visual/interaction layer of a capability before implementation.
argument-hint: [capability or screen to design — e.g. "onboarding flow", "dashboard layout", "settings page"]
---

# Forge Design — Linear-native UI/UX Spec

Generate design specs that either live as standalone KB issues (`kb:design`, `kb:design-system`) or as a `## Design` block appended to an existing Linear project description (the Spec). Agents fetch these lazily via Linear MCP when implementing UI.

Team is `default_team_id`, KB project is `kb_project_id`, both in `~/.forge/config.json`.

## Input

`$ARGUMENTS` = screen, flow, or component to design.

If none, ask: "What screen, flow, or component do you want to design?"

## Process

### 1. Load context from Linear

Via MCP:

- `kb:business` — product vision, core rules
- `kb:persona` (especially `kb:primary-persona`) — who is using this, jobs-to-be-done
- `kb:architecture` — frontend stack, component library
- `kb:design-system` — existing tokens, patterns, components (if already defined)
- The target project (spec) description, if the design is for a specific capability

### 2. Understand the user job

Clarify before designing:

- **Who** uses this screen (which persona)
- **What** they are trying to accomplish (JTBD)
- **When** they reach this screen (what came before / what comes after)
- **Success state** — what "done" looks like for the user

### 3. Decide the target

| Scope                         | Where it goes                                                           |
|-------------------------------|-------------------------------------------------------------------------|
| One capability (one Spec)     | `## Design` section appended to the Linear project's description        |
| Reusable pattern / component  | New issue in KB project, label `kb:design-system`                       |
| Cross-cutting flow / system   | New issue in KB project, labels `kb:design` + relevant `kb:*` context   |

### 4. Compose the design

```markdown
## Design — <screen/flow name>

### User
- **Persona:** <primary persona name>
- **Job-to-be-done:** <specific outcome>
- **Entry point:** <where user arrives from>
- **Exit:** <where user goes after success>

### Flow (steps)
1. <Step 1 — user action → system response>
2. <Step 2>
3. <Step 3>

### Screens / Components
#### <Screen / Component name>
- **Purpose:** <one-line>
- **Layout:** <columns, hierarchy, fold priority>
- **Primary action:** <what the user clicks first>
- **Secondary actions:**
- **Empty state:**
- **Loading state:**
- **Error states:**

### Interaction notes
- <Gesture / keyboard / animation cues, if relevant>
- <Accessibility: focus order, labels, contrast>

### Design tokens referenced
- <spacing / color / typography tokens from `kb:design-system`>

### Open questions
- [ ] <Decision that needs product/stakeholder input>
```

Keep each section tight. One screen of markdown per design issue, ideally.

### 5. Save to Linear

**If the design is for a specific Spec:**

- Fetch the target Linear project description.
- Append the `## Design` block (preserve everything above it).
- Add a `kb:design` label on any issues in that project that are most affected.

**If the design is a reusable pattern or the first entry of a design system:**

- Create a new issue in the `KB` project.
  - **Title:** `Design — <pattern / component / flow name>`
  - **Labels:** `kb:design` (+ `kb:design-system` if it is a reusable component/token)
  - **State:** `backlog` (or team's `reference` state)
  - **Description:** the markdown above.

If a `kb:design-system` issue already exists, prefer updating it with a new `## <Component>` section over creating parallel issues.

### 6. Cross-check

After saving, scan the team for friction:

- Do any active Linear projects imply UI but have no `kb:design` context? Suggest a design pass.
- Does the persona's primary job flow end-to-end, or does a step break into a dead-end?
- Are there existing `kb:design-system` tokens that this design should reuse instead of inventing new ones?

### 7. Output

Report:

- Linear URL of the updated project or new KB issue
- Tokens introduced (if any) — surface them for the user to confirm before they become canonical in `kb:design-system`
- Implementation hand-off: link to the Spec (Linear project) that will consume this design

## Rules

- **Start with the user.** No screen without a persona + JTBD.
- **Reuse before invent.** Check `kb:design-system` first. Only create new tokens with explicit reason.
- **Describe states, not pixels.** Default, empty, loading, error, success — every screen gets them.
- **Mobile considerations** unless the product is desktop-only and that is documented.
- **Accessibility baked in.** Focus order, labels, contrast — not an afterthought.
- **Append, never overwrite.** Existing Linear project descriptions and KB issues grow, they don't get erased.
- **Save only to Linear.** Never write to `.forge/`.
