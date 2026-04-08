---
name: forge-vault
description: Connect Forge to Obsidian. Detects or creates an Obsidian vault for the .forge/ directory, enabling graph view, backlinks, search, and mobile access to the KB. Use when the user says "obsidian", "vault", "connect to obsidian", "forge vault", "second brain", or wants to use Obsidian as their KB viewer.
argument-hint: [optional vault path or "init"]
---

# Forge Vault — Obsidian Integration

Connect your Forge KB to Obsidian for visual navigation, graph view, backlinks, and mobile access. Since Forge is already 100% markdown, this is zero-migration — just point Obsidian at the right folder.

## Input

The user provides: `$ARGUMENTS`

If no arguments, detect existing Obsidian setup or offer to create one.

## Process

### 1. Detect Existing Setup

Check:
- Does `.forge/` exist? If not, run the Forge init skill first (`/skill:forge-init` in Pi).
- Does `.forge/.obsidian/` exist? If yes, vault is already connected.
- Does the user have Obsidian installed? Check for `~/Library/Application Support/obsidian/` (macOS) or `~/.config/obsidian/` (Linux).

### 2. Create Vault Config

If no vault exists, create `.forge/.obsidian/` with minimal config:

```
.forge/
├── .obsidian/
│   ├── app.json
│   └── workspace.json
├── kb/
│   ├── architecture.md
│   ├── business.md
│   ├── roadmap.md
│   └── ...
├── specs/
│   └── ...
└── inbox.md
```

Create `.forge/.obsidian/app.json`:
```json
{
  "newFileLocation": "folder",
  "newFileFolderPath": "kb",
  "showUnsupportedFiles": false,
  "strictLineBreaks": true,
  "readableLineLength": true
}
```

### 3. Add Obsidian Enhancements to KB Docs

Add frontmatter and wikilinks to existing KB docs to make them Obsidian-native:

For each `.forge/kb/*.md`, add YAML frontmatter if not present:

```yaml
---
tags: [forge, kb, architecture]
aliases: [arch, stack]
---
```

For each `.forge/specs/*.md`:

```yaml
---
tags: [forge, spec, todo]
priority: high
created: 2026-03-30
---
```

### 4. Create Obsidian-Friendly Index

Create `.forge/index.md` as the vault home page:

```markdown
# Forge — [Project Name]

## Knowledge Base
- [[kb/architecture|Architecture]]
- [[kb/business|Business]]
- [[kb/roadmap|Roadmap]]
- [[kb/personas|Personas]]

## Specs
- [[specs/github-oauth|GitHub OAuth]] — todo (2/4 tasks)
- [[specs/billing-service|Billing Service]] — in_progress (1/3 tasks)

## Quick Links
- [[inbox|Inbox]] — ideas for the future
- [[config|Config]] — agent definitions
```

### 5. Add .obsidian/ to .gitignore

The `.obsidian/` folder contains user-specific workspace state. Add to `.forge/.gitignore`:

```
runs/
.obsidian/workspace.json
.obsidian/workspace-mobile.json
```

But DO commit `.obsidian/app.json` so vault settings are shared.

### 6. Suggest Obsidian Plugins

Tell the user about plugins that enhance Forge in Obsidian:

- **Excalidraw** — visual diagrams inline (works with Forge whiteboard output)
- **Mermaid** — renders Mermaid blocks from Forge diagram output
- **Kanban** — can view specs as a kanban board
- **Dataview** — query specs by status, priority, tags
- **Git** — auto-commit vault changes
- **Templater** — templates for new specs, KB docs

Example Dataview query for specs:
```dataview
TABLE priority, status, file.mtime as "Updated"
FROM "specs"
SORT priority ASC, file.ctime ASC
```

### 7. Tell the User

Output:
- "Obsidian vault created at `.forge/`"
- "Open Obsidian → Open folder as vault → select `.forge/`"
- "Your KB, specs, and inbox are now browsable with graph view, backlinks, and search"
- "Install Excalidraw and Dataview plugins for the best experience"

## Obsidian Mode Contract

A project with `.forge/.obsidian/` is in **Obsidian mode**.

All Forge skills that write to `.forge/` should detect this marker and:
- Add YAML frontmatter with tags to newly created markdown files
- Preserve frontmatter already present in existing files
- Use `[[wikilinks]]` when referencing other docs (e.g. specs mentioning architecture docs)
- Keep filenames stable so backlinks and graph connections stay valid

This makes the graph view useful while keeping the markdown readable outside Obsidian too.

## Rules

- **Don't modify existing content.** Only add frontmatter and create .obsidian config.
- **Respect existing vaults.** If `.obsidian/` already exists, don't overwrite.
- **Keep it optional.** Forge works without Obsidian. This just enhances the experience.
- **Commit app.json, ignore workspace.json.** Workspace is personal, app settings are shared.
- **Wikilinks are additive.** Adding `[[links]]` doesn't break regular markdown renderers — they just show as text.
