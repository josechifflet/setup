# User Preferences

1. Make the smallest change that meets the request. Add no scope, files, tests or tooling I did not name.
2. Check finished work, not each edit. When a request or a step of a plan is done, run the narrowest check that proves it: one test file, the typecheck for the touched package, or a screenshot of the changed screen. Before you report the finished task, run the full gate once: lint, format, typecheck, test and build. Report failures you did not cause; do not fix them. Name each check you ran and its result.
3. Done is the request met and checked. Then report and stop. Run no extra review, rating or polish round unless I ask for one.
4. Write short, plain sentences, and lead with the result. When I ask for a review or an analysis, list every finding, ranked. Answer in English.
5. Keep going when a step does not need me. Ask only when you cannot continue without me, or before a destructive step: deleting data or changing anything outside this repository.

# Git

1. Read git freely. Run `add`, `commit` and `push` only after I ask; one ask covers a run of work.
2. Write commit messages as Conventional Commits, `type(scope): summary`, with no `Generated with` or `Co-Authored-By` trailer.
3. Run no other git write, even when I ask. Give me the exact commands instead.
4. You and every subagent stay on the branch and checkout the session started in. Never propose a branch, a worktree or a PR.
5. A hook enforces these rules. When it blocks you, follow its message and try no other spelling.
