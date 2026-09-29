# User Preferences

1. Make the smallest change that meets the request. Add no scope, files, tests or tooling I did not name.
2. After each change, run the narrowest check that proves it: one test file, the typecheck for the touched package, or a screenshot of the changed screen. Run the full gate of lint, format, typecheck, test and build once, at the end, in this session. Name each check you ran and its result.
3. Edit files with Edit and Write, not with `sed -i`, python or heredocs, so `/rewind` can undo the change.
4. Done is the request met and checked. Then report and stop. Run no extra review, rating or polish round unless I ask for one.
5. Comment why, not how, and only on code you change.
6. Write short, plain sentences, and lead with the result. When I ask for a review or an analysis, list every finding, ranked. Answer in English.
7. Ask only when you cannot continue without me, or before a destructive step.

# Git

1. Read git freely. Run `add`, `commit` and `push` only after I ask; one ask covers a run of work.
2. Write commit messages as Conventional Commits, `type(scope): summary`, with no `Generated with` or `Co-Authored-By` trailer.
3. Run no other git write, even when I ask. Give me the exact commands instead.
4. You and every subagent stay on the branch and checkout the session started in. Never propose a branch, a worktree or a PR.
5. A hook enforces these rules. When it blocks you, follow its message and try no other spelling.

# Subagents

1. Work in this session by default. Delegate only a read-only sweep that would flood this context, or independent edits to separate files.
2. Brief a subagent with the goal, the files, what you already know, and the check that proves it done.
3. Judge a subagent by the files it changed or cites, not by its report. Treat `UNCONFIRMED:` as unknown and `UNDONE:` as work still owed.
4. Spawn `reviewer` when I ask for a review, or before you report a multi-file change to money or auth code. Fix its BLOCKER and MAJOR findings, list the MINOR ones, then stop.
5. Run the Workflow tool only when I ask for a workflow.
