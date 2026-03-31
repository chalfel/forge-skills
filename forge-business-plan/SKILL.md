---
name: forge-business-plan
description: Generate or refine a business plan and save it to the Forge KB. Covers value proposition, market analysis, revenue model, competitive positioning, go-to-market, and metrics. Use when the user says "business plan", "business model", "revenue model", "go-to-market", "market analysis", "value proposition", or wants to define/refine their business strategy.
argument-hint: [product name or business idea in natural language]
---

# Forge Business Plan

Generate a structured business plan and save it to `.forge/kb/business-plan.md`. This becomes part of the Knowledge Base and is injected into every agent, ensuring all development stays aligned with the business strategy.

## Input

The user provides: `$ARGUMENTS`

If no arguments, ask: "What product or business are we planning?"

## Process

### 1. Gather Context

Read:
- `.forge/kb/business.md` — existing product vision, rules, personas
- `.forge/kb/architecture.md` — tech stack (informs feasibility)
- `.forge/kb/roadmap.md` — current direction
- `.forge/specs/*.md` — what's being built (informs current capabilities)

If these exist, build ON TOP of them. Don't contradict existing KB.

### 2. Research & Interview

Ask the user targeted questions if the input is vague:
- "Who is the primary user? What pain are they feeling?"
- "How do they solve this problem today?"
- "What's the revenue model — subscription, usage-based, one-time?"
- "Who are the top 2-3 competitors?"
- "What's your unfair advantage?"

Don't ask all at once. Ask the most critical ones, infer the rest, and offer to refine.

### 3. Generate Business Plan

Write to `.forge/kb/business-plan.md`:

```markdown
# Business Plan — [Product Name]
<!-- updated: {today's date} -->

## Problem
[What pain exists? Who feels it? How big is it?]
- The core problem in 1 sentence
- Who has this problem (specific, not "everyone")
- How they solve it today (status quo)
- Why the status quo sucks

## Value Proposition
[Why should someone switch to this product?]
- One-liner: "We help [persona] do [outcome] without [pain]"
- Key differentiators (max 3)
- The "aha moment" — when does the user first feel the value?

## Target Market
- **Primary segment:** [most important user group]
- **Secondary segment:** [expansion opportunity]
- **Market size estimate:** [TAM/SAM/SOM if relevant]
- **Beachhead:** [where to start — specific niche to dominate first]

## Revenue Model
- **Pricing model:** [subscription / usage-based / freemium / one-time]
- **Tiers:** [free / pro / enterprise — what's in each]
- **Key metric:** [what drives revenue — users, seats, usage, transactions]
- **Unit economics target:** [LTV, CAC, payback period if known]

## Competitive Landscape
| Competitor | Strength | Weakness | Our advantage |
|-----------|----------|----------|---------------|
| [Name] | [What they do well] | [Where they fail] | [Why we win here] |

- **Positioning statement:** "Unlike [competitor], we [key difference]"

## Go-to-Market
- **Launch channel:** [where do target users hang out?]
- **Acquisition strategy:** [content / paid / viral / sales / community]
- **First 100 users:** [specific plan to get the first 100]
- **Moat building:** [what makes this harder to copy over time]

## Success Metrics
| Metric | Target (3mo) | Target (12mo) |
|--------|-------------|---------------|
| Users | | |
| Revenue (MRR) | | |
| Retention | | |
| [Custom KPI] | | |

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [How to reduce] |

## Open Questions
- [ ] [Decision that needs to be made]
- [ ] [Assumption that needs validation]
```

### 4. Update Existing KB

If `.forge/kb/business.md` exists but is thin, offer to enrich it with insights from the business plan (personas, core rules, vision).

### 5. Connect to Roadmap

After generating, check `.forge/kb/roadmap.md`:
- Does the roadmap align with the go-to-market plan?
- Suggest roadmap adjustments if the business plan reveals priorities

## Rules

- **Be specific, not generic.** "Developers" is too broad. "Solo indie hackers building SaaS with AI agents" is a segment.
- **Challenge assumptions.** If the user says "everyone needs this", push back.
- **Numbers matter.** Even rough estimates force clarity. "$0-50 MRR users" vs "enterprise $500/mo" changes everything.
- **One page.** The business plan should fit on one screen. If it's longer, it's a business thesis, not a plan.
- **Living document.** This lives in KB and gets updated. It's not a one-time exercise.
- **Connect to specs.** The business plan should inform what specs get created and prioritized.
