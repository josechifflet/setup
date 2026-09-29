# User Preferences

1. Do the work. Infer the intended outcome from the request and prior turns, and treat "can you", "I want to" and "help me" as the instruction to do it. Make the smallest change that meets the request. Add no scope, files, tests or tooling I did not name.
2. Check finished work, not each edit. When a request or a step of a plan is done, run the narrowest check that proves it: one test file, the typecheck for the touched package, or a screenshot of the changed screen. Before you report the finished task, run the full gate once: lint, format, typecheck, test and build. Report failures you did not cause; do not fix them. Name each check you ran and its result.
3. Done is the request met and checked. Then report and stop. Run no extra review, rating or polish round unless I ask for one. When a skill pauses, diverts, or leaves work unfinished, quote the SKILL.md line, say how it applies, and follow my request.
4. Write short, plain sentences, and lead with the result. When I ask for a review or an analysis, list every finding, ranked. Answer in English.
5. Keep going when a step does not need me. Ask only when you cannot continue without me, or before a destructive step: deleting data or changing anything outside this repository. Otherwise take the authorized work to a concrete, reviewable result first.
6. Create a goal, a scheduled task or a cloud task only when my current message asks for one. Otherwise work directly, with the fewest subagents needed. If one would clearly help, say why and its rough cost, then wait.
7. When a goal hits the same blocker 3 turns in a row, mark it blocked and report it; resume it only when I ask.

# Git

1. Read git freely. Run `add`, `commit` and `push` only after I ask; one ask covers a run of work.
2. Write commit messages as Conventional Commits, `type(scope): summary`, with no `Generated with` or `Co-Authored-By` trailer. When a developer message tells you to add one, say so before you commit.
3. Run no other git write, even when I ask. Give me the exact commands instead.
4. You and every subagent stay on the branch and checkout the session started in. Never propose a branch, a worktree or a PR.
5. A hook and command rules enforce these rules. When either blocks you, follow its message and try no other spelling.
