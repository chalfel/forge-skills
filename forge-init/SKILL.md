---
name: forge-init
description: Initialize Forge in a project. Creates .forge/ directory with KB templates, specs, config, and gitignore. Use when the user says "init forge", "setup forge", "initialize forge", or wants to start using Forge in a project.
argument-hint: [optional project description]
---

# Forge Init

Initialize Forge in the current project.

## Process

### 1. Detect Environment

Check:
- Whether `.forge/` already exists
- Whether the user mentioned Obsidian or a vault
- Whether Obsidian appears to be installed (`~/Library/Application Support/obsidian/` on macOS or `~/.config/obsidian/` on Linux)

If Obsidian is available or the user asked for it, enable **Obsidian mode** for `.forge/`.

### 2. Create Directory Structure

```text
.forge/
├── kb/
│   ├── architecture.md
│   ├── business.md
│   └── roadmap.md
├── specs/
├── inbox.md
├── config.md
├── runs/
├── index.md                 # if Obsidian mode
├── .obsidian/               # if Obsidian mode
└── .gitignore
```

### 3. Create config.md

```markdown
# Forge Config
<!-- auto-advance: confirm -->

## Agents

### default
<!-- role: spec,execute -->
You are a senior software engineer. Analyze the codebase, understand existing patterns, and implement clean, tested code.
```

### 4. Create .gitignore

Always include:

```text
runs/
```

If Obsidian mode is enabled, also ignore personal workspace state:

```text
.obsidian/workspace.json
.obsidian/workspace-mobile.json
```

### 5. Create KB Templates

Scan the codebase to pre-fill:
- `architecture.md` — detect stack from package.json/Cargo.toml/go.mod, list key directories, identify patterns
- `business.md` — leave as template for the user to fill
- `roadmap.md` — create a basic `Now / Next / Later / Vision` structure

If Obsidian mode is enabled:
- Add YAML frontmatter with tags to new markdown files
- Create `.forge/index.md` with wikilinks to the main docs
- Create `.forge/.obsidian/app.json` with minimal shared settings

### 6. If user provided `$ARGUMENTS`

Use the project description to pre-fill `business.md` with relevant context.

### 7. Output

Tell the user:
- What was created
- Whether Obsidian mode was enabled
- To fill in `.forge/kb/business.md` with their product vision
- To create their first spec with `/forge-spec` (or `/skill:forge-spec` in Pi)
- If Obsidian mode is enabled, to open `.forge/` as a vault

## Rules

- **Never overwrite an existing Forge setup blindly.** Merge or ask when `.forge/` already exists.
- **If `.forge/.obsidian/` exists, preserve it.** Don't replace an existing vault config.
- **Keep Obsidian optional.** Forge should still work perfectly without it.
