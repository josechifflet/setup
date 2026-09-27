#!/usr/bin/env bash
set -euo pipefail

# Every agent and subagent stays on the branch and checkout its session started
# in; only the user creates worktrees or changes branches. block-dangerous-git.sh
# covers the shell. This covers the Claude tools that open a worktree: an Agent
# call with isolation "worktree", and a Workflow whose script asks for one.
# EnterWorktree needs no hook: its bare-name deny in settings.json removes the
# tool, so Claude never calls it. The Agent(isolation:worktree) deny rule backs
# this hook up, but its denial carries no reason. Exit 2 here stops the call
# before permission rules run, so the agent reads why instead.

{ PAYLOAD=$(< /dev/stdin); } 2> /dev/null || PAYLOAD=$(cat)

# Almost no call names a worktree, and those clear with no exec.
case $PAYLOAD in
  *worktree*) ;;
  *) exit 0 ;;
esac

deny() {
  echo "BLOCKED: $1" >&2
  exit 2
}

block() {
  deny "$1 would run in a new git worktree on another branch. Rules set by the user keep every agent and subagent on the branch and checkout the session started in, plans included. Only the user creates worktrees or changes branches. The next step is to run it again without worktree isolation, in this checkout. If the task cannot be done here, the next step is to hand the user the exact command. The same rules forbid reaching it through EnterWorktree, wt, git, a script or a saved workflow."
}

# Fail closed: a call that mentions a worktree and cannot be read is refused.
UNREADABLE="the worktree guard cannot read this call, which mentions a worktree. The next step is to run it again without worktree isolation, or to ask the user to check that jq is installed."
command -v jq > /dev/null 2>&1 || deny "$UNREADABLE"
TOOL=$(jq -r '.tool_name // empty' <<< "$PAYLOAD" 2> /dev/null) || deny "$UNREADABLE"

case $TOOL in
  Agent | Task)
    ISOLATION=$(jq -r '.tool_input.isolation // empty' <<< "$PAYLOAD" 2> /dev/null) || deny "$UNREADABLE"
    if [[ $ISOLATION == worktree ]]; then block "This subagent"; fi
    ;;
  Workflow)
    SCRIPT=$(jq -r '.tool_input.script // empty' <<< "$PAYLOAD" 2> /dev/null) || deny "$UNREADABLE"
    SCRIPT_PATH=$(jq -r '.tool_input.scriptPath // empty' <<< "$PAYLOAD" 2> /dev/null) || deny "$UNREADABLE"
    # scriptPath wins over script when both are set, so the file is read too.
    # A workflow started by name is left to the rule.
    if [[ -n $SCRIPT_PATH && -f $SCRIPT_PATH ]]; then SCRIPT+=$'\n'$(< "$SCRIPT_PATH"); fi
    RE="isolation[\"']?[[:space:]]*:[[:space:]]*[\"'\`]worktree"
    if [[ $SCRIPT =~ $RE ]]; then block "An agent in this workflow"; fi
    ;;
esac
exit 0
