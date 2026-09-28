# Prompts

One prompt per stage, in lifecycle order. Fill in every `<…>`. In a tool without slash commands, replace `/behaviour <mode>` with `Use the behaviour skill in <mode> mode.`

## Set up a home in an existing repo

```text
/behaviour map

Set up the behaviour trees for this repo. They are for <what>, read by <who>. Leave out <anything>.
My answers so far; delete a line to get your recommendation instead:
- Scope: <product only, as user flows and stories with nothing technical | product plus the critical technical rules | technical per package>
- Homes: <one home | one per package, such as .behaviours/frontend/ and .behaviours/backend/>
- Areas: <flows | user stories | features | services>
Survey first. Decide what the repo answers and show the evidence. Ask me the rest, each with options, your recommendation and its reason.
Write nothing until I confirm the shape and the areas. Then write the index with every decision and its reason, the area cards, and an outline draft for every unit.
Audit the home. Report the drafts, the OPEN questions and the code findings, then start align on the most critical area.
```

## Reshape a home

```text
/behaviour map

The current home does not work for me: <what feels wrong>.
Reopen the shape decisions in the index and propose the smallest reshape that fixes it, with options and your recommendation.
Change nothing until I pick. Keep every aligned tree; move or cut only drafts.
```

## Align drafts

```text
/behaviour align <area, or blank for every draft>

Walk me through the drafts and OPEN questions, one unit at a time, most critical area first.
I answer each question with keep, change, cut, deepen, open or out of scope.
For a tree I already aligned, show me only what changed.
At the end, list every aligned leaf the code does not meet yet.
```

## Specify a new feature

```text
/behaviour write <feature>

Specify <feature> before we build it: <who uses it, what they do, what must never happen>.
Ask me about every gap before you write a branch. Then align the tree with me.
```

## Go deep on one function

```text
/behaviour write <Type::function>

Zoom code, depth exhaustive: one branch per guard, conditional arm, catch and loop edge, in source order.
Anything the code does that nobody asked for becomes an OPEN question, not a branch.
```

## Change behaviour

```text
/behaviour write <area>

<Behaviour> changes to <new behaviour>.
Update the authority first, then the trees, in the same change.
Then run check on diff by trace.
```

## Generate tests

```text
/behaviour tests <area or unit>

Generate tests from the aligned trees in this repo's test style. <Structure only | Write the assertion bodies too.>
```

## Audit the home

```text
/behaviour audit <area, or blank for the whole home>

Find every inconsistency: structure, language, logic, authority and repo.
Fix structure and wording once I agree. Turn the rest into questions for align.
```

## Fit a home to its budget

```text
/behaviour audit

Run the structure layer and list every unit, area and home over budget.
For each, propose cuts, merges or splits from the budget rules, smallest change first. Change nothing until I pick.
```

## Check before a release

```text
/behaviour check smoke

Check the smoke path of every aligned tree by <run | tests | trace>.
Report each FAIL with its evidence and each GAP as a question.
```

Use `full` to check every leaf, or `explore` to leave the trees on purpose.

## Verify with certainty

```text
/behaviour verify <area or unit>

Verify every aligned leaf and score how certain each verdict is. Target certainty <10 | 8>.
Temporary tests are fine. Delete them before you report.
```

## Read an area

```text
/behaviour

Explain <area> to me as path sentences, smoke paths first. Change nothing.
```
