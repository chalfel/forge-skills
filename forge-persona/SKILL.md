---
name: forge-persona
description: Create detailed user personas and save them as Linear KB issues (label `kb:persona`). Builds empathy-driven profiles with jobs-to-be-done, pain points, behaviors, and decision drivers. Use when the user says "persona", "user persona", "who is our user", "target user", "ideal customer", "ICP", "user profile", or wants to understand their users better.
argument-hint: [persona type or user description — e.g. "solo developer", "marketing manager at startup"]
---

# Forge Persona — Linear-native

Create detailed, actionable personas and store each one as an issue in the team's `KB` Linear project, tagged with label `kb:persona`. Agents fetch personas lazily via Linear MCP when they need user context.

Team is `default_team_id`, KB project is `kb_project_id`, both in `~/.forge/config.json`.

## Input

`$ARGUMENTS` = persona type or description.

If none, ask: "Who are your users? Describe the primary person who uses (or would use) your product."

## Process

### 1. Load context from Linear

Via MCP:

- `kb:business` and `kb:business-plan` — product vision, target market, value proposition
- Existing `kb:persona` issues — do not duplicate, extend/differentiate
- Projects (specs) in the team — reveal implicit user assumptions

### 2. Interview (if vague)

Ask focused questions — 1–2 at a time:

- "What does this person's day-to-day look like?"
- "What is frustrating them right now?"
- "How do they solve this today? What tools?"
- "What would make them switch to something new?"
- "Where do they hang out online?"

### 3. Compose the persona

Write the issue description using this template:

```markdown
# <Persona Name> — <One-line role description>
_Primary: yes|no_

## Profile
- **Role:**
- **Experience:**
- **Tech comfort:**
- **Company size:**
- **Budget authority:**

## Jobs to be Done
1. **Primary job:**
2. **Related job:**
3. **Emotional job:**

## Pain Points
- **<Pain 1>:** <description + how they cope today>
- **<Pain 2>:** <description + how they cope today>

## Current Workflow
1. <Step 1>
2. <Step 2>
- **Time spent:**
- **Biggest friction:**

## Decision Drivers
- **Must have:**
- **Nice to have:**
- **Deal breakers:**
- **Price sensitivity:**

## Behavior
- **Discovery:**
- **Evaluation:**
- **Adoption pattern:**
- **Retention signals:**
- **Churn signals:**

## Quotes (representative)
- "<Quote capturing frustration>"
- "<Quote capturing what they wish existed>"
- "<Quote about how they evaluate tools>"

## How Our Product Serves Them
- **Primary value:**
- **Aha moment:**
- **Success metric:**
```

### 4. Save to Linear

Create (or update) an issue in the `KB` project:

- **Title:** `Persona — <Persona Name>`
- **Labels:** `kb:persona` (also add `kb:business` if the persona maps to a revenue/pricing decision)
- **State:** `backlog` (or team's `reference` state if one exists)
- **Description:** the persona markdown above

If a persona with a similar title already exists, update it (append a dated changelog section; never destructive overwrite).

Mark exactly ONE persona issue as primary by adding the label `kb:primary-persona` (create the label if missing). If the user changes which persona is primary, move the label, do not duplicate.

### 5. Multiple personas

Max 3 issues with `kb:persona`. More than 3 = the product is not focused. Push back before creating a 4th.

### 6. Cross-check

After saving, scan projects (specs) in the team:

- Do current specs serve this persona's jobs-to-be-done?
- Are there pain points with no spec addressing them?
- Does the `Now` initiative prioritize the primary persona's needs?

Surface gaps: "Persona <X> has pain `<Y>` but no project addresses it. Want me to run `forge-spec`?"

### 7. Output

Report:

- Linear issue URL for each persona
- Gap list (pain points → missing specs)
- Next-step suggestions (`forge-spec` for gaps, `forge-business-plan` to refresh if personas shift the segment)

## Rules

- **Based on reality, not imagination.** If the user has actual users, base personas on them.
- **Specific > generic.** "Maria, 28, solo dev building a SaaS in Elixir" beats "developers aged 25–40".
- **Jobs-to-be-done > demographics.**
- **Max 3 personas.** More than 3 → the product is not focused enough.
- **Include quotes.** Fake quotes that ring true are the fastest empathy tool.
- **Actionable.** Every section must inform a product decision, or cut it.
- **Living document.** Append updates — never destructive overwrite.
- **Anti-personas too.** If relevant, note who is NOT the target (saves time rejecting bad feature requests) — same issue, under a `## Not our user` section.
- **Save only to Linear.** Never write to `.forge/`.
