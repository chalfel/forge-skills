# Forge Skills

Agent Skills for [Forge](https://github.com/caiofelix/forge) — a spec-driven AI agent orchestrator.

These skills work well with **[Pi](https://github.com/badlogic/pi-mono/tree/main/packages/pi-coding-agent)** and other Agent Skills-compatible coding harnesses. They can also be used from Claude Code.

## What is Forge?

Forge is a VS Code extension + CLI that manages AI coding agents through structured specs. Instead of ad-hoc prompting, you define capabilities with "done when" criteria, break them into parallelizable tasks, and spawn AI agents in isolated git worktrees.

## Skills

> In **Pi**, use `/skill:<name>` or let the agent auto-load the skill.
> In **Claude Code**, skills appear as `/<name>` commands.

| Skill | Description |
|-------|-------------|
| **forge-init** | Initialize Forge in a project. Creates `.forge/` with KB templates, specs, config, and gitignore. |
| **forge-intake** | Intelligent info router. Analyzes what you say and saves to the right place (KB, specs, roadmap, inbox). |
| **forge-spec** | Generate a spec with parallelizable tasks from a product idea. |
| **forge-run** | Execute a spec/task by spawning an agent in a git worktree. |
| **forge-task** | Full task lifecycle with Linear as source of truth: play task, open PR, review PR, run spec, task done (tmux + worktrees + port allocation). |
| **forge-status** | Overview of all specs — progress, blocked tasks, what's ready. |
| **forge-audit** | Compare KB vs actual codebase. Detects drift. |
| **forge-review** | Review task PRs against spec done-when criteria and KB constraints. |
| **forge-security** | Security scan — OWASP top 10, secrets, auth issues, vulnerabilities. |
| **forge-diagram** | Generate architecture diagrams in Mermaid from the codebase. |
| **forge-whiteboard** | Create visual whiteboards as Excalidraw files. |
| **forge-business-plan** | Generate and save a business plan into the Forge KB. |
| **forge-persona** | Create user personas and save them into the Forge KB. |
| **forge-design** | Create UI/UX specs, wireframes, and design system docs for Forge. |
| **forge-report** | Generate stakeholder-friendly status reports from Forge data. |
| **forge-vault** | Connect `.forge/` to Obsidian for backlinks, graph view, search, and mobile access. |

## Install in Pi

### Option 1: Install as a local pi package

```bash
pi install /absolute/path/to/forge-skills
```

Or from git:

```bash
pi install git:github.com/caiofelix/forge-skills
```

Then reload Pi:

```bash
/reload
```

### Option 2: Copy the skill folders directly

```bash
# All skills
cp -r forge-*/ ~/.agents/skills/

# Or individual skills
cp -r forge-spec/ ~/.agents/skills/
cp -r forge-init/ ~/.agents/skills/
```

## Install in Claude Code

```bash
# All skills
cp -r forge-*/ ~/.claude/skills/

# Or individual skills
cp -r forge-spec/ ~/.claude/skills/
cp -r forge-init/ ~/.claude/skills/
```

Restart the harness after installation so the new skills are discovered.

## .forge/ Structure

```text
.forge/
├── kb/                 # Knowledge base (injected into every agent)
│   ├── architecture.md # Stack, patterns, constraints
│   ├── business.md     # Product rules, vision, personas
│   ├── roadmap.md      # Now / Next / Later / Vision
│   └── ...             # Other KB docs (personas, business-plan, design-system, etc.)
├── specs/              # One .md per capability
│   └── *.md
├── inbox.md            # Ideas for the future
├── config.md           # Agent definitions + settings
├── runs/               # Agent logs (gitignored)
├── index.md            # Optional Obsidian home page
├── .obsidian/          # Optional Obsidian vault config
└── .gitignore
```

## Obsidian Integration

If the user has Obsidian, use `forge-vault` to make `.forge/` an Obsidian-friendly vault.

That enables:
- backlinks and graph view for KB/spec relationships
- wikilinks between docs
- mobile access to the KB
- Excalidraw + Mermaid-friendly documentation inside the vault

## Spec Format

```md
# Users can login with GitHub
<!-- status: todo -->
<!-- priority: high -->
<!-- created: 2026-03-30 -->
<!-- branch: forge/bold-ember-321 -->

**What exists:** Basic email/password auth
**What's missing:** GitHub OAuth integration

### Task: Backend OAuth flow
<!-- status: todo -->
<!-- parallelizable: yes -->
<!-- deps: none -->
<!-- repo: backend -->

**Done when:**
- GET /auth/github redirects to GitHub
- Callback stores tokens in DB
```

## License

MIT
