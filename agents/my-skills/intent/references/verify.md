# Verify

`verify` proves each leaf met or not met and scores how certain that verdict is, from 0 to 10. `check` gives one verdict by one method. `verify` stacks evidence per leaf, asks TypeSafe to judge what the evidence shows, and climbs to stronger evidence until the verdict reaches the target certainty or three passes run out.

## Setup

1. Load the `typesafe-ai` skill and confirm the request shape on its live API page. Today it is `POST https://api.typesafe.ai/v1/systemone` with `Authorization: Bearer $TYPESAFE_API_KEY`, model `jev-latest`, and a `questions` map keyed by your own IDs. Never print the key or write it to a file. Retry 429 and 529 with exponential backoff.
2. Scope: the units or areas the user names. List the leaves with `scripts/trees paths --aligned <scope>`.
3. Target: the certainty the user names; otherwise 10.
4. Stamp: `V` and the local time as `MMDDHHmm`, for example `V09281430`. Every temporary file and record carries it.

## Evidence ladder

Climb one rung at a time, and only as high as the receipt demands. Each rung caps the certainty it can support.

1. Code, cap 6. Find the code on the leaf's path and cite `file:line`. When several spans could be the one, ask TypeSafe one Choice over the candidates plus `none`. The code says so; nothing ran.
2. Existing test, cap 8. Run only the suite tests that drive the leaf's conditions. Their authors asserted what they meant, which may be less than the leaf.
3. Smoke run or temporary test, cap 10. A smoke run drives the running software as `references/check.md` describes under `run`. A temporary test asserts exactly the leaf. Either reaches 10 only when it observes the leaf at its own zoom: a smoke run for `product`, a temporary test for `code`, either for `contract`. Otherwise its cap is 9.

## Temporary tests

- Write one file per unit, named with `intent-verify-<stamp>`, where and how the test runner discovers tests. Mirror an existing test's setup.
- Assert the leaf's outcome and every effect. Set up each earlier sibling on the path to fail, because the first match wins. For a child, reach its parent's path first.
- Prove the test can fail: invert one expectation, run it, watch it fail, restore it. A test that cannot fail proves nothing.
- Run only that file. Never edit production code or an existing test. Use only stamped records.
- Delete every temporary file before you report, and confirm with `git status --porcelain` that none is left. After an interrupted run, find leftovers by the stamp.
- A temporary test that earned a 10 may deserve a place in the suite. Offer it, and keep it only when the user says so, through the `tests` mode.

## Judge

TypeSafe judges what the evidence means. Ask all of a leaf's questions in one request, over one state. Keep each excerpt to the lines on the leaf's path: unrelated detail distracts the model, and state plus the longest question must fit in 32k tokens. Jev counts unreliably and reads numbers and dates as text, so compare them in the test or in code and put the result in the state.

```json
{
  "conditions": ["given the order is paid", "when refunds.create resolves"],
  "outcome": "it should return the order with status `cancelled`",
  "effects": ["it should call `refunds.create` once with the captured amount"],
  "zoom": "code",
  "place": "src/orders/service.ts",
  "evidence": [
    { "rung": "code", "source": "src/orders/service.ts:41-52", "excerpt": "…" },
    {
      "rung": "temporary test",
      "source": "test/intent-verify-V09281430.test.ts",
      "excerpt": "…",
      "result": "passed",
      "can_fail": "yes: it failed when one expectation was inverted"
    }
  ]
}
```

For a child, `conditions` starts with its parent's path to the refined outcome. Write `result` as `passed` or `failed: <message>`, and keep the can-fail proof in `can_fail`. A mixed string such as "passed; failed when inverted" pulls probability toward `contradicts`.

Two Choice questions, worded the same way every time:

- `relation_<i>`, one per evidence item. Instructions: "How does `evidence[<i>]` relate to `outcome` under `conditions`? Ignore `effects`." Criteria: `shows`, "it exercises every condition in `conditions` and shows all of `outcome` happening"; `contradicts`, "it exercises those conditions and shows a different outcome, or fails on `outcome`"; `says_nothing`, "it does not settle `outcome` under `conditions` either way: other conditions, only part of `outcome`, or unrelated".
- `effect_<j>`, one per effect. Instructions: "Does the evidence show `effects[<j>]` in the same run as `outcome`?" Criteria: `shows`, "an evidence item shows it"; `contradicts`, "an evidence item shows it absent or different"; `says_nothing`, "no evidence item addresses it".

The relation question ignores effects on purpose: judged together, one unshown effect drags a passing test toward partial. The rules stay yours, applied in order:

1. Verdict. `NOT MET` when any relation or effect answers `contradicts`: one confident red flag is enough. `MET` when a relation answers `shows` and nothing contradicts. `UNKNOWN` otherwise.
2. Judgment: `round(10 × confidence)` of the answer that decides the verdict, the most confident `contradicts` or `shows`. `UNKNOWN` scores 0.
3. Certainty: the lower of the judgment and the cap of the deciding item's rung. An effect answered `says_nothing` caps it at 5.

Choice confidence measures how concentrated the answer is, not whether it is true. A judgment of 9 or 10 matches the docs' band for acting without a person. On `jev-1.13.0`, a passing temporary test with a can-fail proof read `shows` at 0.87; the same test failing read `contradicts` at 0.90; a code read reached 0.44. Record the `model` each response names: a mapping tuned on one Jev version may not hold on the next. When TypeSafe is unreachable, answer the same questions yourself with a confidence from 0 to 1, cap certainty at 8, and mark the leaf `judged without TypeSafe`.

## Certainty loop

1. Score each leaf. Below the target, write a one-line receipt: the missing rung, the unshown effect, or the conflict, with its `file:line`.
2. Climb to the rung the receipt names, and judge again.
3. Stop at the target, or after three passes. At the cap, report the receipt that survived and what blocks it.

Honesty:

- A 10 is a verdict you would stake your reputation on.
- A score below 10 without a receipt is a mood, not a score.
- Only new evidence moves a score. Rereading the same evidence does not.
- Stop at the target. Never write a temporary test to decorate a leaf that already reached it.
- Certainty measures the verdict, not the software. `NOT MET 10/10` is a strong result.

## Fan-out

When the tool can spawn subagents, give each unit its own, at most four at once. Temporary tests that share a database run one agent at a time.

## Report

```text
<file>:<line> MET|NOT MET|UNKNOWN <certainty>/10 <rung> — <evidence> [— receipt: <what keeps it below 10>]
```

1. Counts per verdict, and per certainty: 10, 7 to 9, 0 to 6.
2. Every `NOT MET` with its evidence.
3. Every leaf below the target, with its receipt and blocker.
4. The Jev model version, and every leaf judged without TypeSafe.
5. The temporary files created and the proof that each is deleted.
