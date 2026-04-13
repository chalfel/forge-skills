# Forge Skills

Agent Skills for [Forge](https://github.com/caiofelix/forge) — a spec-driven AI agent orchestrator.

These skills work well with **[Pi](https://github.com/badlogic/pi-mono/tree/main/packages/pi-coding-agent)** and other Agent Skills-compatible coding harnesses. They can also be used from Claude Code.

## What is Forge?

Forge is an AI-native development workflow. **Linear is the source of truth** (teams, projects, issues, labels); **Claude Code is the executor** running inside **tmux + git worktrees** on your machine. You define capabilities as Linear projects, break them into issues (subtasks), and spawn Claude Code agents in isolated worktrees — each with its own allocated dev-server port.

## Skills

> In **Pi**, use `/skill:<name>` or let the agent auto-load the skill.
> In **Claude Code**, skills appear as `/<name>` commands.

| Skill | Description |
|-------|-------------|
| **forge-init** | Bootstrap a Linear team: creates `Now/Next/Later/Vision` initiatives, `KB` project, `Inbox` project, `kb:*` labels, a starter `kb:repos` KB issue, and `~/.forge/config.json`. |
| **forge-bootstrap** | New-machine / new-team setup. Reads the team's `kb:repos` KB issue, clones every repo, runs setup commands, writes `~/.forge/config.json` + `~/.forge/repos/<team>.json`. |
| **forge-intake** | Intelligent info router. Classifies a dump and saves to Linear — KB issues, initiatives, new specs, Inbox, or the `kb:repos` list. |
| **forge-spec** | Create a spec as a Linear project with subtask-level issues (done-when criteria, parallelizable flag, native `blocks` relations). |
| **forge-run** | Full task lifecycle: play task, run spec, open PR, task done. Spawns Claude Code in a git worktree with a tmux window and allocated port. |
| **forge-review** | Non-interactive reviewer — pipes `gh pr diff` into `claude -p` with Linear spec + KB context, posts via `gh pr review`. |
| **forge-status** | Overview of Linear projects (specs) and issues (subtasks). Progress, blocked, ready to play, running locally. |
| **forge-audit** | Compare Linear KB + specs + roadmap against the actual codebase. Detects drift. |
| **forge-report** | Business-first status report, pulled from Linear initiatives/projects/issues. |
| **forge-business-plan** | Generate/refine a business plan saved as a KB issue (`kb:business-plan`). |
| **forge-persona** | Create user personas as KB issues (`kb:persona`). |
| **forge-design** | UI/UX specs, flows, design system — saved to Linear project descriptions or KB issues (`kb:design`, `kb:design-system`). |
| **forge-security** | Security scan — OWASP top 10, secrets, auth issues, vulnerabilities. |
| **forge-diagram** | Generate architecture diagrams in Mermaid from the codebase. |
| **forge-whiteboard** | Create visual whiteboards as Excalidraw files. |

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

## Linear Mapping (full Linear — nothing local except runtime state)

Forge stores everything in Linear. There are no `.forge/specs/*.md` or `.forge/kb/*.md` files.

| Linear                                          | Forge                         |
|-------------------------------------------------|-------------------------------|
| Team                                            | Workspace / Product           |
| Initiative (`Now / Next / Later / Vision`)      | Roadmap horizon               |
| Project                                         | Spec                          |
| Issue                                           | Subtask                       |
| Issue in `KB` project with label `kb:*`         | KB document                   |
| Issue in `Inbox` project with label `idea`      | Raw idea / spark              |

A Spec is a Linear project under one of the four initiatives. Subtasks are its issues. KB docs live as issues in a dedicated `KB` project of the same team, labeled by topic (`kb:architecture`, `kb:business`, `kb:persona`, `kb:design`, `kb:api-standards`, ...). Agents fetch KB entries **lazily** via the Linear MCP (`https://mcp.linear.app/sse`) when they need them — nothing is prebaked into `CLAUDE.md`.

## Local state (`~/.forge/`)

Only runtime state lives on disk:

```text
~/.forge/
├── config.json      # linear token, default_team_id, kb_project_id, inbox_project_id,
│                    # initiatives, max_parallel_tasks, port_range
├── ports.json       # issue-id → allocated port
├── sessions.json    # issue-id → tmux target
├── worktrees.json   # issue-id → { path, branch }
└── runs/            # reviewer logs (gitignored)
```

`forge-init` creates this layout and bootstraps the Linear team for a product.

## License

MIT
