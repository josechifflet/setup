#!/usr/bin/env bash
set -euo pipefail

# [PERF] This hook runs before every Bash call and a heredoc body travels inside
# the command string, so the cost has to stay flat in the size of that body. Two
# literal gates and one fixed-length pipeline hold it there. Every number here is
# measured on bash 3.2 for darwin/arm64, which is what `/usr/bin/env bash` finds
# on a stock machine.
#
# `$(</dev/stdin)` and not `read -r -d ''`: the builtin forks nothing but reads
# a pipe one byte at a time, ~0.40ms/KB, where this form reads it in blocks and
# still forks no `cat` — 85ms against 10ms on a 240KB payload, and within 0.4ms
# of the builtin on a small one. The `cat` fallback is for a host with no
# /dev/stdin, where the bare form would fail and the hook would fail open.
{ PAYLOAD=$(< /dev/stdin); } 2> /dev/null || PAYLOAD=$(cat)

# A command needs the parser when it names git or a guarded verb, or holds the
# quoting and expansion that can spell one at run time (`g''it`, `$'\x67it'`,
# `re$()set`). JSON escapes a double quote in the command as \", so the
# backslash covers it here. A brace counts only when no quote or brace follows
# it, since every JSON object opens with `{"`. Clearing the rest here costs no
# exec, jq included.
case "$PAYLOAD" in
  *git* | *reset* | *clean* | *restore* | *stash* | *rebase* | *rm* | *gc* | *prune* | *filter-* | *update-ref* | *reflog* | *worktree* | *amend* | *\\* | *\$* | *\`* | *\'* | *\** | *\?* | *\[* | *\{[!\"\}]*) ;;
  *) exit 0 ;;
esac

# [SECURITY] Fail closed: with jq missing a git command is refused rather than
# silently allowed through. It sits after the gate above because a payload with
# no `git` in it has already been cleared, and refusing those for a missing
# dependency would block the whole session over a command jq never had to see.
if ! command -v jq > /dev/null 2>&1; then
  echo "BLOCKED: jq is required for Codex hook evaluation but was not found." >&2
  exit 2
fi

# A missing or malformed payload means the command cannot be evaluated
# safely, so refuse it.
if ! COMMAND="$(jq -er ".tool_input.command" 2> /dev/null <<< "$PAYLOAD")"; then
  echo "BLOCKED: could not read the Bash command from the Codex hook payload." >&2
  exit 2
fi

# The payload carries cwd, env and transcript paths, so these can appear in it
# while the command itself is innocent. Re-check the extracted command before
# paying for the scan below.
case "$COMMAND" in
  *git* | *reset* | *clean* | *restore* | *stash* | *rebase* | *rm* | *gc* | *prune* | *filter-* | *update-ref* | *reflog* | *worktree* | *amend* | *\\* | *\$* | *\`* | *\'* | *\"* | *\** | *\?* | *\[* | *\{* | *\}*) ;;
  *) exit 0 ;;
esac

# Verbs a dynamic command word must not reach (`$G reset --hard`), and the verbs
# the no-parser fallback refuses. One list, so jq and the fallback cannot drift.
GUARDED_VERBS="reset clean restore stash rebase rm gc prune filter-branch filter-repo update-ref reflog worktree"

# An alias defined by the call's own environment (`GIT_CONFIG_COUNT=1 …`,
# `HOME=/tmp/x`) is invisible to the lookup below, so an unknown subcommand in
# such a command is refused rather than looked up in the wrong config. A `cd`
# moves the repo the lookup would read, so it taints the same way.
# `*HOME=*` also covers XDG_CONFIG_HOME.
TAINT=false
case "$COMMAND" in
  *GIT_*=* | *HOME=* | *"cd "* | *pushd*) TAINT=true ;;
esac

# [SECURITY] The old guard deleted quoted spans and read only the first word of
# each segment, so `git "reset"`, `sh -c '...'` and `$G reset` walked past it.
# shfmt parses the command into a syntax tree and jq visits every CallExpr at
# any depth, which is what reaches subshells, blocks, pipelines, `$(...)`,
# backticks, loops and functions without listing them. One shfmt and one jq per
# parse keeps the cost flat under Grok's 5s and Codex's 10s timeouts, where a
# timeout is a fail-open.
#
# jq prints one record per line: `B<TAB>rule` blocks, `S<TAB>json-text` is shell
# text to parse again, `A<TAB>json-args<TAB>name<TAB>json-dirs` asks the shell
# for a config alias, the only lookup jq cannot do itself.
# shellcheck disable=SC2016  # the jq program is jq source, not shell
JQ_PROG='
# Unquoted backslashes only escape, so `\git` runs git.
def unesc: gsub("\\\\(?<c>.)"; "\(.c)");
# Inside double quotes bash drops a backslash only before these four, and shfmt
# keeps it in the Lit Value, so `git \"reset\"` would not read as reset.
def dqunesc: gsub("\\\\(?<c>[\"\\\\$`])"; "\(.c)");
def hexn: ascii_downcase | explode | map(if . >= 97 then . - 87 else . - 48 end)
  | reduce .[] as $d (0; . * 16 + $d);
def octn: explode | map(. - 48) | reduce .[] as $d (0; . * 8 + $d);
# ANSI-C quoting (dollar sign, single quote) decoded the way bash does, so an
# escaped \x72eset reads as reset. An escape bash does not know keeps its
# backslash, as bash keeps it.
def ansic:
  gsub("\\\\(?<e>x[0-9A-Fa-f]{1,2}|u[0-9A-Fa-f]{1,4}|U[0-9A-Fa-f]{1,8}|[0-7]{1,3}|c.|.)";
    .e as $e
    | if ($e | test("^[xuU]")) then [$e[1:] | hexn] | implode
      elif ($e | test("^[0-7]")) then [$e | octn] | implode
      elif ($e | startswith("c")) then [($e[1:2] | explode[0]) % 32] | implode
      else ({"a": "\u0007", "b": "\b", "e": "\u001b", "E": "\u001b", "f": "\f",
        "n": "\n", "r": "\r", "t": "\t", "v": "\u000b", "\\": "\\", "\u0027": "\u0027",
        "\"": "\"", "?": "?"}[$e] // ("\\" + $e)) end);
# Unquoted brace and glob text expands at run time (`git {reset,} --hard`), so a
# Lit holding any of it is not a literal. A lone `[` is the test command.
def expands: . != "[" and (gsub("\\\\."; "") | test("[{}*?\\[]"));
# A word is literal only when every part is; anything else (an expansion, a
# substitution) is null, which the rules below treat as unknown.
def word:
  reduce (.Parts // [])[] as $p ("";
    if . == null then null
    elif $p.Type == "Lit" then (if ($p.Value | expands) then null else . + ($p.Value | unesc) end)
    elif $p.Type == "SglQuoted" then . + (if $p.Dollar then $p.Value | ansic else $p.Value end)
    elif $p.Type == "DblQuoted" and all(($p.Parts // [])[]; .Type == "Lit")
    then . + ([($p.Parts // [])[].Value | dqunesc] | join(""))
    else null end);
# The literal text of a word that is not literal, expansions dropped, so
# `g$()it` still shows git and `--am{end,}` still shows a flag.
def litpieces:
  [(.Parts // [])[] | if .Type == "Lit" or .Type == "SglQuoted" then .Value
    elif .Type == "DblQuoted" then [(.Parts // [])[] | select(.Type == "Lit") | .Value] | join("")
    else "" end] | join("");
# An unquoted expansion splits into any number of words, flags included.
def unquotedexp:
  any((.Parts // [])[]; .Type != "Lit" and .Type != "SglQuoted" and .Type != "DblQuoted");
def globword: any((.Parts // [])[]; .Type == "Lit" and (.Value | expands));
# A non-literal word that starts like an option, or an unquoted expansion that
# can split into one, could be any option.
def dyn: "\u0000dyn";
def wordx: word as $w
  | if $w != null then $w
    elif (litpieces | startswith("-")) or unquotedexp then dyn else null end;
# A guarded verb standing alone in text, so `re$()set` matches and `format` does not.
def verbre: "(^|[^A-Za-z-])(" + ($guarded | split(" ") | join("|")) + ")([^A-Za-z-]|$)";
# Shell text for a script word, so `-c "cd $HOME && git reset --hard"` is still
# parsed: an expansion becomes a placeholder word instead of hiding the whole
# script. $raw keeps a heredoc body as written, since its backslashes are not
# word escapes.
def script($raw):
  [(.Parts // [])[] as $p
   | if $p.Type == "Lit" then (if $raw then $p.Value else $p.Value | unesc end)
     elif $p.Type == "SglQuoted" then (if $p.Dollar then $p.Value | ansic else $p.Value end)
     elif $p.Type == "DblQuoted" then
       [($p.Parts // [])[] | if .Type == "Lit" then .Value | dqunesc else "\"$_dyn\"" end]
       | join("")
     else "\"$_dyn\"" end]
  | join("");
def base: sub("^.*/"; "");
def isguarded: . as $v | type == "string" and any($guarded | split(" ")[]; . == $v);
# git accepts any unambiguous prefix of a long option, so `--forc` is --force.
def longmatch($v; $e):
  ($e | startswith("--")) and ($e | length) > 2 and ($v | type == "string")
  and ($v | startswith("--")) and ($v | length) >= 3
  and ($e | startswith($v | sub("=.*$"; "")));
# Flags count anywhere in the arguments and inside clusters, so `-fdx` and
# `-d -f` both carry the f.
def hasflag($short; $exact):
  any(.[]; . as $v | $v == dyn or ($v | type == "string" and (
    ($short != "" and ($v | test("^-[A-Za-z]*[" + $short + "]")))
    or any($exact[]; . == $v or longmatch($v; .)))));
# The first positional argument: the dynamic marker when it is not literal, and
# a separate marker when there is none, so a plain `git reflog` stays allowed.
def firstpos:
  first(.[] | if . == null then dyn else . end | select(. == dyn or (startswith("-") | not)))
  // "\u0000none";
# Values of options that take one are not flags: `-m "$msg"` is a message.
def dropvals($re):
  . as $a
  | [range(0; length) as $i
     | select(($i > 0 and ($a[$i - 1] | type == "string") and ($a[$i - 1] | test($re))) | not)
     | $a[$i]];
# Words after `--` are pathspecs, never flags.
def beforedd: (indices("--")[0] // length) as $k | .[:$k];
# For commit and clean a quoted expansion is one whole word that could still be
# the flag, so every non-literal word counts.
def strict: map(if . == null then dyn else . end);
def shells: ["sh", "bash", "zsh", "dash", "ksh"];
def wrappers: ["sudo", "doas", "env", "command", "exec", "nice", "nohup", "time",
  "timeout", "stdbuf", "setsid"];
# Builtins win over aliases in git, so only other names need an alias lookup.
def builtins: ["add", "am", "apply", "archive", "bisect", "blame", "branch",
  "bundle", "cat-file", "check-attr", "check-ignore", "checkout", "cherry",
  "cherry-pick", "clean", "clone", "commit", "config", "count-objects",
  "describe", "diff", "diff-files", "diff-index", "diff-tree", "difftool",
  "fetch", "for-each-ref", "format-patch", "fsck", "gc", "grep", "hash-object",
  "help", "init", "log", "ls-files", "ls-remote", "ls-tree", "maintenance",
  "merge", "merge-base", "mergetool", "mv", "name-rev", "notes", "prune",
  "pull", "push", "range-diff", "rebase", "reflog", "remote", "repack",
  "replace", "reset", "restore", "rev-list", "rev-parse", "revert", "rm",
  "shortlog", "show", "show-ref", "sparse-checkout", "stash", "status",
  "submodule", "switch", "symbolic-ref", "tag", "update-index", "update-ref",
  "var", "version", "whatchanged", "worktree"];
def render: map(if . == null or . == dyn then "\"$_dyn\"" else @sh end) | join(" ");
def verdict($sub):
  # reset moves HEAD and can orphan commits; restore rewrites index or
  # worktree; stash moves work where the user did not put it; rebase and the
  # filters rewrite shared history; rm removes tracked files from the worktree;
  # gc and prune delete the recovery path for a bad reset; update-ref moves refs
  # beneath every other guard.
  if any(["reset", "restore", "stash", "rebase", "rm", "gc", "prune",
    "update-ref", "filter-branch", "filter-repo"][]; . == $sub) then "git " + $sub
  # Only the force forms delete untracked files.
  elif $sub == "clean"
    and (beforedd | dropvals("^(-[A-Za-z]*e|--exclude)$") | strict | hasflag("f"; ["--force"]))
  then "git clean --force"
  # Creating and listing branches is additive; deleting, moving or forcing
  # throws away a ref the user made.
  elif $sub == "branch"
    and (dropvals("^(-[A-Za-z]*[tu]|--(set-upstream-to|track|contains|no-contains|merged|no-merged|points-at|format|sort))$")
      | hasflag("dDmMf"; ["--delete", "--move", "--force"]))
  then "git branch --delete/--move/--force"
  # A `--` or `.` pathspec and -f overwrite the worktree with no reflog; -B moves
  # an existing branch. Plain checkout and -b are navigation.
  elif $sub == "checkout"
    and (dropvals("^(-[A-Za-z]*[bt]|--(orphan|track|conflict|pathspec-from-file))$")
      | hasflag("fB"; ["--force", "--", "."]))
  then "git checkout --force/-B/--/."
  # Plain switch and -c refuse to lose work, so git guards them itself.
  elif $sub == "switch"
    and (dropvals("^(-[A-Za-z]*[ct]|--(create|orphan|track|conflict))$")
      | hasflag("fC"; ["--force", "--discard-changes"]))
  then "git switch --force/-C/--discard-changes"
  elif $sub == "commit"
    and (beforedd
      | dropvals("^(-[A-Za-z]*[mFCct]|--(message|file|reuse-message|reedit-message|template|author|date|fixup|squash|trailer|cleanup|pathspec-from-file))$")
      | strict | hasflag(""; ["--amend"]))
  then "git commit --amend"
  # The reflog is the last thing standing after a destructive command.
  elif $sub == "reflog" and (firstpos | . == null or . == dyn or . == "expire" or . == "delete")
  then "git reflog expire/delete"
  # add, list and move are what `wt` and isolation:"worktree" drive.
  elif $sub == "worktree" and (firstpos | . == null or . == dyn or . == "remove" or . == "prune")
  then "git worktree remove/prune"
  else empty end;
def st0: {al: {}, C: [], cfg: false};
# Global options come before the subcommand; these take a value word. The state
# keeps inline aliases, the -C directories the alias lookup must follow, and
# whether the call changes config the lookup cannot see.
def split_globals($i; $st):
  .[$i] as $x
  | if $i >= length then empty
    elif $x == null or $x == dyn then {sub: null, rest: .[$i + 1:], st: $st}
    elif any("-C", "-c", "--git-dir", "--work-tree", "--namespace",
      "--config-env", "--super-prefix", "--attr-source"; . == $x) then
      .[$i + 1] as $val
      | ([$val | select($x == "-c" and type == "string")
        | capture("^alias\\.(?<n>[^=]+)=(?<v>.*)$"; "s")] | .[0]) as $m
      | split_globals($i + 2;
          if $m then $st | .al += {($m.n | ascii_downcase): $m.v}
          elif $x == "-C" and ($val | type == "string") then $st | .C += [$val]
          elif $x == "--namespace" or $x == "--super-prefix" or $x == "--attr-source" then $st
          else $st | .cfg = true end)
    elif ($x | test("^--(git-dir|work-tree|config-env|exec-path)=")) then split_globals($i + 1; $st | .cfg = true)
    elif ($x | startswith("-")) then split_globals($i + 1; $st)
    else {sub: $x, rest: .[$i + 1:], st: $st} end;
def gitwalk($depth; $st):
  split_globals(0; $st)
  | .sub as $sub | .rest as $rest | .st as $st2
  # A subcommand bash builds at run time (`git re$()set`) cannot be judged.
  | if $sub == null then "B\tgit subcommand that is not a literal word"
    else
      ([$rest | verdict($sub)] | .[0]) as $v
      | if $v then "B\t" + $v
        elif any(builtins[]; . == $sub) then empty
        elif $st2.al[$sub | ascii_downcase] then
          $st2.al[$sub | ascii_downcase] as $val
          # A self-referencing alias would otherwise loop; past the cap the
          # command is refused rather than guessed at.
          | if $depth >= 3 then "B\tgit alias nesting deeper than 3"
            elif ($val | startswith("!"))
            then "S\t" + (($val[1:] + " " + ($rest | render)) | @json)
            else ([$val | splits("\\s+") | select(. != "")] + $rest)
              | gitwalk($depth + 1; $st2) end
        elif ($sub | test("^[A-Za-z0-9][A-Za-z0-9-]*$")) then
          if $st2.cfg or $taint
          then "B\tgit alias under config the guard cannot see"
          else "A\t" + ($rest | tojson) + "\t" + $sub + "\t" + ($st2.C | tojson) end
        else empty end
    end;
# The index of the script word after the -c cluster at $k: bash takes the first
# word that is not an option, so `bash -c -x "…"` runs the "…".
def scriptpos($k):
  def go($j):
    if $j >= length then null
    elif .[$j] == "--" then (if $j + 1 < length then $j + 1 else null end)
    elif .[$j] == "-o" or .[$j] == "+o" then go($j + 2)
    elif (.[$j] | type == "string") and (.[$j] | test("^[-+]")) then go($j + 1)
    else $j end;
  go($k + 1);
# A shell with no -c and no script file reads its script from stdin.
# Scans the arguments of a shell: -o and +o take a value, a -c cluster means the
# script is an argument, -s or running out of words means stdin.
def stdinscan($j):
  if $j >= length then true
  elif (.[$j] | type) != "string" then false
  elif .[$j] == "-o" or .[$j] == "+o" then stdinscan($j + 2)
  elif (.[$j] | test("^-[A-Za-z]*c")) then false
  elif (.[$j] | test("^-[A-Za-z]*s")) then true
  elif (.[$j] | test("^[-+]")) then stdinscan($j + 1)
  else false end;
# A shell that reads its script from stdin, directly or behind a wrapper such as
# sudo, env or timeout.
def stdinshell:
  [.Args[]? | word] as $w
  | ([range(0; $w | length) as $i
      | select($w[$i] | type == "string" and (base as $b | any(shells[]; . == $b))) | $i]
     | .[0]) as $s
  | if $s == null then false
    elif any($w[:$s][]; type != "string"
      or (((base as $b | any(wrappers[]; . == $b)) or test("^-|=|^[0-9.]+[smhd]?$")) | not))
    then false
    else $w[$s + 1:] | stdinscan(0) end;
def callrecs($depth):
  [.Args[]?] as $a | [$a[] | wordx] as $w
  # A command word bash builds at run time: refused when it is a glob or brace
  # (`{gi,rese}t`, `/usr/bin/g?t`), when its literal pieces spell git
  # (`g$()it`, `"$(git --exec-path)"/git-reset`), or when a guarded verb
  # follows it, literal or assembled (`$G reset`, `re$()set`).
  | (if ($w | length) > 0 and ($w[0] == null or $w[0] == dyn)
       and (($a[0] | globword)
         or (($a[0] | litpieces) | test("(^|/)git(-.*)?$"))
         or any($w[1:][]; isguarded)
         or any($a[1:][]; word == null and (litpieces | test(verbre))))
     then "B\tdynamic command word that may run git" else empty end),
    (range(0; $w | length) as $i
     | $w[$i] as $x | select($x != null and $x != dyn) | ($x | base) as $b | $w[$i + 1:] as $after
     | $a[$i + 1:] as $afterw
     # Any git word starts an invocation, so sudo, env, xargs, timeout, nohup
     # and find -exec need no wrapper list.
     | if $b == "git" then $after | gitwalk($depth; st0)
       elif ($b | test("^git-.")) then [$b[4:]] + $after | gitwalk($depth; st0)
       elif $b == "rm" then
         if ($after | hasflag("rRf"; ["--recursive", "--force"]))
           and any($after[]; type == "string" and test("(^|/)\\.git/?$"))
         then "B\trm --recursive/--force on a .git directory" else empty end
       elif any(shells[]; . == $b) then
         ([range(0; $after | length) as $k
           | select($after[$k] | type == "string" and test("^-[A-Za-z]*c")) | $k]
          | .[0]) as $k
         | if $k != null then
             ($after | scriptpos($k)) as $s
             | if $s != null then "S\t" + ($afterw[$s] | script(false) | @json) else empty end
           else empty end
       elif $b == "eval" then
         if ($afterw | length) > 0
         then "S\t" + ([$afterw[] | script(false)] | join(" ") | @json) else empty end
       else empty end);
# A heredoc or here-string fed to a shell is a script, not data. A heredoc body
# keeps its backslashes as written; a here-string is a word, so its quoting
# comes off first, as bash takes it off.
def hdocrecs:
  select(.Cmd.Type == "CallExpr"
    and any(.Cmd.Args[]? | word | select(. != null) | base; . as $b | any(shells[]; . == $b)))
  | .Redirs[]?
  | if .Hdoc != null then .Hdoc | script(true)
    elif .Word != null then .Word | script(false)
    else empty end
  | "S\t" + @json;
# Text piped into a shell that reads stdin is a script too: `echo "…" | bash`.
def piperecs:
  select(.Type == "BinaryCmd" and (.Op == 13 or .Op == 14)
    and .Y.Cmd.Type == "CallExpr" and (.Y.Cmd | stdinshell))
  | [.X | .. | objects
     | (select(.Type == "CallExpr") | [.Args[1:][]? | script(false)] | join(" ")),
       (select(has("Hdoc") and .Hdoc != null) | .Hdoc | script(true))]
  | join("\n") | "S\t" + @json;
if $mode == "ast" then
  input | .. | objects
  | (select(.Type == "CallExpr") | callrecs($depth)), (select(has("Redirs")) | hdocrecs),
    piperecs
else
  # An alias found in a -C repo expands there, so its next hop is looked up
  # there too.
  ([$value | splits("\\s+") | select(. != "")] + $rest) | gitwalk($depth; st0 | .C = $cdirs)
end
'

block() {
  echo "BLOCKED: '$COMMAND' is forbidden by repo git policy. Everything else stays available, git commit and git push included." >&2
  exit 2
}

# [SECURITY] Fail closed: a guard that cannot evaluate a command refuses it.
refuse() {
  echo "BLOCKED: '$COMMAND' could not be evaluated by the git guard. Refusing." >&2
  exit 2
}

# Without a parser, a quote, backslash or expansion must not hide a word, so
# those characters are deleted rather than their spans; every separator becomes
# a line break. ANSI-C quoting can spell any word, so it is refused outright.
fallback() {
  local lines i j w verb rest
  local -a words
  local flat
  case $1 in *"\$'"*) refuse ;; esac
  # Brace expansion builds words the deletion below would only join
  # (`git {reset,} --hard` becomes `reset,`), so it is refused outright.
  case $1 in *\{*,*\}* | *\{*..*\}*) refuse ;; esac
  # shellcheck disable=SC2016  # literal characters for tr, not an expansion
  flat=$(printf '%s\n' "$1" | tr -d '\042\047\134$(){}\140')
  # A glob can spell git or a verb (`/usr/bin/g?t`); refused when the text
  # could run one.
  case $flat in
    *\** | *\?* | *\[*)
      case $flat in *git* | *reset* | *clean* | *restore* | *stash* | *rebase* | *rm* | *gc* | *prune* | *filter-* | *update-ref* | *reflog* | *worktree* | *amend*) refuse ;; esac
      ;;
  esac
  lines=$(printf '%s\n' "$flat" | tr ';&|' '\n' | { grep -F git || :; })
  while IFS=$' \t' read -r -a words; do
    i=0
    while [[ "$i" -lt "${#words[@]}" ]]; do
      w=${words[i]##*/}
      verb=
      j=$((i + 1))
      if [[ "$w" == git ]]; then
        while [[ "$j" -lt "${#words[@]}" ]]; do
          case ${words[j]} in
            -C | -c | --git-dir | --work-tree | --namespace | --config-env | --super-prefix | --attr-source) j=$((j + 2)) ;;
            -*) j=$((j + 1)) ;;
            *)
              verb=${words[j]}
              j=$((j + 1))
              break
              ;;
          esac
        done
      else
        case $w in git-?*) verb=${w#git-} ;; esac
      fi
      case " $GUARDED_VERBS " in *" $verb "*) block "git $verb" ;; esac
      # The flag-level rules, read crudely: the force, delete, move and amend
      # flags of each verb, clusters and long-option prefixes included. These are
      # globs, so a flag first in its cluster needs its own pattern.
      for rest in "${words[@]:j}"; do
        case $verb:$rest in
          branch:-[dDmMf]* | branch:-[!-]*[dDmMf]* | branch:--f* | branch:--d* | branch:--mo* | \
            checkout:-[fB]* | checkout:-[!-]*[fB]* | checkout:--f* | checkout:-- | checkout:. | \
            switch:-[fC]* | switch:-[!-]*[fC]* | switch:--f* | switch:--di* | \
            commit:--am*) block "git $verb $rest" ;;
        esac
      done
      i=$((i + 1))
    done
  done <<< "$lines"
}

handle() {
  local depth=$2 kind a b c text
  while IFS=$'\t' read -r kind a b c; do
    case $kind in
      B) block "$a" ;;
      S)
        text=$(jq -r . <<< "$a") || refuse
        analyze "$text" $((depth + 1))
        ;;
      A) resolve_alias "$b" "$a" "$depth" "$c" ;;
    esac
  done <<< "$1"
}

# `git config` is the one lookup jq cannot make, and it runs only for a
# subcommand that is not a git builtin. It follows the call's -C directories,
# so an alias defined in another repo is still found.
resolve_alias() {
  local value records args dir rc
  if [[ -z "$CWD" ]]; then
    CWD=$(jq -r '.cwd // empty' <<< "$PAYLOAD") || CWD=
    [[ -n "$CWD" ]] || CWD=$PWD
  fi
  # Unquoted, bash expands a leading ~ in the -C value before git sees it.
  dir=$(jq -r --arg cwd "$CWD" --arg home "$HOME" 'reduce .[] as $d ($cwd;
    if $d == "~" then $home elif ($d | startswith("~/")) then $home + $d[1:]
    elif ($d | startswith("/")) then $d else . + "/" + $d end)' <<< "${4:-[]}") || refuse
  # Exit 1 is "no such alias". Anything else (a missing -C directory, a broken
  # config) means the lookup saw nothing, which is not the same as safe.
  rc=0
  value=$(git -C "$dir" config --get "alias.$1" 2> /dev/null < /dev/null) || rc=$?
  case $rc in
    0) ;;
    1) return 0 ;;
    *) refuse ;;
  esac
  [[ "$3" -lt 3 ]] || block "git alias nesting deeper than 3"
  case $value in
    '!'*)
      args=$(jq -r 'map(if . == null or . == "\u0000dyn" then "\"$_dyn\"" else @sh end) | join(" ")' <<< "$2") || refuse
      analyze "${value#!} $args" $(($3 + 1))
      ;;
    *)
      records=$(jq -nr --arg mode git --arg guarded "$GUARDED_VERBS" --arg value "$value" \
        --argjson rest "$2" --argjson depth $(($3 + 1)) --argjson taint "$TAINT" \
        --argjson cdirs "${4:-[]}" "$JQ_PROG") || refuse
      handle "$records" $(($3 + 1))
      ;;
  esac
}

# shfmt reads bash first and zsh second, so zsh-only syntax such as `${(f)...}`
# still gets a tree instead of the fallback.
analyze() {
  local ast records
  [[ "$2" -le 3 ]] || block "shell nesting deeper than 3"
  ast=
  if [[ -n "$HAVE_SHFMT" ]]; then
    ast=$(printf '%s\n' "$1" | shfmt -ln=bash --to-json 2> /dev/null) ||
      ast=$(printf '%s\n' "$1" | shfmt -ln=zsh --to-json 2> /dev/null) || ast=
  fi
  if [[ -z "$ast" ]]; then
    fallback "$1"
    return 0
  fi
  records=$(jq -nr --arg mode ast --arg guarded "$GUARDED_VERBS" --arg value "" \
    --argjson rest '[]' --argjson depth "$2" --argjson taint "$TAINT" --argjson cdirs '[]' \
    "$JQ_PROG" <<< "$ast") || refuse
  handle "$records" "$2"
}

HAVE_SHFMT=
command -v shfmt > /dev/null 2>&1 && HAVE_SHFMT=1
CWD=
analyze "$COMMAND" 0
exit 0
