# Color

Law 11 owns where color comes from. Law 9 owns what earns it. Law 16 owns depth. This sheet carries the values those three leave unstated: the size of a categorical hue set and how many one surface carries, the meanings fixed to status, the three parts a chip is built from, the neutral ramp and what stays on it, the link, the chart series and the pale comparison behind it, and what an accent spends on a dark surface. Color is a data channel with a capacity, and every value below is a starting point a system replaces with its own token. None of them settles a Law.

## Category hues

A categorical set is six hues. Six saved views take six dots and each one is found on sight. A seventh hue lands between two that already exist and the set stops reading as a set; eight is the ceiling, and past it the channel is spent and the label does the work.

The six, spaced by hue angle so no pair sits within 30 degrees:

- Blue — `oklch(0.546 0.245 263)` — `#2563eb`
- Purple — `oklch(0.541 0.281 293)` — `#7c3aed`
- Green — `oklch(0.627 0.194 149)` — `#16a34a`
- Red — `oklch(0.577 0.245 27)` — `#dc2626`
- Amber — `oklch(0.769 0.188 70)` — `#f59e0b`
- Pink — `oklch(0.592 0.249 1)` — `#db2777`

One surface carries one set. A sidebar of colored dots, a column of chips and a chart legend on the same screen draw from the same six, and the same hue means the same category in all three. Two sets on one surface make the hue mean nothing.

Hue alone separates a set only at equal lightness. Hold every member within `0.08` of L `0.58`, amber excepted, and separate any pair a color-vision deficiency collapses — red against green, blue against purple — by a lightness gap of at least `0.15` or by shape. A dot is 8px, and 8px of color reads as hue and nothing finer.

## Status

Status is a fixed vocabulary, not a palette choice. Six meanings, bound once, reused everywhere:

- Success, closed, healthy — green `#16a34a`
- Error, failed, overdue — red `#dc2626`
- Warning, stale, at threshold — amber `#d97706`
- Information, in progress, new — blue `#2563eb`
- Neutral, draft, idle — the ramp, no hue
- Emphasis, beta, special — purple `#7c3aed`

Neutral is a status. Draft, idle and unchanged sit on the ramp with no accent at all, which is Law 9's silent default arriving as color. A status hue on a routine state burns the one signal that says something changed.

Green and red carry a direction, so a metric that falls where falling is good takes the meaning and not the arithmetic: cost down is green.

## Chips

A chip is three parts in one hue plus a fourth decision. Tint background, saturated text, an icon matching the text, and a border only where the chip sits on a tinted surface that swallows its own tint.

- Background — the hue at L `0.95`, chroma `0.03`: `#dbeafe` blue, `#dcfce7` green, `#fee2e2` red, `#ede9fe` purple, `#fce7f3` pink, `#fef3c7` amber.
- Text and icon — the same hue at L `0.45`, chroma `0.15`: `#1d4ed8`, `#15803d`, `#b91c1c`, `#6d28d9`, `#be185d`, `#b45309`.
- Contrast — that pairing holds 4.5:1 or better, so a chip needs no second check per hue. Lightness gap between tint and text is `0.50`.
- Border — none on a white or ramp-0 surface, where the tint is the whole boundary. On a tinted or photographic surface, the text color at 15% alpha, drawn with `material.md`'s hairline recipe.

The icon takes the chip's text color, since Law 14 gives peers in one context one color logic. A chip with a gray glyph and colored text reads as two decisions.

Chip height sits at 20px to 24px with 6px to 8px of inline padding, and the label runs one step below body size at a raised weight. Uppercase suits a short tag of four characters or fewer; a word stays sentence case.

A monochrome chip is the default for an open string that carries no category: ramp-2 background, ramp-9 text, no hue. Hue is spent on a closed set where the color is the retrieval key.

## Neutrals

The ramp is tinted toward the accent hue at chroma `0.004` to `0.010`, which is Law 11's one family. Eleven steps, lightness first:

`0.99` `0.97` `0.94` `0.90` `0.83` `0.71` `0.58` `0.47` `0.37` `0.27` `0.18`

Jobs, from the top: page, sunken panel, hover fill, hairline and disabled fill, border, disabled text and decorative glyph, placeholder, secondary text, strong secondary, body text, heading.

Contrast against the page: body at step 9 holds 12:1, secondary at step 7 holds 4.8:1, and step 6 falls to 2.5:1 and is therefore a glyph or a rule and never a word. Large text at 18.66px bold or 24px regular drops to a 3:1 floor, and a non-text boundary a control depends on holds 3:1.

What stays on the ramp: every unchanged default, every unchecked box, every table rule, every secondary label, every disabled control, every decorative glyph and every icon that sits beside a label rather than carrying a status. A settings panel at its defaults runs entirely on the ramp, and the one blue toggle is the one thing that changed.

## Links

An inline link is the accent hue at L `0.45` — `#1d4ed8` — and underlined. Underline offset `0.15em`, thickness `1px` at body size, `skip-ink: auto`.

Color alone separates a link from body text only at 3:1 between the two, and the underline is what satisfies WCAG 1.4.1 without that measurement. Hover raises the underline to `2px` and darkens to L `0.38`. Focus takes a `2px` outline at the accent with `2px` of offset, never an underline change, since the underline is already spent.

A link in a nav, a toolbar or a card title drops both the accent and the underline: it is a whole region, its interactivity is its position, and Law 10 already requires that position to show it. Visited state earns its place on document lists, where returning to an already-read item is the task.

## Chart series

A chart spends hue on series identity and lightness on time. This period runs the saturated hue; the comparison period runs the same hue washed out. One hue, two periods, no legend needed.

- This period — the category hue at chroma `0.19`, stroke `2px`, full opacity.
- Comparison — the same hue angle at L `0.88`, chroma `0.06`, stroke `1.5px`: `#fecaca` against `#dc2626`, `#bfdbfe` against `#2563eb`.
- Bars — the same pair stacked, the saturated bar above the pale one, so the delta is read as a length difference and not as a number.
- Gridlines and axis — ramp step 4 for the rules, ramp step 7 for the labels. A gridline that competes with the weakest series is one step too dark.

Six series is the ceiling here too, and it arrives sooner: four lines is where direct labels beat a legend. Past six, group the tail into one ramp-6 band and name it.

A series a user must identify holds 3:1 against the plot background. A pale comparison line is exempt, because it is read as the ghost of the line above it and never on its own.

The hovered series holds its color while the rest drop to 40% opacity, which is Law 8's recede-the-neighbors at chart scale.

## Dark surfaces

Hue inverts differently from surface. Lightness rises and chroma falls, because a saturated accent on a dark ground vibrates and a washed one disappears.

- Accent — L `0.55` becomes L `0.72`, chroma drops by about a third: `#2563eb` becomes `oklch(0.72 0.16 263)`.
- Chip — tint becomes the hue at L `0.28`, chroma `0.05`; text becomes the hue at L `0.80`, chroma `0.11`. The `0.50` lightness gap survives the flip, so the 4.5:1 floor survives with it.
- Link — L `0.75`, underline unchanged. A light-mode link color on a dark ground fails the floor.
- Chart comparison — the ghost darkens rather than lightens. Series at L `0.72`, comparison at L `0.42`, chroma `0.06`.
- Status — the same six meanings at the same six hue angles. Only lightness and chroma move.

The ramp flips its lightness order and keeps its tint, so the family Law 11 sets holds in both themes. Surface lightness per rung belongs to Law 16 and sits in `references/material.md`.

`material.md` already rules one token resolving to two values, so no component branches on theme.
