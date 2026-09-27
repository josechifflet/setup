# setup

My agent setup for Claude Code, Codex, Cursor, Grok and opencode. It holds one set of rules, six subagents per tool, a git guard hook and 14 skills.

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

Copies, not symlinks: every agent writes state into its home, and a symlink would carry it back into the repo. Re-run `install.sh` after you pull.

## Layout

```text
agents/AGENTS.md   → ~/.agents/AGENTS.md   shared rules
agents/my-skills/  → ~/.agents/skills      skills I wrote
agents/skills/     → ~/.agents/skills      vendored skills, pinned in skills-lock.json
claude/            → ~/.claude             CLAUDE.md, settings, subagents, hook, status line
codex/             → ~/.codex              AGENTS.md, config, subagents, hook, command rules
cursor/            → ~/.cursor             rule, subagents, MCP, permissions
grok/              → ~/.grok               AGENTS.md, config, subagents, hook
opencode/          → ~/.config/opencode    AGENTS.md, config, subagents
```

## How it works

- **Rules.** Each tool gets the same preferences: implement first, check once at the end, short replies, and git reads, adds, commits and pushes only. Every other git write goes to you as the exact command, and no agent or subagent leaves the branch or checkout its session started in.
- **Subagents.** explorer and researcher read, planner writes a plan file, orchestrator runs one wave of workers, worker makes one owned write, reviewer reviews a diff. The main session decides.
- **Safety.** Every agent asks before a shell command. A `PreToolUse` hook in Claude, Codex and Grok allows only git reads, `add`, `commit` and a plain `push`, and refuses `wt` and the `gh` commands that change a branch; each refusal tells the agent why and what to do next. A second Claude hook refuses subagents and workflows that ask for a worktree. Claude's deny list repeats the branch-change blocks, because a hook that times out or fails lets the call run. Cursor and opencode deny branch changes and destructive git in config.
- **MCP.** context7 and [Paper](https://paper.design) Desktop. Export `CONTEXT7_API_KEY`. For Codex, add the key by hand as `[mcp_servers.context7.http_headers]` in `~/.codex/config.toml`.
- **Plans.** Plan files live in `~/.local/state/plans`, outside every repo.

The models, login method and themes are mine. Edit `claude/settings.json`, `codex/config.toml`, `grok/config.toml` and `opencode/opencode.jsonc` before you install.

## Skills

Mine, under the repo's MIT license:

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
