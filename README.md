# setup

My agent setup for Claude Code, Codex, Cursor, Grok and opencode. It holds one set of rules, a git guard hook and 15 skills.

## Install

Needs bash, rsync, [jq](https://jqlang.org) and [yq](https://github.com/mikefarah/yq). The git hooks need only bash and awk.

```sh
git clone https://github.com/josechifflet/setup.git
cd setup
./install.sh -n   # list what would change
./install.sh
```

1. Each tool folder is copied into its home. A replaced file stays beside it as `<name>.bak`.
2. Five settings files are merged, not copied, because the apps rewrite them: `claude/settings.json`, `codex/config.toml`, `grok/config.toml`, `cursor/mcp.json` and `cursor/cli-config.json`. Keys here win; keys the app wrote stay.
3. Skills are copied into `~/.agents/skills` and `~/.cursor/skills`, and each is linked into `~/.claude/skills`. A skill folder with the same name is replaced; other skills are left alone.

Copies, not symlinks: every agent writes state into its home, and a symlink would carry it back into the repo. Re-run `install.sh` after you pull. It never deletes, so remove a file the repo dropped by hand: an install from before the subagents were dropped leaves every file in `~/.claude/agents` but `planner.md`, and `~/.codex/agents`, `~/.cursor/agents`, `~/.grok/agents` and `~/.config/opencode/agent` behind.

## Layout

```text
agents/AGENTS.md   → ~/.agents/AGENTS.md   shared rules
agents/my-skills/  → ~/.agents/skills      skills I wrote
agents/skills/     → ~/.agents/skills      vendored skills, pinned in skills-lock.json
claude/            → ~/.claude             CLAUDE.md, settings, planner, hooks, status line
codex/             → ~/.codex              AGENTS.md, config, hook, command rules
cursor/            → ~/.cursor             rule, MCP, permissions
grok/              → ~/.grok               AGENTS.md, config, hook
opencode/          → ~/.config/opencode    AGENTS.md, config
```

## How it works

- **Rules.** Each tool gets the same five preferences and five git rules: make the smallest change, check finished work and run the full gate once before the report, report and stop with no review or polish round you did not ask for, lead with the result, and keep going unless blocked or about to delete data or change something outside the repo. Git reads run freely, and `add`, `commit` and `push` run once you ask. Every other git write goes to you as the exact command, and no agent or subagent leaves the branch or checkout its session started in. Two more rules cover what each tool can start on its own, and each tool works directly with the fewest subagents needed. Claude and Grok start a workflow only when your message contains `ultracode` and stop its retry loops after 3 rounds. Codex creates a goal, a scheduled task or a cloud task only when you ask, and marks a goal blocked after 3 turns on the same blocker. Cursor starts a loop, autopilot, automation or cloud agent only when you ask, and stops a loop after 3 rounds. opencode has no workflow feature, so it only keeps file search out of subagents.
- **Context.** Claude auto-compacts at 400K tokens and Grok at 80% of its 500K window, the same point. Codex's model has a 272K window, so its default stands.
- **Subagents.** Claude defines one, `planner`, which runs only when you name it. It writes a plan file for staged work to `~/.local/state/plans`, outside every repo, with a `Session:` line naming the session that runs it. A `SessionStart` hook prints the session ID and points at the plans that line assigns to the session, so a plan survives compaction and resume, and moves when you hand it to another session. Every other tool uses its built-in subagents, and each works directly when it can.
- **Safety.** Every agent asks before a shell command. A `PreToolUse` hook in Claude, Codex and Grok allows only git reads, `add`, `commit` and a plain `push`, and refuses `wt` and the `gh` commands that change a branch; each refusal tells the agent why and what to do next. A second Claude hook refuses subagents and workflows that ask for a worktree. Claude's deny list repeats the branch-change blocks, because a hook that times out or fails lets the call run. Cursor and opencode deny branch changes and destructive git in config.
- **MCP.** context7 and [Paper](https://paper.design) Desktop. Export `CONTEXT7_API_KEY`. For Codex, add the key by hand as `[mcp_servers.context7.http_headers]` in `~/.codex/config.toml`.

The models, login method and themes are mine. Edit `claude/settings.json`, `codex/config.toml`, `grok/config.toml` and `opencode/opencode.jsonc` before you install.

## Skills

Mine, under the repo's MIT license:

- `behaviour`: writes behaviour trees people align on, then audits, checks and verifies the code against them. Its `verify` mode uses `typesafe-ai`.
- `bet`: plans test coverage as a Branching Expectation Tree.
- `context-doctor`: trims AGENTS.md, CLAUDE.md, rules and skills to what earns its tokens.
- `handoff`: compacts a conversation into a handoff document and a kickoff prompt.
- `paper-use`: builds, mirrors and audits Paper design files.
- `rate`: scores work on every axis until each is 10.
- `ui-principles`: rules for clean, scannable UI layout.

Vendored. Each folder keeps its upstream `LICENSE`:

- `agent-browser` from [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser), Apache-2.0.
- `grilling` from [mattpocock/skills](https://github.com/mattpocock/skills), MIT.
- `ponytail`, `ponytail-audit`, `ponytail-debt`, `ponytail-review` from [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail), MIT.
- `thermo-nuclear-code-quality-review` from [cursor/plugins](https://github.com/cursor/plugins), MIT.
- `typesafe-ai` from [typesafe-ai/skills](https://github.com/typesafe-ai/skills), MIT.

Changes from upstream: a shorter `description` and a `metadata` block in the `SKILL.md` frontmatter, plus an `agents/openai.yaml` with the Codex display name. `typesafe-ai` is unchanged.

## License

[MIT](LICENSE), except the vendored skills, which keep their own licenses.
