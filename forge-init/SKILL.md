---
name: forge-init
description: Initialize Forge in a project. Creates .forge/ directory with QG templates, config, and gitignore. Use when the user says "init forge", "setup forge", "initialize forge", or wants to start using Forge in a project.
argument-hint: [optional project description]
---

# Forge Init

Initialize Forge in the current project.

## Process

### 1. Create Directory Structure

```
.forge/
├── kb/
│   ├── architecture.md
│   └── business.md
├── specs/
├── config.md
├── runs/
└── .gitignore
```

### 2. Create config.md

```markdown
# Forge Config
<!-- auto-advance: confirm -->

## Agents

### default
<!-- role: spec,execute -->
You are a senior software engineer. Analyze the codebase, understand existing patterns, and implement clean, tested code.
```

### 3. Create .gitignore

```
runs/
```

### 4. Create KB Templates

Scan the codebase to pre-fill:
- `architecture.md` — detect stack from package.json/Cargo.toml/go.mod, list key directories, identify patterns
- `business.md` — leave as template for the user to fill

### 5. If user provided `$ARGUMENTS`

Use the project description to pre-fill the business.md with relevant context.

### 6. Output

Tell the user:
- What was created
- To fill in `.forge/kb/business.md` with their product vision
- To create their first spec with `/forge-spec`
