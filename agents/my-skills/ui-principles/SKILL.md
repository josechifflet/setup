---
name: ui-principles
description: "Manifesto for clean, scannable UI layout. Use when building, reshaping, reviewing, or fixing screens, dashboards, tables, forms, cards, settings, landing or marketing pages — edges, space, geometry, alignment, hierarchy, disclosure, color, typography, material, iconography, identity, composition, breakpoints, motion. Not backend or CLI."
argument-hint: "[build | review | fix]"
metadata:
  short-description: "Manifesto for clean, scannable UI layout"
---

# UI Principles

Nobody reads a screen. People arrive with a question already in their head and hunt until they find the answer, and nothing on a screen is ever fully consumed. Every law here exists to shorten that hunt. None of them is decoration: edges, differentiation and recognition are not what make a surface prettier, they are what make it faster to scan.

A layout is not a collection of boxes. It is a set of edges, the space between them, and the few things loud enough to break the pattern. Get those three right and the screen feels inevitable. Get them wrong and no amount of color, copy or polish repairs it.

Placing one piece is easy. Orchestrating every piece, in every state, seen and unseen, is the work.

Any visual surface qualifies: application, page, panel, document, slide, print. No framework, toolkit or platform is assumed.

## Modes

build — compose or reshape a surface, then review it.
review — evaluate without editing; report findings and a verdict.
fix — edits are authorized; apply them, then review again.

Infer the mode from the request. Default to review.

## Vocabulary

Surface: the whole composition.
Edge: any line content can hang from — a container side, a column start, a divider, a baseline, the underside of an avatar, the boundary of the group above.
Contact: an element aligned to an edge. Not literal touching.
Region: content the user treats as one thing.
Spine: a region's dominant edge — start of a list, end of a magnitude, time of a sequence.
Vessel: the form a region takes — a list, a timeline, a chart.
Rest: the surface before hover, focus, disclosure or empty.
Hidden layer: everything off the rest state — hover, focus, gesture, popover, drawer, modal, tooltip, first-run, announcement, and every state the data can produce.
Cue: whatever says these items belong together — space, tone, weight, a rule, an enclosure.
Skeleton: regions, order, proportion and spines, with no identity applied.
Identity: what the skeleton is dressed in — palette, type, texture, imagery, iconography, motion.
Register: the intent a region serves. Product favors retrieval and quiet controls. Brand allows expression and pauses. Density follows the task, the content and the input method. Choose per region, since a marketing page can hold a working form.

## The gate

Every element earns its place or it leaves. Failing the gate has two repairs: the element is removed, or it is encoded so that what leaves is the reading and not the fact, per Law 10. Removal is a design decision, and so is encoding. A surface is not better for holding more prose, and Law 7 already rules the void.

Time-to-answer is the standard, not element count. An element is justified when it shortens the hunt named at the top of this file, and unjustified when it does not. A surface carrying forty facts in forms the audience already owns answers faster than one carrying six in prose. A sparse screen is not automatically a good one: emptiness that lengthens the hunt fails the same gate that clutter fails.

These are not justifications: it looks good, it fills the space, the library ships a component for it, the default had it.

Before an element is added, kept or changed, it answers five questions:

1. Which edge does it sit on? Laws 1, 2, 3.
2. How is it differentiated? Laws 5, 6.
3. Can it be shown instead of told? Laws 10, 17.
4. Does it deserve its emphasis? Laws 8, 9.
5. Does it need a container? Laws 4, 5.

An element that cannot answer is fixed or removed. An unanswered question is a finding, ranked with the failures and never with taste.

## Act I — Edges

1. Edges carry the structure.
   Structure comes from shared edges. Each region hangs from one spine. Pick the vessel from the content, then hang it: text to the start, comparable numbers to the end, where digits line up by place value. A sequence that means time is a timeline, not a table sorted by date. A magnitude the user compares is a chart, not a column of figures. Two hard edges hold a row without help. Center only what nobody reads or compares — a badge, a glyph, one standalone line. A receipt has no dividers and almost no space, and it is still legible, because two edges do all the work.

2. Two contacts.
   Every element meets at least two edges. One contact floats. Two lock. A card feels resolved because it hands you four edges for free; an open canvas feels wrong because it hands you none. Every row draws a line that is a new edge for the next row to stack onto, which is why a checklist reads as built rather than placed. An edge only one element uses is no edge. An element with one contact has two repairs: clear content off the edge, or manufacture the second edge by splitting the row, promoting a divider, or letting the block above define a top edge. Enlarging an element takes away the edge its neighbors hung from, so restore that edge: a subline under an enlarged icon puts the bottom edge back. Collapsing the overflow into a menu is not a repair; it hides the defect and buries a frequent action.

3. Contact is local.
   Alignment needs proximity. An edge shared across a long gap is arithmetic, not structure. Stretch a tight list across a wide surface and every alignment survives while the composition dies. Cap each region at the width its content needs. Keep its contents close enough to read as one thing. Truncate a long cell so its siblings keep their edges. Distance separates whether you intend it or not.

4. Dissolve the container.
   Most cards are scaffolding left standing in the finished building. One column edge and a stack of rows group the same content with none of the ink, and the borders on borders and the three stacked radii go with it. Keep an enclosure only when its boundary explains a unit, a selection target or a relationship that edges cannot carry. A new screen is the same test at navigation scale: new functionality usually needs a layer, not a page.

## Act II — Space

5. Space is the first cue.
   Unequal gaps are the grouping. Equal gaps everywhere group nothing. Escalate only when space fails: space, then tone or weight, then a rule, then an enclosure. Each step is a louder claim. A boundary overrides both proximity and similarity, so it is the last cue you spend. Use the weakest cue that reads. Make every cue agree about membership, because when space and a boundary disagree the eye believes the boundary and the user is misled. A label belongs nearer its own field than the next one. Sibling gaps belong to the parent, so the same relationship is never spaced twice.

6. Differentiate before you dilute.
   Density is not the problem. Undifferentiated density is. Air added to a uniform wall makes a longer uniform wall. Give the eye landmarks instead. Group by what the user hunts for — date, owner, status — under headings that predict what follows. Swap a name for a known face, because the eye matches a face faster than it reads a name. Turn a closed set of values into chips and leave open strings as text. Prose is a wall until it is shaped, and a list or a table hands a paragraph the landmarks it lacked — though shaped past the point of need it is a wall again, in a new costume. Lift the number out of the sentence. Roll a time dimension into a trend so nobody hunts down a timestamp column. Headings are the strongest landmark, because people scan them and skip the text beneath. Then stop. A cue that marks some rows differentiates nothing once it fires on every one, while a glyph that names its own row is recognition rather than a landmark, and Law 17 makes that one the expected form.

7. A void is a decision.
   Empty space separates, paces, reserves a state or gives a target room. Space inside a container needs no excuse; it needs a role. Test a suspected hole by shrinking it, and keep the change only if grouping, balance, legibility and every state still hold. A hole that survives is structure. Never fill space merely because it is there.

## Act III — Signal

8. Emphasis is a difference, not a property.
   Edges, differentiation and recognition make a screen fast to scan. Not one of them says where to start. Emphasis is the only thing that does. Nothing is emphatic alone. An element stands out by how far it departs from its neighbors, so the first move is to quiet the neighbors, not to amplify the element. Recede the field, or darken the frame so the center becomes the subject without being touched. One dominant action per decision; independent decisions may each have one. The rest state holds that decision. Use the smallest difference that reads. One deviation is seen; a second cancels the first. A surface where nothing dominates fails exactly like one where everything does.

9. Defaults are silent.
   An unchecked box is a thin outline and nothing else, because the fill is the whole signal that something changed. Nobody would build one that is blue when off, yet screens ship with every default dressed as a change. A settings panel sitting at its defaults has nothing that stands out as changed, and that is correct. Keep defaults legible and mute. Spend color, weight and fill on what changed, and on what is selected, erroring, focused or urgent. In a product register every accent traces to a fact — a status, a threshold, an actor, a deadline — and an accent added because a region looked plain traces to nothing. A deactivated row recedes. A selected default still needs its selection cue. Quiet is not invisible: contrast, visible focus, real labels and usable targets survive every reduction. Quiet is a contrast strategy, not a color budget. A surface carrying twenty real facts carries twenty encodings, each in the form Law 10 gives it. What recedes is the routine and the unchanged, never the informative.

10. Recognition beats reading.
    A red octagon is a stop sign before you read a word. Differentiation shrinks the read; recognition removes it. Encoding is the standing first move, not a permission granted after the prose is written: a fact with a visual form the audience already owns takes that form, and prose is the fallback. Showing outruns telling, so the trade runs by kind: a face for a person, a chip for a category, a diagram for a relationship, a trend line for a direction, underlined color for a link. The version carrying less raw information often lands first, because what survives registers on sight instead of waiting to be read. A chip pays twice: it reads instantly, and it lifts a control out of the menu that hid it. Ownership is the test, not the brake — a symbol the audience does not already hold explains nothing, and an icon the user has to decode is worse than the word it replaced. Placement can name a control where an icon cannot: a checkbox set apart above an action bar says what it governs. A tooltip may name one on approach, but a tooltip carrying the only meaning of a primary action is a label you refused to write. The instinct when something is unclear is to explain it harder, and a comparison, a label or a tooltip each feels productive because each is technically more information. Never make a screen harder to scan in order to make it easier to understand. Show what is interactive at rest, and never let a fact look like a button. Never carry meaning in color alone.

11. Color is pulled, not generated.
    A palette comes out of a real artifact of the audience's world, never out of a generator: earthy tones come out of the photographs themselves. Accents are traced and chosen, not sprinkled. Color is a channel with capacity: a closed set of six categories earns six hues drawn from one family, and the constraint is traceability and family, not scarcity. In a product register the color comes from the data, and an icon in an activity chip is red because the action is urgent — Law 9 already sets the trace back to a fact. A neutral ramp tinted toward the accent belongs to one family; pure gray belongs to nothing. Contrast is a floor that survives texture, so noise laid over a photograph buys the text its contrast. Dark is not an inverted light theme, and a sterile light mode and a flat dark mode are the two failures. Background carries the register per section: cream with no noise reads as clean software, dark with heavy noise reads as moody. Law 10 already bars meaning carried in color alone.

## Act IV — The hidden layer

12. Half the product is off the rest state.
    What you can see is the smaller half. A dense table works because of what is not shown yet: the copy affordance on a cell, the comment marker, the row menu, the drawer, the confirmation, and the loading, empty, error, long, translated and deactivated version of every region. Inventory that layer and it rivals the visible one. Skip it and the rest state looks finished while the product is not — the difference between a screen that photographs well and one that survives use. Every hidden piece is a region: its own spine, its own two contacts, its own single dominant action.

13. Disclosure has a ladder.
    Rank each action by how often it is used and what it costs to miss. Put it on the lowest rung that still reaches its user: the rest state, then approach through hover or focus, then a gesture, then a popover or drawer, then a page. Frequent sits high. Rare and cheap sits low. Destructive never sits so low that it is found by accident. Whatever the rung, a reveal opens on its own primary action — a share popover opens with the search field, not with a list of people. First-run is the same ladder in time: point at one action, wait for it, then offer the next. A modal that explains the whole product is forgotten the moment it is dismissed. This is sequencing, not hiding.

## Act V — Craft

14. Geometry is inherited.
    One spacing scale, one type scale, one radius logic, one icon weight and scale, one color logic, one texture. Peers in the same context share their values, and any difference has to mean something. Compare neighbors directly: a taller primary beside a shorter secondary, mismatched insets down repeated rows, one filled icon among outlines. Emphasis between sibling controls belongs in weight and color, not in height. For concentric shapes, inner radius equals outer radius minus the inset, or the inner corner bulges. A value that repeats belongs in the scale. A decision the product already made is the default for the next screen, and a second answer to a solved question is a defect, not a variation.

15. Type is a system, not a font.
    One family carries a surface, and a second earns its place only by doing a job the first cannot. The scale is a short ratio with few steps, and each step has a job, which Law 14 already rules as one scale. Hierarchy is size, weight and color together, never size alone, and Law 8 already puts emphasis in the difference from neighbors. A line of text is capped at a reading measure, which is Law 3 at sentence scale. Line height falls as size rises, and tracking tightens as size rises. Numbers a user compares take figures that line up by place value, which Law 1 already hangs on the end edge. Wrapping is composed: a heading breaks where the meaning breaks, and no line is left orphaned. Enlarged text and user font size are widths, per Law 21.

16. Material gives depth a reason.
    Law 4 already removes the containers that were scaffolding, and this Law governs the ones that survive. An enclosure that survives states its material once: one elevation ladder, where height means how far a surface sits from the task, from resting to raised to floating to overlay. A shadow is a light source, and one light source lights a surface, so every shadow on it falls the same way. Tone separates before a line does, and a line before a shadow, which is Law 5's escalation and not a second one. Semi-transparency needs something behind it worth seeing, and text over it keeps the contrast floor Law 11 sets. A dark surface rises by lightness where a light surface rises by shadow, and Law 11 already bars the inverted theme. Depth is ordered, never random, which is Law 22's layering.

17. Icons are a family, not a pile.
    Icons and chips do the reading, which is how a surface stays clean while still saying everything: meaning sits in the glyph, the face and the tag rather than in another sentence. On a dense surface a leading icon on a repeated row and a chip on a closed-set value are the expected form, not an embellishment, and their absence is what needs the argument. That only holds while they read as one family — one weight, one grid, one optical size, where a difference between peers has to mean something. An icon replaces a word only when the audience already owns the symbol, which is Law 10's test and not a second one. Icons drawn from the brand's own material come to stand for the product's features. Size is tied to the text an icon sits with, and a bigger icon is never how emphasis is added, since Law 8 puts that difference in the neighbors. An enlarged icon owes its neighbors the edge back, per Law 2. Optical alignment is Law 22's. A semantic icon carries an accessible name; a decorative one is hidden from assistive technology. An icon alone in an action bar is guesswork, where placement can name the control instead, as Law 10 shows.

18. Identity is worn, not applied.
    Skeleton and identity are separate layers. Lock the message, the regions and their order first. Dress them second. A skeleton that holds up in only one skin was leaning on decoration. An identity that lifts onto a competitor unchanged is not an identity. Take the material from the audience's world — the objects, surfaces, light and type these users already live with — and pull the texture and imagery from a real artifact of it rather than from a generator, as Law 11 pulls the palette and Law 17 the icons. Naming the audience in the copy while showing nothing they would recognize is the loudest tell there is. On a brand surface one actionable heading promises the outcome; the name of the category promises nothing.

19. Motion carries the eye.
    Motion is identity: a few themes, repeated, or it is a trick. Its job is to hand the focal point from one region to the next. Where two regions meet with a hard break, let the outgoing one recede as the incoming one arrives over it, then reverse the move at the far end so the surface has bookends instead of seams. What enters decelerates and what leaves accelerates, and a move between two resting states eases both ends. Duration follows distance and size, and the band ends before anyone waits, because motion reports a state change rather than performing one. Movement rides the properties that cost no layout, so the surface never reflows to animate. A reveal grows from the thing that opened it, so the origin governs the transform, and Law 13 already rules what a reveal opens on. Movement that points at nothing competes with the one thing you raised. Motion the user cannot interrupt is a lock. What a gesture drives follows the hand, and what a clock drives follows a curve. A timed rotation is the last resort for items that all matter: it pauses on approach, stays operable without waiting, and never holds the only path to a task. Never animate what is being read. Honor reduced motion by removing the movement, not the meaning.

## Act VI — The surface

20. A section is assembled in order.
    Background first, then texture, then type, then spacing, then the assets, then the edge treatment. Each step settles before the next one starts. Scatter is ordered, not random, in the depth Law 22 sets, and the edge treatment recedes the frame so the center becomes the subject, which is Law 8 at section scale. One focal point per section, chosen before anything is placed, since a section that earns its beat was composed toward a subject rather than filled. Sections alternate register so each reads as its own beat, while the repeated assembly keeps them one page. Borrow section skeletons, not screens: take the pattern that already solves the beat, note the one change it needs, assemble them, then strip everything back to the wireframe, which is the half of the process Build step 3 carries.

21. A breakpoint comes from the content.
    A breakpoint sits where a region actually breaks, never at the name of a device. A region reflows on its own width, so a container query beats a viewport query, and this is Law 3 at responsive scale. Reading width stays capped and columns collapse in reading order. DOM order, reading order and keyboard order stay the same at every width. A vessel changes rather than scrolls, so a table that no longer fits becomes a stacked list, which is Law 1 taking the vessel from the content. Content is never hidden merely to make it fit, and Law 2 has already ruled that collapsing into a menu is not a repair. On touch there is no hover, so an action sitting on the approach rung needs a different rung on a touch surface, per Law 13. Targets stay large enough for a thumb and sit within its reach. Sticky bars, safe areas and the keyboard inset are states, not decoration, and Law 12 counts them in. Enlarged text and 200% zoom are widths too.

22. The eye overrules the ruler.
    Measurements start the work. Perception finishes it. Space is measured from the ink, not the box: a large heading already carries space under its baseline, so the gap below the pair has to grow — often to about twice the gap inside it — before it reads as separation. Optical mass decides what looks centered, not the bounding box: a triangle in a circle, a glyph in a square, a round shape beside flat neighbors. Align icons by visible shape. Layering is ordered, never random — larger and quieter masses behind and below, smaller and sharper ones in front, every layer clear of the text. Repair accidental near-alignments, because a near-miss reads as a mistake where a full offset reads as intent. Confirm by looking at the rendered result, never by trusting the numbers.

## Working the laws

Build

1. Name the question the user arrives with and the action that follows. On a brand surface the heading promises that answer, and everything else supports it.
2. Lay out the task before the controls. Derive regions, reading widths, spines, vessels and breakpoints from the content, not from a grid picked in advance, and put each breakpoint where the content actually breaks.
3. Borrow skeletons, not screens. Take the section pattern that already solves each beat of the message, note the one change it needs, assemble them, then delete everything but the wireframe.
4. Dress the skeleton once it holds. Draw the identity from the audience's world, pull the palette from a real artifact of it, then fix the scales once: spacing, type, radius, one icon family, color, texture, motion, and the register each section carries. Decide every axis — hug, fill or fix — and reuse widths across peers.
5. Place content on edges. Manufacture the edges that are missing. Only then reach past space for a cue. Every element answers the gate as it lands.
6. Mute the routine and the unchanged, encode every fact that has a form the audience owns, then raise the one thing the user came for.
7. List the hidden layer before you build it: every state the data can produce and every action off the rest state, each on its rung. Build it, then walk all of it back through the laws and the gate.

Review

1. Restate the surface, the task and the evidence in hand.
2. Squint. The regions should survive. If they blur into one field, Act II failed.
3. Trace the path to the named answer, first run included, and count the stops. Each stop is a finding.
4. Run the gate over every element in scope. Name what each one does for the hunt. An element that cannot answer is a finding.
5. Test Acts I, V and VI against peers in the same context and state, never against isolated components.
6. Inventory the hidden layer against what exists. A state nobody designed is a finding, and so is a frequent action stranded on a low rung.
7. Exercise narrow, middle and wide widths, and every container width Law 21 names; long, empty and translated content; enlarged text and 200% zoom; loading, empty, error, focus, hover, selected, disabled, disclosure, tooltip, first-run and announcement; every theme and reading direction; keyboard order, pointer use, touch use and reduced motion.
8. Swap the identity in description: this skeleton in another skin, this skin on a competitor's skeleton. A layout that collapses was decoration. A skin that changes nothing was never an identity.
9. Fix a shared cause at its owner and a local defect locally, then re-review what changed.

## Resources

Open tools, specs, palettes and checkers, grouped by Law: `references/tools.md`. It holds what a Law needs as an artifact and nothing that decides one — a palette, an icon family, a scale, a spec, a rendered proof. Every entry carries its licence, and the ones that are not open source say so.

Type scales, families, measures and figure settings, for Laws 14 and 15: `references/typography.md`.

Durations, easing curves, distances and reduced-motion handling, for Law 19: `references/motion.md`.

Elevation ladders, shadow recipes, tone steps and transparency, for Laws 4 and 16: `references/material.md`.

State inventories, disclosure rungs, breakpoints and target sizes, for Laws 12, 13 and 21: `references/states.md`.

The catalogue of what visual form each kind of fact takes and when that form fails, for the gate and Laws 6, 10 and 17: `references/encodings.md`.

Hue sets and capacity, status semantics, chip construction, neutral ramp, link color, chart series and dark surfaces, for Laws 9 and 11: `references/color.md`.

The anatomy of a dense product surface, including the key-value row, for Laws 1, 5 and 20: `references/composition.md`.

When the surface is built on shadcn/ui and Tailwind CSS v4: every catalogue entry sorted by how well it carries the Laws, each skeleton built from named parts, and the tokens, variants and utilities that make the scales real, for the gate and Laws 4, 13, 14, 17 and 21: `references/shadcn-tailwind.md`.

## Findings

Visible claims need rendered evidence. A source-only claim is a prediction and must say so. A still image cannot prove hover, disclosure, motion, keyboard or pointer behavior. Missing evidence stays unverified, and agreement between reviewers never turns a prediction into an observation.

Four lines per finding:

1. Where — region and object, with conditions and the mismatched values.
2. Law — number, and the principle it breaks. A gate finding names the gate and the question it could not answer.
3. Failure — the named failure and its cost to the scan.
4. Fix — the smallest concrete change, and how to confirm it. Removal is often that change.

Rank task blockers first, repeated scan cost second, polish last. Merge findings that share a cause. Name an exception when the task or the design system justifies it. Taste is not a defect.

## Failure names

Gate — Unjustified element: nothing it does that the hunt needs. Stock component: a component chosen because the library ships it. Decorative fill: an element placed to occupy space. Premature removal: a needed fact cut where an encoding was the repair.
Law 1 — No spine: nothing to align to. Second spine: competing edges. Ceremonial body: centered text you must compare. Wrong vessel: the form ignores the content.
Law 2 — Island: one contact. Ghost edge: an edge nothing else uses.
Law 3 — Stretched stack: alignment without association. Crowded cell: one long value steals its siblings' edges.
Law 4 — Box in a box: a redundant boundary. Detour: a secondary unit given a page.
Law 5 — Monotone gap: equal gaps, no groups. Cue pileup: three cues, one group. Split allegiance: cues disagree. Orphan inset: siblings spaced twice.
Law 6 — Uniform wall: density with no landmark. Confetti: a marking cue fired on every row, differentiating nothing. Raw enum: a closed set left as text.
Law 7 — Idle void: space with no role. Decorated hole: filler hiding one.
Law 8 — Two primaries: one decision, two actions. Flat field: nothing dominates, loud or quiet.
Law 9 — Loud default: a routine state dressed as a change. Silent change: a change dressed as a default. Untraced color: an accent no fact drives. Budgeted quiet: an informative fact muted to keep the surface grey.
Law 10 — Told not shown: prose where a visual the audience already owns would register on sight. Guesswork: meaning only after decoding. Unlabeled: no name at rest or on approach. Costume: appearance misstates behavior. Overexplained: scanning costs more than the explanation saves. Redundant label: a name for what the UI already says.
Law 11 — Generated palette: color with no source in the audience's world. Sprinkled accent: color spent where nothing changed. Dead gray: a neutral ramp that belongs to no family. Washed text: contrast lost to the texture beneath it. Inverted theme: a dark theme built by flipping a light one. Starved channel: a closed set squeezed into fewer hues than it has categories.
Law 12 — Hollow rest: a finished rest state over an undesigned layer. Undesigned state: the data produces it, the design does not. Improvised layer: hidden pieces invented one at a time.
Law 13 — Overexposed: a rare action at rest. Buried: a frequent action in a menu. Trapdoor: a destructive action found by accident. Headless reveal: a popover with no primary action. Modal dump: the whole product at once.
Law 14 — Radius stack: nested corners, no shared arc. Size drift: unequal neighbors. Off-scale: a value off the scale. Peer drift: repeated components, different insets. Icon drift: mixed fill or scale. Second answer: a question the product already solved, answered differently.
Law 15 — Second family: a face with no job the first cannot do. Size-only rank: hierarchy carried by size alone. Runaway line: text past its measure. Ragged figures: compared numbers that do not line up by place value.
Law 16 — Sourceless shadow: a shadow with no light source. Flat ladder: two heights, one treatment. Empty glass: transparency with nothing behind it. Lost floor: text that drops its contrast over a backdrop.
Law 17 — Mixed family: icons from more than one set. Nameless icon: a semantic icon with no accessible name. Announced decoration: an ornament exposed to assistive technology. Loud glyph: size standing in for emphasis. Bare row: a repeated row on a dense surface with no leading icon.
Law 18 — Miscast: an identity for any audience. Nameless world: the copy names them, nothing shown belongs to them. Formula skin: defaults instead of material. Load-bearing decoration: swap the skin, lose the layout. Category heading: names the class, promises nothing.
Law 19 — One-shot: used once, never as identity. Hard seam: no handoff between regions. Reversed ease: what enters accelerates. Uninterruptible move: motion the user cannot cut short. Motion noise: movement pointing at nothing. Hostage rotation: a timer the user cannot outrun.
Law 20 — Split focus: one section, two subjects. Loose scatter: masses placed with no order. One-note run: sections that never change register. Lifted screen: a whole screen borrowed instead of its skeleton.
Law 21 — Device breakpoint: a width taken from a device, not the content. Viewport reflow: a region reflowed on the surface width instead of its own. Order break: reading order changes with the width. Hover-only action: an action stranded on the approach rung on touch. Squeezed vessel: a vessel scrolled instead of changed.
Law 22 — Near-miss: accidental misalignment. Optical lie: centered by math, off by eye. Boxed gap: measured to the box, not the ink. Depth miss: layers colliding with the reading.

## Verdict

Designed: the checked scope has no observed failure, no unresolved prediction, and no element in scope that could not answer the gate.
Assembled: observed failures remain.
Otherwise withhold clearance and name the missing evidence. No verdict extends past the checked scope.

When scores are requested, score each attribute separately: 0 unusable, 1–3 task blocked, 4–6 substantial friction, 7–9 defects remain, 10 clearance demonstrated in scope. Mark unverified attributes unverified, re-score after fixes, and never raise a score to finish.
