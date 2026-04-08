---
name: forge-persona
description: Create detailed user personas and save to the Forge KB. Builds empathy-driven profiles with jobs-to-be-done, pain points, behaviors, and decision drivers. Use when the user says "persona", "user persona", "who is our user", "target user", "ideal customer", "ICP", "user profile", or wants to understand their users better.
argument-hint: [persona type or user description — e.g. "solo developer", "marketing manager at startup"]
---

# Forge Persona

Create detailed, actionable user personas and save them to `.forge/kb/personas.md`. These become part of the Knowledge Base, ensuring agents build features that serve real user needs.

## Input

The user provides: `$ARGUMENTS`

If no arguments, ask: "Who are your users? Describe the primary person who uses (or would use) your product."

## Process

### 1. Gather Context

Read:
- `.forge/kb/business.md` — product vision, target market
- `.forge/kb/business-plan.md` — target segments, value proposition
- `.forge/specs/*.md` — what's being built (reveals implicit user assumptions)
- Any existing `.forge/kb/personas.md`

Also check whether `.forge/.obsidian/` exists.
If it does, the project is in **Obsidian mode**:
- Add YAML frontmatter to newly created KB docs
- Preserve existing frontmatter when updating files
- Use `[[wikilinks]]` when referencing related KB docs or specs in prose

### 2. Interview (if needed)

If the user gave a vague description, ask focused questions:
- "What does this person's day-to-day look like?"
- "What's frustrating them right now about [problem area]?"
- "How do they currently solve this? What tools do they use?"
- "What would make them switch to something new?"
- "Where do they hang out online? How do they discover new tools?"

### 3. Generate Persona

Write to `.forge/kb/personas.md` (append if personas already exist):

If the project is in Obsidian mode, prepend this frontmatter:

```yaml
---
tags: [forge, kb, persona]
aliases: [personas, icp]
updated: {today's date}
---
```

Then write:

```markdown
# Personas
<!-- updated: {today's date} -->

## [Persona Name] — [One-line role description]
<!-- primary: true/false -->

### Profile
- **Role:** [Job title / situation]
- **Experience:** [Junior/Mid/Senior, years in field]
- **Tech comfort:** [Low/Medium/High]
- **Company size:** [Solo / Startup / SMB / Enterprise]
- **Budget authority:** [Yes/No, spending range]

### Jobs to be Done
What this person is trying to accomplish:
1. **Primary job:** [The main outcome they want]
2. **Related job:** [Adjacent need that our product also solves]
3. **Emotional job:** [How they want to FEEL — competent, in control, ahead of peers]

### Pain Points
What frustrates them today:
- **[Pain 1]:** [Description + how they cope today]
- **[Pain 2]:** [Description + how they cope today]
- **[Pain 3]:** [Description + how they cope today]

### Current Workflow
How they solve the problem today (before our product):
1. [Step 1 — what tool/process]
2. [Step 2]
3. [Step 3]
- **Time spent:** [hours/week on this workflow]
- **Biggest friction:** [where they lose time or get frustrated]

### Decision Drivers
What makes them choose a tool:
- **Must have:** [Non-negotiables — deal breakers if missing]
- **Nice to have:** [Differentiators that tip the scale]
- **Deal breakers:** [What makes them NOT choose a tool]
- **Price sensitivity:** [Free-only / Will pay if value is clear / Budget available]

### Behavior
- **Discovery:** [How they find new tools — Twitter, HN, YouTube, colleagues]
- **Evaluation:** [How they decide — free trial, docs, community, referral]
- **Adoption pattern:** [Try alone first → team / Need team buy-in first]
- **Retention signals:** [What behavior = they're sticking around]
- **Churn signals:** [What behavior = they're about to leave]

### Quotes (Representative)
Things this persona would actually say:
- "[Quote that captures their frustration]"
- "[Quote that captures what they wish existed]"
- "[Quote about how they evaluate tools]"

### How Our Product Serves Them
- **Primary value:** [Which feature/capability matters most to them]
- **Aha moment:** [When do they first feel the value]
- **Success metric:** [How they measure if our product is working for them]

---
```

### 4. Multiple Personas

If the product serves multiple segments:
- Create 2-3 personas max (primary + secondary)
- Mark one as `<!-- primary: true -->`
- Explain how they differ in needs and how the product serves each

### 5. Connect to Product

After creating personas, check:
- Do current specs serve these personas' jobs-to-be-done?
- Are there pain points with no spec addressing them?
- Does the roadmap prioritize the primary persona's needs?

Suggest gaps: "Persona [X] needs [capability] but there's no spec for it."

### 6. Update Business KB

If `.forge/kb/business.md` has a thin "User Personas" section, offer to update it with a summary linking to the full personas doc.

## Rules

- **Based on reality, not imagination.** If the user has actual users, base personas on them. If not, base on the closest real people they know.
- **Specific > generic.** "Maria, 28, solo dev building a SaaS in Elixir" beats "developers aged 25-40".
- **Jobs-to-be-done > demographics.** What they're trying to accomplish matters more than their age.
- **Max 3 personas.** More than 3 means the product isn't focused enough.
- **Include quotes.** Fake quotes that ring true are the fastest way to build empathy.
- **Actionable.** Every persona section should inform a product decision. If it doesn't, cut it.
- **Living document.** Update as you learn more about real users. Initial personas are hypotheses.
- **Anti-personas too.** If relevant, note who is NOT the target (saves time rejecting bad feature requests).
- **If `.forge/.obsidian/` exists, keep the doc Obsidian-friendly.** Preserve/add frontmatter and use `[[wikilinks]]` where navigation benefits from it.
