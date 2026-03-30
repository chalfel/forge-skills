# Forge Skills

Claude Code skills for [Forge](https://github.com/caiofelix/forge) — a spec-driven AI agent orchestrator.

## What is Forge?

Forge is a VS Code extension + CLI that manages AI coding agents through structured specs. Instead of ad-hoc prompting, you define capabilities with "done when" criteria, break them into parallelizable tasks, and spawn AI agents in isolated git worktrees.

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **forge-init** | `/forge-init` | Initialize Forge in a project. Creates `.forge/` with QG, specs, config. |
| **forge-intake** | `/forge-intake` | Intelligent info router. Analyzes what you say and saves to the right place (QG, specs, roadmap, inbox). |
| **forge-spec** | `/forge-spec` | Generate a spec with parallelizable tasks from a product idea. |
| **forge-run** | `/forge-run` | Execute a spec/task by spawning an agent in a git worktree. |
| **forge-status** | `/forge-status` | Overview of all specs — progress, blocked tasks, what's ready. |
| **forge-audit** | `/forge-audit` | Compare KB (knowledge base) vs actual codebase. Detects drift. |
| **forge-review** | `/forge-review` | Code review against spec done-when criteria, QG constraints, and quality. |
| **forge-security** | `/forge-security` | Security scan — OWASP top 10, secrets, auth issues, vulnerabilities. |
| **forge-diagram** | `/forge-diagram` | Generate architecture diagrams in Mermaid from the codebase. |
| **forge-whiteboard** | `/forge-whiteboard` | Create visual whiteboards as Excalidraw files. |

## Install

Copy the skills you want to `~/.claude/skills/`:

```bash
# All skills
cp -r forge-*/ ~/.claude/skills/

# Or individual skills
cp -r forge-spec/ ~/.claude/skills/
cp -r forge-init/ ~/.claude/skills/
```

Restart Claude Code. Skills appear as `/forge-*` commands.

## .forge/ Structure

```
.forge/
├── kb/                 # Knowledge base (injected into every agent)
│   ├── architecture.md # Stack, patterns, constraints
│   ├── business.md     # Product rules, vision, personas
│   └── roadmap.md      # Now / Next / Later / Vision
├── specs/              # One .md per capability
│   └── *.md
├── inbox.md            # Ideas for the future
├── config.md           # Agent definitions + settings
├── runs/               # Agent logs (gitignored)
└── .gitignore
```

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
