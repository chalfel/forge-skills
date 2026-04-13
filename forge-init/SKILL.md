---
name: forge-init
description: Initialize Forge for a product by bootstrapping a Linear team with the Forge layout (Now/Next/Later/Vision initiatives, KB project, Inbox project) and writing the local `~/.forge/config.json`. Use when the user says "init forge", "setup forge", "initialize forge", or wants to start using Forge on a new product.
argument-hint: [optional product name or team hint]
---

# Forge Init

Bootstrap a Linear team to host a Forge product, and prepare the local runtime state.

Forge is full Linear:

| Linear         | Forge                  |
|----------------|------------------------|
| Team           | Product / Workspace    |
| Initiative     | Roadmap horizon        |
| Project        | Spec                   |
| Issue          | Subtask                |
| Issue in `KB` project with `kb:*` label | KB document |

All Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`).

## Process

### 1. Resolve the team

Use `$ARGUMENTS` as the product name hint.

- List existing teams via Linear MCP.
- If a team matches (fuzzy, by name or key), confirm with the user and reuse it.
- Otherwise, offer to create a new team (key derived from the product name).

Abort if the user does not pick/confirm a team — `forge-init` must know which team it is operating on.

### 2. Create the roadmap initiatives

Inside the chosen team, ensure these four initiatives exist (create any that are missing). Idempotent: skip initiatives that already exist by name.

| Name     | Purpose                                           |
|----------|---------------------------------------------------|
| `Now`    | Active horizon — projects (specs) being built     |
| `Next`   | Queued — next up after Now                        |
| `Later`  | Non-committed — ideas with some shape             |
| `Vision` | Aspirational — long-term north stars              |

Each initiative holds projects (= Specs). `forge-intake` and `forge-spec` will place new projects under the correct initiative.

### 3. Create the KB project

Inside the team, create (or reuse) a project named `KB`:

- **Description:** `Knowledge Base for this product. Each issue is a KB document. Filter by label \`kb:*\`.`
- **State:** `backlog`
- **Not** attached to any initiative (it is reference material, not a deliverable).

Ensure these labels exist on the team (create any missing):

- `kb:architecture`
- `kb:business`
- `kb:roadmap`
- `kb:persona`
- `kb:design`
- `kb:api-standards`
- `kb:ops`

Any additional `kb:*` label can be created on demand by `forge-intake`.

### 4. Create the Inbox project

Inside the team, create (or reuse) a project named `Inbox`:

- **Description:** `Raw ideas and sparks. Triage into specs (new projects) or KB docs.`
- **State:** `backlog`

Ensure the label `idea` exists on the team. `forge-intake` routes exploratory items here.

### 5. Write `~/.forge/config.json`

```bash
mkdir -p "$HOME/.forge/runs"
```

Create or merge `~/.forge/config.json`:

```json
{
  "default_team_id": "<resolved team id>",
  "default_team_key": "<team key, e.g. ENG>",
  "kb_project_id": "<KB project id>",
  "inbox_project_id": "<Inbox project id>",
  "initiatives": {
    "now": "<id>",
    "next": "<id>",
    "later": "<id>",
    "vision": "<id>"
  },
  "max_parallel_tasks": 3,
  "port_range": [3000, 3999]
}
```

If the file already exists, merge non-destructively — preserve anything the user has customized (`max_parallel_tasks`, `port_range`, extra fields).

### 6. Seed the KB (optional)

If the repo looks like a codebase (has a manifest at the root), offer to auto-create a starter KB issue by scanning:

- **Architecture** (label `kb:architecture`): stack detected from `package.json` / `Cargo.toml` / `go.mod` / `pyproject.toml`, plus top-level directory map.

Only create this if the user says yes. Leave `kb:business`, `kb:persona`, etc. for the user (or `forge-persona`, `forge-business-plan`, `forge-design`) to fill in.

### 7. Output

Report:

- Team name + key + URL
- Four initiative URLs
- KB project URL
- Inbox project URL
- Path to `~/.forge/config.json`
- Next step suggestions: `forge-spec <capability>` (creates first real spec under `Now`), `forge-persona`, `forge-business-plan`.

## Rules

- **Never bootstrap without user confirmation on the team.** Products are expensive to undo in Linear.
- **Idempotent.** Re-running on an already-initialized team must not duplicate initiatives, projects, or labels.
- **Non-destructive config merge.** Never blow away existing `~/.forge/config.json` fields.
- **No local `.forge/` directory.** KB and specs live in Linear. Only `~/.forge/` (user-level) is used, for runtime state.
- **Do not create GitHub branches or other side effects.** `forge-init` only touches Linear + `~/.forge/`.
