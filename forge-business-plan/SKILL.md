---
name: forge-business-plan
description: Generate or refine a business plan and save it as a Linear KB issue (label `kb:business-plan`). Covers value proposition, market, revenue model, competitive positioning, go-to-market, and metrics. Use when the user says "business plan", "business model", "revenue model", "go-to-market", "market analysis", "value proposition", or wants to define/refine business strategy.
argument-hint: [product name or business idea in natural language]
---

# Forge Business Plan — Linear-native

Generate a structured business plan and save it as an issue in the team's `KB` Linear project, tagged with label `kb:business-plan`. Every Claude Code agent can fetch it lazily via the Linear MCP (`https://mcp.linear.app/sse`) when it needs business context.

Team comes from `default_team_id` in `~/.forge/config.json`. The `KB` project id is `kb_project_id` in the same config.

## Input

The user provides: `$ARGUMENTS`.

If no arguments, ask: "What product or business are we planning?"

## Process

### 1. Gather context (from Linear)

Via MCP, read the current KB:

- `kb:business` — existing product vision, rules, personas
- `kb:architecture` — tech stack (informs feasibility)
- `kb:persona` — existing personas (informs target market)
- All projects (specs) in the team — reveals current capabilities

Build ON TOP of what exists. Do not contradict the current KB.

### 2. Interview the user

If the input is vague, ask targeted questions — one or two at a time, not a wall:

- "Who is the primary user? What pain are they feeling?"
- "How do they solve this today?"
- "Revenue model — subscription, usage-based, one-time?"
- "Top 2–3 competitors?"
- "What is your unfair advantage?"

Infer the rest and offer to refine later.

### 3. Compose the business plan

Target: one page. If it exceeds a screen, it is a thesis, not a plan.

```markdown
# Business Plan — <Product Name>
_Last updated: <today>_

## Problem
- The core problem in 1 sentence
- Who has it (specific, not "everyone")
- Status quo solution
- Why the status quo sucks

## Value Proposition
- One-liner: "We help <persona> do <outcome> without <pain>"
- Key differentiators (max 3)
- "Aha moment" — when the user first feels the value

## Target Market
- **Primary segment:**
- **Secondary segment:**
- **Market size estimate:** <TAM/SAM/SOM if relevant>
- **Beachhead:** <specific niche to dominate first>

## Revenue Model
- **Pricing model:** <subscription / usage-based / freemium / one-time>
- **Tiers:**
- **Key metric:** <what drives revenue — users, seats, usage, transactions>
- **Unit economics target:** <LTV, CAC, payback period if known>

## Competitive Landscape
| Competitor | Strength | Weakness | Our advantage |
|------------|----------|----------|---------------|
|            |          |          |               |

- **Positioning:** "Unlike <competitor>, we <key difference>"

## Go-to-Market
- **Launch channel:**
- **Acquisition strategy:**
- **First 100 users:**
- **Moat building:**

## Success Metrics
| Metric | Target (3mo) | Target (12mo) |
|--------|--------------|---------------|
|        |              |               |

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
|      |            |        |            |

## Open Questions
- [ ] <Decision to make>
- [ ] <Assumption to validate>
```

### 4. Save to Linear

- Search the `KB` project for an existing issue with label `kb:business-plan`.
- If it exists: update the description to the new version, preserving any useful prior content (append a dated "Changelog" section rather than destructive overwrite). Add a comment summarizing what changed.
- If it does not exist: create a new issue in the `KB` project.
  - **Title:** `Business Plan — <Product Name>`
  - **Labels:** `kb:business-plan`, `kb:business`
  - **State:** `backlog` (or the team's `reference` state if one exists)
  - **Description:** the plan markdown above.

Ensure the `kb:business-plan` label exists on the team; create it if missing.

### 5. Cross-check

- Read `kb:business` — if it is thin, offer to enrich it with insights from this plan (personas, core rules, vision) as a separate KB issue update.
- Compare against the `Now` initiative — does the roadmap align with the go-to-market plan? Suggest adjustments (new projects under `Now`, demotions to `Later`, etc.).

### 6. Output

Report:

- Linear issue URL for the business plan
- List of suggested KB / roadmap adjustments (with action buttons: "run forge-intake to apply" or similar)

## Rules

- **Be specific, not generic.** "Developers" is too broad. "Solo indie hackers building SaaS with AI agents" is a segment.
- **Challenge assumptions.** If the user says "everyone needs this", push back.
- **Numbers matter.** Even rough estimates force clarity.
- **One page.** If the plan does not fit on a screen, it is a thesis.
- **Living document.** Append updates over time — never destructive overwrite.
- **Connect to specs.** The plan should inform which projects end up under `Now`.
- **Save only to Linear.** Never write to `.forge/`.
