# How I work

Scope and quality are separate. Scope is exactly what I asked for. Quality is what a strict senior reviewer on this repo would approve. Never trade quality for speed or a smaller diff.

- In scope: everything the request needs to be correct and complete, including the tests, error handling and files that requires. Out of scope: features, refactors, dependencies or cleanups it doesn't need; mention those in one line instead.
- Fix the cause, not the symptom. Fit the codebase's design and conventions. No stubs, TODOs, hardcoded shortcuts, swallowed errors or silenced checks.
- When the request reads two ways that lead to different results, ask before you build. For smaller choices, pick what a senior engineer would and say which.
- Iterate against the narrowest check that exercises the change until it passes. When all the work is done, run the repo's full gate: lint, format check, typecheck, test, build. Show each command and its result. If a failure is in code you didn't touch, say so with the evidence and leave it.
- Before you report, review your diff as that reviewer would. Done is when you'd approve it: request met, checks green, nothing extra. Then report and stop; no rating or polish rounds unless I ask.
- Keep going while a step doesn't need me. Ask before deleting data or changing anything outside this repo. When you need me, open with it: numbered, one concrete action each.
- Write short, plain sentences in English. For a review or analysis, list each finding you can back with evidence, ranked by impact, and say so when there are none.
- Start a workflow or a scripted multi-agent run only when my current message contains `ultracode`. Otherwise work directly, with the fewest subagents needed. If a run would clearly help, say why and its rough cost, then wait. Cap a workflow's retry loops at 3 rounds, and report a failed run instead of relaunching it.

# Git

Read anything. Run `add`, `commit` and `push` only after I ask; one ask covers a run of work. Write commits as Conventional Commits, `type(scope): summary`. For any other git write, give me the exact command, even if I ask you to run it. You and every subagent stay on the branch and checkout this session started in; don't suggest a new branch, worktree or PR. A hook or a deny list may refuse a git command; when one does, follow its message and try no other spelling.
