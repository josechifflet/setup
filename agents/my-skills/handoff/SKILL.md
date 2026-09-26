---
name: handoff
description: "Compacts this conversation into a handoff document and a kickoff prompt."
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
metadata:
  short-description: "Handoff document and kickoff prompt"
---

Produce two artifacts in order.

## 1. Handoff document

Write it so a fresh agent can continue the work. Save to the OS temporary directory — never the current workspace.

- State where the work stands: what is done, what remains, the commands that prove it (tests, build, lint).
- Reference existing artifacts (PRDs, plans, ADRs, issues, commits, diffs) by path or URL —
  never duplicate their content.
- Surface failed approaches ("tried X, broke because Y") and decisions-with-rationale,
  so the next session does not repeat eliminated paths.
- Include a "Suggested skills" section listing skills the next agent should invoke.
- Handoff contains tasks (delegation plans, remaining work items) → size each by complexity: S, M, L, or XL.
  Never recommend task models.
- Redact sensitive information (API keys, passwords, PII).
- Arguments passed → treat them as the next session's focus; tailor the doc to it.

## 2. Kickoff prompt

Print a single fenced code block, ready to copy-paste into the next session. Keep it tight: every line
must earn its place, and drop anything the handoff doc already carries.

- Open with the action: `Read <handoff path>, then ...`.
- State the objective and its definition of done (e.g. tests pass, build green).
- Scope constraints — what to leave alone, what needs confirmation — only where they bind.
- Name the suggested skills from the handoff doc so the next agent invokes them.
