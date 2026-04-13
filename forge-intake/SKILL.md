---
name: forge-intake
description: Intelligent information router for Forge. Classifies what the user says and routes it into Linear — KB docs (issues in the KB project with kb:* labels), new specs (Linear projects under the right initiative), or raw ideas (Inbox project). Use when the user shares product context, technical decisions, feature ideas, business rules, or any information that needs to be categorized and stored. Triggers on "save this", "add to forge", "here's some context", "anota aí", or any unstructured dump of project info.
argument-hint: [any information, context, decision, or idea]
---

# Forge Intake — Linear Information Router

Classify what the user says and route it to the correct place in Linear.

All Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`). The target team is `default_team_id` from `~/.forge/config.json` (run `forge-init` first if missing).

## Input

The user provides: `$ARGUMENTS`.

If no arguments, ask: "What information do you want to add?"

## Classification rules

Analyze the input and classify into one or more categories. A single message may contain multiple types.

### 1. Architecture → KB issue, label `kb:architecture`
Technical decisions, stack choices, patterns, constraints, infrastructure.
- "We use NestJS with Prisma"
- "All APIs must be REST, no GraphQL"
- "Database is PostgreSQL on Supabase"

### 2. Business → KB issue, label `kb:business`
Product rules, business logic, pricing, compliance.
- "Users must verify email before posting"
- "Free tier is limited to 3 projects"
- "LGPD compliance is required"

### 3. Persona → KB issue, label `kb:persona`
Target users, ICPs, user archetypes. Consider invoking `forge-persona` for a full structured persona.

### 4. Design → KB issue, label `kb:design`
Design system tokens, component conventions, UX guidelines. Consider invoking `forge-design`.

### 5. Business plan / go-to-market → KB issue, label `kb:business`
Full plan content is better produced by `forge-business-plan`. If user dumps raw GTM info, save it as a KB issue for now and suggest running `forge-business-plan` for a structured version.

### 6. API standards / Ops / other domain → KB issue, new label `kb:<topic>`
If the input is important context that doesn't fit existing `kb:*` labels, create a new `kb:<topic>` label on the team and attach it. Keep labels lowercase, dash-separated, always prefixed with `kb:`.

### 6b. Repositories → update the `kb:repos` KB issue
Statements like "we have a repo called web at github.com/acme/web", "add backend repo", "move the mobile app to develop branch". Find the issue labeled `kb:repos` in the team's `KB` project, parse its markdown table, add/update the matching row, and save.

Row schema: `| Name | Clone URL | Default branch | Setup |`.

If no `kb:repos` issue exists yet, create it with the starter format from `forge-init`.

`forge-bootstrap` reads this issue to clone everything on a new machine — so keep the table shape stable.

### 7. Roadmap item → place under a Linear initiative
- "Now" items → under the `Now` initiative
- "Next quarter" items → under `Next`
- "Someday" items → under `Later`
- "North star" items → under `Vision`

Roadmap items are typically specs that are not yet detailed. Create a Linear project in the right initiative, state `backlog`, with the user's phrasing as the description. If the user wants it fleshed out, invoke `forge-spec`.

### 8. Spec (capability) → invoke `forge-spec`
Feature requests, capability ideas, bugs. Anything that's "users should be able to X". Delegate to `forge-spec` to create the Linear project + subtask issues properly.

### 9. Inbox (exploratory) → issue in the `Inbox` project, label `idea`
Sparks and "what if..." — too vague for a spec, too tactical for roadmap, too unshaped for KB.
- "What if we linked GitHub orgs to auto-detect architecture?"
- "Maybe we should have a plugin system"

### 10. Agent / workflow preferences → `~/.forge/config.json`
Defaults like `max_parallel_tasks`, port range, preferred editor, etc. Merge non-destructively.

## Process

### 1. Load config
Read `~/.forge/config.json`. If it does not exist, stop and tell the user to run `forge-init` first.

### 2. Fetch current Linear state (minimal)
Via MCP, list:
- Existing team labels (to avoid duplicate `kb:*` creation)
- Existing initiatives (should be `Now/Next/Later/Vision` from init)
- Existing projects (`KB`, `Inbox`, and any specs)

### 3. Classify and show the routing plan

Before writing anything, tell the user what you detected and where it will go:

```
I detected the following information:

→ Architecture: "NestJS + Prisma + PostgreSQL"
  Will create/update KB issue "Stack" with label kb:architecture

→ Business rule: "Free tier limited to 3 projects"
  Will append to KB issue "Plan tiers" (label kb:business)

→ Spec: "Users can upgrade from free to premium"
  Will invoke forge-spec to create a Linear project under the Now initiative

→ Inbox: "Maybe a Slack integration someday"
  Will create issue in Inbox project with label `idea`

Proceeding...
```

### 4. Write to Linear

- **KB updates**: look for an existing KB issue with a matching title (or scoped to the same `kb:*` label). If found, append to its description (preserve existing content, add a dated section). If not, create a new issue in the `KB` project with the appropriate `kb:*` label.
- **Specs**: hand off to `forge-spec` with the user's input as arguments.
- **Roadmap/initiative shifts**: update the project's `initiative` association.
- **Inbox**: create an issue in the `Inbox` project with the `idea` label. Include a short title and the user's words verbatim in the description.

### 5. Confirm
Show the user what was written, with Linear URLs.

## Multi-input handling

The user may dump a lot at once. Split into as many targets as needed:

```
User: "We're building a social media scheduler in Elixir/Phoenix with LiveView.
Users can schedule posts to Twitter, LinkedIn, Instagram. Want to add TikTok
later. Free users get 10 scheduled posts/month, premium unlimited. Need GDPR."

→ kb:architecture — "Elixir/Phoenix + LiveView"
→ kb:business    — "Scheduling limits: free=10/mo, premium=unlimited"
→ kb:business    — "GDPR compliance required"
→ Spec (Now)     — "Users can schedule posts to Twitter" (forge-spec)
→ Spec (Now)     — "Users can schedule posts to LinkedIn" (forge-spec)
→ Spec (Now)     — "Users can schedule posts to Instagram" (forge-spec)
→ Roadmap (Later)— "TikTok integration" (Linear project under Later)
```

## Rules

- **Never overwrite** existing KB content. Append with a dated section.
- **Ask if ambiguous.** If it could be KB or spec, ask.
- **One input can fan out.** Don't force a single classification.
- **Preserve Linear formatting.** Use markdown inside issue descriptions.
- **Respect team labels.** Create new `kb:*` labels only when needed and always with the `kb:` prefix.
- **Delegate specs to `forge-spec`.** Don't inline the spec creation logic here.
- **Never write to `.forge/`**. Only `~/.forge/config.json` for workflow prefs.
