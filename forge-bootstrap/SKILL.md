---
name: forge-bootstrap
description: Bootstrap a machine (or a new team) for Forge — given a Linear team, clones every repo listed in the team's `kb:repos` KB issue, runs their setup commands, and writes `~/.forge/config.json` pointing at that team. Use when the user says "setup do zero", "novo pc", "new machine", "bootstrap forge", "clona os repos do time", "forge machine setup", or switches to a different product/team.
argument-hint: [team name or key — e.g. "ENG" or "Acme Web"]
---

# Forge Bootstrap — new machine / new team setup

Pull every repo of a Linear team onto this machine, wire up `~/.forge/config.json` to that team, and optionally run per-repo setup commands.

Source of truth for the repo list is a single KB issue in the team's `KB` Linear project, labeled `kb:repos`. All Linear operations go through the Linear MCP server (`https://mcp.linear.app/sse`).

## Input

`$ARGUMENTS` = team name or team key (e.g. `ENG`, `Acme Web`).

If not provided, list the user's Linear teams and ask which one to bootstrap.

## `kb:repos` issue format

A single KB issue per team, title `Repositories`, label `kb:repos`, description shaped as a markdown table:

```markdown
# Repositories

| Name      | Clone URL                        | Default branch | Setup              |
|-----------|----------------------------------|----------------|--------------------|
| web       | git@github.com:acme/web.git      | main           | pnpm install       |
| backend   | git@github.com:acme/backend.git  | main           | cargo build        |
| mobile    | git@github.com:acme/mobile.git   | develop        | pnpm install       |

<!-- parseable by forge-bootstrap — keep columns stable -->
```

Rules:
- `Name` is the local directory name.
- `Clone URL` is git-clone-able as-is (SSH preferred).
- `Default branch` is the long-lived branch; `forge-run` bases worktrees off it.
- `Setup` is an optional one-liner run in the repo after clone. Leave blank if nothing to run.

## Process

### 1. Sanity check host

Before touching anything:

- Check `git`, `jq`, `tmux`, `gh` are on PATH. Report missing tools and stop.
- Check `~/.ssh` has at least one key if any clone URL is SSH. If not, warn.
- Detect `LINEAR_API_KEY` or existing MCP auth. If neither is present, stop and tell the user to authenticate Linear MCP first.

### 2. Resolve the team

Via Linear MCP, list teams and match `$ARGUMENTS` against team name and key (case-insensitive). If multiple match, ask. If none match, offer to create one (hands off to `forge-init`).

### 3. Fetch the `kb:repos` KB issue

In the team's `KB` project, find the issue with label `kb:repos`. If missing:

- Offer to create a starter one (empty table with a commented example row).
- Stop the bootstrap — the user has to fill it in first, because there is nothing to clone.

### 4. Parse the table

Parse the markdown table from the issue description into a list of records:

```json
[
  {"name": "web", "url": "git@github.com:acme/web.git", "branch": "main", "setup": "pnpm install"},
  ...
]
```

Trim whitespace. Skip rows with empty `name` or `url`. Ignore comment lines.

### 5. Pick the base directory

Default: `~/dev/<team-key-lowercased>/`.

Confirm with the user before creating (one prompt, not per-repo). If they override, remember the choice for this run only — the persistent default stays `~/dev/<team-key>/`.

### 6. Clone each repo

For each record:

```bash
mkdir -p "<base>"
if [ -d "<base>/<name>/.git" ]; then
  echo "[skip] <name> already present"
  git -C "<base>/<name>" fetch --all --prune
  git -C "<base>/<name>" status --short --branch
else
  git clone --branch "<branch>" "<url>" "<base>/<name>"
fi
```

Keep going on individual failures — report them at the end, don't abort the batch.

### 7. Offer to run setup

Collect all non-empty `setup` commands. Show them to the user in a single block:

```
Setup commands to run:
  web      → pnpm install
  backend  → cargo build
  mobile   → pnpm install

Run all? [Y/all/select/n]
```

Options:
- `Y` / `all` → run every setup command sequentially in its repo dir
- `select` → ask per repo
- `n` → skip all

Stream each setup's output. On failure, log the error and continue to the next.

### 8. Write `~/.forge/config.json`

Merge into an existing config non-destructively — preserve `max_parallel_tasks`, `port_range`, and any unknown keys.

Keys populated (or confirmed) from Linear:

- `default_team_id`
- `default_team_key`
- `kb_project_id`
- `inbox_project_id`
- `initiatives` = `{ now, next, later, vision }` — by id

If the team has not been initialized (no `KB` project, no initiatives), delegate to `forge-init` first, then continue.

### 9. Write the repo map

Additionally, persist a machine-local map of where each repo lives, so `forge-run` can create worktrees without re-asking:

`~/.forge/repos/<team-key>.json`

```json
{
  "base": "/home/user/dev/acme",
  "repos": {
    "web":     { "path": "/home/user/dev/acme/web",     "default_branch": "main",    "url": "git@github.com:acme/web.git" },
    "backend": { "path": "/home/user/dev/acme/backend", "default_branch": "main",    "url": "git@github.com:acme/backend.git" },
    "mobile":  { "path": "/home/user/dev/acme/mobile",  "default_branch": "develop", "url": "git@github.com:acme/mobile.git" }
  }
}
```

`forge-run` reads this when a Linear subtask's description has `Repo: <name>` — it picks the matching local path as the parent of the new worktree.

### 10. Output

Report:

- Team name + URL
- Base directory used
- Per-repo status: `cloned`, `already present` (with branch + ahead/behind), `failed`
- Setup results (skipped / ran / failed)
- Path to `~/.forge/config.json` and `~/.forge/repos/<team-key>.json`
- Next step suggestions: `forge-status`, or `forge-run play-task <issue-id>`

## Switching between teams/products

`forge-bootstrap` is idempotent per team. Running it again with a different team switches `default_team_id` in `~/.forge/config.json` (after confirming with the user) and ensures that team's repos are cloned + set up. Previous teams' repo maps stay under `~/.forge/repos/<other-team-key>.json` so you can switch back without re-cloning.

To switch "active" team without re-running the full bootstrap, the user can say: "use team <key>" — this skill's step 8 handles just that.

## Rules

- **Never delete local repos or worktrees.** Bootstrap is additive.
- **Never force-checkout.** If a repo has local changes, leave it alone and report.
- **Non-destructive config merge.** `~/.forge/config.json` keeps user customizations.
- **Idempotent.** Re-runs must be safe and cheap.
- **Ask once, not per-repo**, for the base directory and for the global "run setup?" decision.
- **Report, don't bail.** Per-repo failures are collected and reported at the end.
- **Source of truth = Linear.** If the user asks to "add a repo", route to `forge-intake` which will update the `kb:repos` issue — `forge-bootstrap` does not edit that issue directly.
