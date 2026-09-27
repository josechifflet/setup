#!/usr/bin/env bash
set -euo pipefail

# Agents read git and may add and commit; the user runs every other git write,
# and no agent or subagent leaves the branch or checkout its session started
# in. That rule lives in each home's CLAUDE.md or AGENTS.md, and this hook is
# the fast backstop behind it. It allows a git call only when its subcommand is
# a known read, `add`, or `commit` without --amend. It also refuses `wt` and
# the `gh` commands that check out, merge or sync a branch. Every refusal tells
# the agent why and what to do next, because a bare denial reads as a hurdle to
# route around. The text states facts, not orders: Claude can treat an order
# from outside the conversation as prompt injection and surface it instead of
# acting on it. It parses laxly on purpose: no alias, variable or $(...) word is resolved, text piped
# or here-string fed into a shell is not read, and a git word split by quotes
# never reaches the parser, so `$G push`, `echo git push | sh`, `g''it push` or
# `$(echo git) push` passes. That trade keeps jq and shfmt off the path.
#
# [PERF] bash 3.2 and BWK awk on darwin/arm64: ~4ms with no `git`, `gh pr`,
# `gh repo` or `wt ` in the command, no exec at all; ~7ms with one, a single awk; ~32ms for a 245KB
# heredoc. The shfmt and jq version this replaced took ~23ms and ~78ms.

# [PERF] Byte semantics. In a UTF-8 locale bash 3.2 counts and matches by
# character, and one `${x%%y*}` on a 245KB payload took 9s.
LC_ALL=C

# `$(</dev/stdin)` reads in blocks with no `cat`. The fallback covers a host
# with no /dev/stdin, where the bare form would fail open.
{ PAYLOAD=$(< /dev/stdin); } 2> /dev/null || PAYLOAD=$(cat)

# Grok reads the decision from stdout. $1 never holds a quote or a backslash:
# awk strips a subcommand to [A-Za-z0-9._@/+$ -] before it names one, and the
# rest is fixed text.
block() {
  printf '{"decision": "deny", "reason": "BLOCKED: %s"}\n' "$1"
  exit 2
}

case $PAYLOAD in
  *git* | *'gh pr'* | *'gh repo'* | *'wt '*) ;;
  *) exit 0 ;;
esac

# JSON escapes every quote inside a string value, so only the real key can
# match here. The value is a JSON string on one line whatever the layout, so
# awk reads it as the first record and ignores the rest.
case $PAYLOAD in
  *\"command\"*) REST=${PAYLOAD#*\"command\"} ;;
  *) block "the git guard found no command in its payload and cannot check this call. Rules set by the user allow agents only git reads, add and commit." ;;
esac
case $REST in
  *git* | *'gh pr'* | *'gh repo'* | *'wt '*) ;;
  *) exit 0 ;;
esac

# The awk program must hold no apostrophe: it sits in single quotes and gets
# one as `q`.
# shellcheck disable=SC2016  # awk source, not shell
GUARD_AWK='
# Reads the JSON string after the "command" key and prints why the command is
# refused, or nothing. The tokenizer knows quotes, $( ), backticks, subshells,
# redirections, comments and heredoc bodies, so a git word inside a string, a
# comment or a heredoc is no call. A backslash is parked as \034 before the
# JSON escapes are undone, so every backslash left in the command is \034.
BEGIN {
  BS = "\034"; DQ = "[\"\034`$]"; CX = "[\"\034`$()<]"; CAP = 65536
  n = split("status diff log show blame annotate grep shortlog describe rev-parse rev-list ls-files ls-tree ls-remote cat-file for-each-ref show-ref show-branch merge-base name-rev whatchanged cherry range-diff count-objects check-ignore check-attr check-ref-format check-mailmap var help version verify-commit verify-tag diff-tree diff-files diff-index", t, " ")
  for (k = 1; k <= n; k++) READ[t[k]] = 1
  n = split("command builtin exec nice nohup time timeout gtimeout doas sudo env xargs stdbuf setsid noglob nocorrect caffeinate if then do else elif while until ! { coproc", t, " ")
  for (k = 1; k <= n; k++) WRAP[t[k]] = 1
  n = split("sh bash zsh dash ksh mksh", t, " ")
  for (k = 1; k <= n; k++) SHELLS[t[k]] = 1
  n = split("\" $ ` ( ) ; & | < > #", t, " ")
  for (k = 1; k <= n; k++) SP[t[k]] = 1
  SP[" "] = 1; SP["\t"] = 1; SP[q] = 1; SP[BS] = 1
  # What a refused command would do, and what the agent does instead.
  MOVE = "changes the branch or checkout this session works in. Rules set by the user keep every agent and subagent on the branch and checkout the session started in, plans included. Only the user changes branches or worktrees. The work continues on this branch. If it cannot, the next step is to hand the user the exact command."
  REWRITE = "rewrites history or discards work. Rules set by the user allow agents only git reads, add and commit, and leave every other git write to the user. The next step is to hand the user the exact command and continue without it."
  REMOTE = "talks to a remote. Rules set by the user leave every push, fetch and pull to the user. The next step is to hand the user the exact command and continue without it."
  OTHER = "is not a git read, add or commit. Rules set by the user leave every other git write to the user. The next step is to hand the user the exact command and continue without it."
  TAIL = " The same rules forbid reaching it through another spelling, a script, an alias, wt, a worktree or a subagent."
  n = split("switch checkout worktree branch bisect symbolic-ref", t, " ")
  for (k = 1; k <= n; k++) KIND[t[k]] = MOVE
  n = split("commit rebase reset merge cherry-pick revert restore stash clean rm am update-ref gc prune reflog replace filter-branch", t, " ")
  for (k = 1; k <= n; k++) KIND[t[k]] = REWRITE
  n = split("push fetch pull clone", t, " ")
  for (k = 1; k <= n; k++) KIND[t[k]] = REMOTE
  # Listing forms. A positional argument is a name to create unless a flag
  # puts the command in list mode.
  BR_S = "^-[ailqrv]+$"
  BR_L = "^--(list|all|remotes|verbose|quiet|contains|no-contains|merged|no-merged|points-at|sort|format|color|no-color|column|no-column|abbrev|no-abbrev|show-current|ignore-case|omit-empty)(=|$)"
  BR_LS = "^(-[ailqrv]*[alr][ailqrv]*|--(list|all|remotes|contains|no-contains|merged|no-merged|points-at)(=.*)?)$"
  TG_S = "^-[ilnv0-9]+$"
  TG_L = "^--(list|contains|no-contains|merged|no-merged|points-at|sort|format|color|no-color|column|no-column|ignore-case|omit-empty|verify)(=|$)"
  TG_LS = "^(-[ilnv0-9]*[lnv][ilnv0-9]*|--(list|contains|no-contains|merged|no-merged|points-at|verify)(=.*)?)$"
  reset()
}
NR == 1 {
  s = $0
  sub(/^[ \t\r:]*/, "", s)
  if (substr(s, 1, 1) != "\"") { print "the git guard found a command that is not a string and cannot check this call. Rules set by the user allow agents only git reads, add and commit."; done = 1; next }
  s = substr(s, 2)
  # [PERF] Each gsub costs ~3ms on a 245KB command, so one runs only when
  # index finds its target, and the lines split on the escaped \n directly.
  if (index(s, "\\\\")) gsub(/\\\\/, BS, s)
  if (index(s, "\\\"")) gsub(/\\"/, "\035", s)
  p = index(s, "\"")
  if (p) s = substr(s, 1, p - 1)
  if (!hot(s)) { done = 1; next }
  if (index(s, "\\t")) gsub(/\\t/, "\t", s)
  if (index(s, "\\r")) gsub(/\\r/, "", s)
  if (index(s, "\\/")) gsub(/\\\//, "/", s)
  if (index(s, "\035")) gsub(/\035/, "\"", s)
  # Encoders that escape HTML-significant bytes would otherwise hide && and >.
  if (index(s, "\\u")) {
    gsub(/\\u0026/, "\\&", s); gsub(/\\u003[cC]/, "<", s); gsub(/\\u003[eE]/, ">", s)
    gsub(/\\u0027/, q, s); gsub(/\\u0022/, "\"", s)
  }
  m = split(s, L, "\\\\n")
  for (li = 1; li <= m; li++) scan(L[li])
}
END {
  if (done) exit
  finish()
  while (qi < qn) {
    reset()
    m = split(Q[++qi], L, "\n")
    for (li = 1; li <= m; li++) scan(L[li])
    finish()
  }
}

function reset() {
  d = 0; o = 0; K[0] = "C"; CL[0] = ""
  NW[0] = 0; CW[0] = ""; HW[0] = 0; LN[0] = 0; RD[0] = 0
  nhd = 0; body = 0; cont = 0
}
# The context stack: C is a command list (top level, $( ), ( ) or backticks),
# S a single quote, A a $-single quote, D a double quote. Words belong to the
# nearest C level, o.
function push(kind, closer) {
  d++; K[d] = kind; CL[d] = closer
  if (kind == "C") { NW[d] = 0; CW[d] = ""; HW[d] = 0; LN[d] = 0; RD[d] = 0; o = d }
}
function pop() {
  if (d) d--
  o = K[d] == "C" ? d : d - 1
}
function addw(s) {
  HW[o] = 1
  if (LN[o] < CAP) { CW[o] = CW[o] s; LN[o] += length(s) }
}
function dropword() { CW[o] = ""; HW[o] = 0; LN[o] = 0 }
function endword() {
  if (!HW[o]) return
  if (RD[o]) RD[o] = 0
  else W[o, ++NW[o]] = CW[o]
  dropword()
}
function endseg() {
  endword()
  if (NW[o]) run(o, 1, NW[o])
  NW[o] = 0; RD[o] = 0; seg++
}
function finish() {
  while (d) { if (K[d] == "C") endseg(); pop() }
  endseg()
}
# Text that every command this guard checks contains. gh takes --repo after
# its group, so `gh pr` and `gh repo` stay adjacent. Narrow on purpose: bare
# gh or wt would send every command that says "through" or "newt" to the walk.
function hot(x) { return index(x, "git") || index(x, "gh pr") || index(x, "gh repo") || index(x, "wt ") }
function enqueue(s) { if (hot(s) && qn < 16) Q[++qn] = s }
function deny(s, why) {
  gsub(/[^A-Za-z0-9._@\/+$ -]/, "", s)
  print "`" s "` " why TAIL
  done = 1
  exit
}

function scan(line,    n, i, j, c, k, dl, dash, lc) {
  if (body) { hdline(line); return }
  k = K[d]
  # Whole-line shortcuts: a line that cannot close its quote, or a fresh
  # command line with nothing that could reach git, skips the character walk.
  if (k == "S" || k == "A") { if (!index(line, q)) { addw(line "\n"); return } }
  else if (k == "D") { if (line !~ DQ) { addw(line "\n"); return } }
  else if (!cont && !NW[o] && !HW[o] && !hot(line) && !index(line, q) && line !~ CX) { seg++; return }
  n = split(line, ch, "")
  lc = 0
  for (i = 1; i <= n; i++) {
    c = ch[i]; k = K[d]
    if (k == "S") {
      for (j = i; j <= n && ch[j] != q; j++) ;
      if (j > i) addw(substr(line, i, j - i))
      if (j <= n) pop()
      i = j
    } else if (k == "A") {
      if (c == BS) { if (i < n) addw(ch[++i]) }
      else if (c == q) pop()
      else addw(c)
    } else if (k == "D") {
      for (j = i; j <= n && ch[j] != "\"" && ch[j] != BS && ch[j] != "$" && ch[j] != "`"; j++) ;
      if (j > i) addw(substr(line, i, j - i))
      if (j > n) break
      i = j; c = ch[i]
      if (c == "\"") pop()
      else if (c == BS) { if (i < n) addw(ch[++i]); else lc = 1 }
      else if (c == "`") { addw("$"); push("C", "`") }
      else if (ch[i + 1] == "(") { i++; addw("$"); push("C", ")") }
      else addw("$")
    } else if (!(c in SP)) {
      for (j = i + 1; j <= n && !(ch[j] in SP); j++) ;
      addw(substr(line, i, j - i))
      i = j - 1
    } else if (c == " " || c == "\t") endword()
    else if (c == BS) { if (i < n) addw(ch[++i]); else lc = 1 }
    else if (c == q) { HW[o] = 1; push("S", "") }
    else if (c == "\"") { HW[o] = 1; push("D", "") }
    else if (c == "$") {
      if (ch[i + 1] == q) { i++; HW[o] = 1; push("A", "") }
      else if (ch[i + 1] == "(") { i++; addw("$"); push("C", ")") }
      else addw("$")
    } else if (c == "`") {
      if (CL[d] == "`") { endseg(); pop() } else { addw("$"); push("C", "`") }
    } else if (c == "(") { endseg(); push("C", ")") }
    else if (c == ")") { endseg(); if (CL[d] == ")") pop() }
    else if (c == ";" || c == "|" || (c == "&" && ch[i + 1] != ">")) endseg()
    else if (c == "#") { if (HW[o]) addw(c); else break }
    else if (c == "<" && ch[i + 1] == "<" && ch[i + 2] != "<") {
      if (CW[o] ~ /^[0-9]+$/) dropword(); else endword()
      i += 2; dash = 0
      if (ch[i] == "-") { dash = 1; i++ }
      while (ch[i] == " " || ch[i] == "\t") i++
      for (dl = ""; i <= n && ch[i] !~ /[ \t;&|()<>]/; i++) if (ch[i] != q && ch[i] != "\"" && ch[i] != BS) dl = dl ch[i]
      i--
      HD[++nhd] = dl; HT[nhd] = dash; HS[nhd] = seg
    } else {
      # A redirection: an fd number before it and the target after it are
      # not arguments, so `git branch 2>/dev/null` stays a listing.
      if (CW[o] ~ /^[0-9]+$/) dropword(); else endword()
      while (i < n && ch[i + 1] ~ /[<>&|]/) i++
      RD[o] = 1
    }
  }
  k = K[d]
  if (k == "S" || k == "A") addw("\n")
  else if (k == "D") { if (!lc) addw("\n") }
  else if (!lc) {
    endseg()
    if (nhd) { body = 1; hk = 1; hb = ""; hl = 0 }
  }
  cont = lc
}
# A heredoc body is data unless a shell reads it as a script.
function hdline(line,    t) {
  t = line
  if (HT[hk]) sub(/^\t+/, "", t)
  if (t == HD[hk]) {
    if (HS[hk] in SH) enqueue(hb)
    hb = ""; hl = 0
    if (++hk > nhd) { body = 0; nhd = 0 }
    return
  }
  if ((HS[hk] in SH) && hl < CAP) { hb = hb line "\n"; hl += length(line) + 1 }
}

# One simple command. Assignments, wrappers and their options come off the
# front; `-exec` starts a nested command; a shell with -c and eval queue their
# script for a later pass.
function run(lv, s, e,    i, w, b, wr, j) {
  wr = 0
  for (i = s; i <= e; i++) {
    w = W[lv, i]; b = w; sub(/.*\//, "", b)
    if (b == "git") break
    if (w ~ /^[A-Za-z_][A-Za-z0-9_]*=/) continue
    if (b in WRAP) { wr = 1; continue }
    # Runners whose command follows `--`, or a directory for direnv. A mise
    # command string runs through a shell, so it is queued like sh -c.
    if ((b == "mise" && W[lv, i + 1] ~ /^(exec|x)$/) || (b == "op" && W[lv, i + 1] == "run")) {
      for (i += 2; i <= e && W[lv, i] != "--"; i++) {
        if (W[lv, i] ~ /^(-c|--command)$/ && i < e) enqueue(W[lv, i + 1])
        else if (W[lv, i] ~ /^--command=/) enqueue(substr(W[lv, i], 11))
      }
      continue
    }
    if (b == "direnv" && W[lv, i + 1] == "exec") { i += 2; continue }
    if (wr && (w ~ /^-/ || w ~ /^[0-9][0-9.]*[smhd]?$/ || (i > s && W[lv, i - 1] ~ /^(-[A-Za-z]|--(signal|kill-after|user|group|chdir|unset))$/))) continue
    break
  }
  if (i > e) return
  for (j = i + 1; j <= e; j++) if (W[lv, j] ~ /^-(exec|execdir|ok|okdir)$/) { run(lv, j + 1, e); break }
  if (b == "git") gitcheck(lv, i + 1, e)
  else if (b == "wt") wtcheck(lv, i + 1, e)
  else if (b == "gh") ghcheck(lv, i + 1, e)
  else if (b in SHELLS) {
    for (j = i + 1; j <= e; j++) {
      w = W[lv, j]
      if (w == "-o" || w == "+o") j++
      else if (w ~ /^-[A-Za-z]*c[A-Za-z]*$/) { if (j < e) enqueue(W[lv, j + 1]); return }
      else if (w !~ /^[-+]/) return
    }
    SH[seg] = 1
  } else if (b == "eval") {
    for (w = ""; ++i <= e; ) w = w " " W[lv, i]
    enqueue(w)
  } else if (b == "watch") {
    # watch joins its arguments and hands them to sh -c.
    for (j = i + 1; j <= e && W[lv, j] ~ /^-/; j++) if (W[lv, j] ~ /^(-n|--interval|-q|--equexit)$/) j++
    for (w = ""; j <= e; j++) w = w " " W[lv, j]
    enqueue(w)
  }
}

# Global options come off the front; the subcommand then has to be a read.
function gitcheck(lv, i, e,    w, sc, k, np, p1) {
  for (; i <= e; i++) {
    w = W[lv, i]
    if (w ~ /^(-C|-c|--git-dir|--work-tree|--namespace|--config-env|--super-prefix|--attr-source)$/) i++
    else if (w !~ /^-/) break
  }
  if (i > e) return
  sc = W[lv, i]
  if (sc in READ) {
    for (k = i + 1; k <= e; k++) if (W[lv, k] ~ /^--output(=|$)/) deny("git " sc " --output", "writes a file. The plain read with its output redirected does the same with no git write.")
    return
  }
  # Staging and new commits are the writes agents may run. git takes any
  # unique prefix of a long option, and --am is already --amend.
  if (sc == "add") return
  if (sc == "commit") {
    for (k = i + 1; k <= e; k++) if (W[lv, k] ~ /^--am(e(nd?)?)?$/) deny("git commit --amend", REWRITE)
    return
  }
  # Help never writes. Only the first argument counts: later, `--help` can be
  # the value of an option, as in `git commit -m --help`.
  if (W[lv, i + 1] == "--help" && i < e) return
  if (e == i + 1 && W[lv, e] == "-h") return
  np = 0; p1 = ""
  for (k = i + 1; k <= e; k++) if (W[lv, k] !~ /^-/ && !np++) p1 = W[lv, k]
  if (sc == "branch") { if (listonly(lv, i + 1, e, BR_S, BR_L, BR_LS)) return }
  else if (sc == "tag") { if (listonly(lv, i + 1, e, TG_S, TG_L, TG_LS)) return }
  else if (sc == "config") { if (confread(lv, i + 1, e)) return }
  else if (sc == "remote") { if (p1 == "" || p1 == "show" || p1 == "get-url") return }
  else if (sc == "stash") { if (p1 == "list" || p1 == "show") return }
  else if (sc == "worktree") { if (p1 == "list") return }
  else if (sc == "reflog") { if (p1 !~ /^(expire|delete|drop|write)$/) return }
  else if (sc == "notes") { if (p1 == "" || p1 == "list" || p1 == "show") return }
  else if (sc == "submodule") { if (p1 == "" || p1 == "status" || p1 == "summary") return }
  else if (sc == "symbolic-ref") {
    for (k = i + 1; k <= e; k++) if (W[lv, k] ~ /^(-d|--delete)$/) np = 2
    if (np <= 1) return
  }
  deny("git " sc, (sc in KIND) ? KIND[sc] : OTHER)
}
# worktrunk switches between worktrees and makes new ones; only its listing,
# config and help leave the checkout alone.
function wtcheck(lv, s, e,    k, w) {
  for (k = s; k <= e; k++) {
    w = W[lv, k]
    if (w ~ /^(-C|--config|--config-set)$/) k++
    else if (w !~ /^-/) break
  }
  if (k > e || w ~ /^(list|config|help)$/) return
  deny("wt " w, MOVE)
}
# The gh commands that check out, merge or sync a branch in this clone.
function ghcheck(lv, s, e,    k, w, g1, g2) {
  for (k = s; k <= e; k++) {
    w = W[lv, k]
    if (w ~ /^(-R|--repo)$/) k++
    else if (w !~ /^-/) { if (g1 == "") g1 = w; else { g2 = w; break } }
  }
  if ((g1 == "pr" && g2 ~ /^(checkout|co|merge)$/) || (g1 == "repo" && g2 == "sync")) deny("gh " g1 " " g2, MOVE)
}
function listonly(lv, s, e, sre, lre, lsre,    k, w, np, ls) {
  np = 0; ls = 0
  for (k = s; k <= e; k++) {
    w = W[lv, k]
    if (w == "--") { np += e - k; break }
    if (w !~ /^-/) np++
    else if (w ~ /^--/ ? w !~ lre : w !~ sre) return 0
    else {
      if (w ~ lsre) ls = 1
      # A value after a space is a value, not a name to create.
      if (w ~ /^--(sort|format)$/) k++
    }
  }
  return !np || ls
}
function confread(lv, s, e,    k, w, np, p1, rd) {
  np = 0; rd = 0; p1 = ""
  for (k = s; k <= e; k++) {
    w = W[lv, k]
    if (w == "-e" || w ~ /^--(add|unset|unset-all|replace-all|rename-section|remove-section|edit)$/) return 0
    if (w == "-l" || w ~ /^--(get|get-all|get-regexp|get-urlmatch|get-color|get-colorbool|list)$/) rd = 1
    else if (w ~ /^(-f|--file|--blob|--type|--default|--comment|--value|--url)$/) k++
    else if (w !~ /^-/ && !np++) p1 = w
  }
  return rd || p1 == "get" || p1 == "list" || (np <= 1 && p1 !~ /^(set|unset|rename-section|remove-section|edit)$/)
}
'

REASON=$(printf '%s\n' "$REST" | awk -v q="'" "$GUARD_AWK") || block "the git guard failed to run and cannot check this call. Rules set by the user allow agents only git reads, add and commit."
[[ -z $REASON ]] || block "$REASON"
exit 0
