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

## Linear Mapping (full Linear)

Forge is full Linear — there are no `.forge/specs/*.md` files anymore.

| Linear         | Forge                            |
|----------------|----------------------------------|
| Team           | Workspace / Product              |
| Project        | Spec                             |
| Issue          | Subtask                          |

A Spec is a Linear project; its description carries the `What exists / What's missing / Demo` narrative. Each subtask is a Linear issue inside that project. Native Linear `blocks` / `blocked by` relations replace `<!-- deps: -->`.

## Local state

Task-lifecycle skills (`forge-task`, `forge-run`, `forge-review`) persist runtime state under `~/.forge/`:

```text
~/.forge/
├── config.json      # linear token, default team, max_parallel_tasks, port_range
├── ports.json       # task-id → allocated port
├── sessions.json    # task-id → tmux target
├── worktrees.json   # task-id → { path, branch }
└── runs/            # reviewer logs (gitignored)
```

KB files (architecture, business, roadmap, personas, design, etc.) currently still live under `.forge/kb/*.md` in each repo. Migrating the KB into Linear (team-level docs + tags) is an in-flight direction — see the open discussion before authoring new KB content.

## License

MIT
