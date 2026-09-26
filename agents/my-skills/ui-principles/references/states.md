# States

Law 12 rules the hidden layer, Law 13 the rung each piece sits on, Law 21 the widths and the targets. This sheet is the inventory those Laws assume: the states a region owes, the data shapes that break it, the widths and inputs and environments that reach it, and the numbers a target and a focus ring have to clear. It is a list of what a review exercises. It ranks nothing, names no failure and settles no Law — `## Working the laws` owns the procedure and the verdict.

## States

- Rest — the surface before anything happens, and the baseline every other state is judged against.
- Hover — gate it behind `@media (hover: hover)`. On touch `:hover` latches after a tap and holds until the user taps elsewhere, so it reads as a stuck selection.
- Focus — programmatic focus on the control. A wrapper lights up through `:focus-within` when the input inside it is the thing focused.
- Focus-visible — the ring the engine shows for keyboard and assistive technology and suppresses for a mouse click. Style `:focus-visible`, never bare `:focus`, and never write `outline: none` without a visible replacement.
- Active — the frame between pointer down and commit. Missing here, a control feels dead on a slow network.
- Selected — carried by `aria-selected` or `aria-checked`. A selected default still needs its selection cue even though Law 9 mutes it.
- Disabled — where contrast collapses first. `disabled` removes the control from the tab order and from copy; a control that must stay reachable uses `aria-disabled` and explains why it cannot act.
- Read-only — the value is present and editing is closed. `readonly` keeps focus, selection and copy where `disabled` takes all three.
- Loading — a skeleton at the region's real size, or a spinner beside the original label. A bare spinner replacing a label leaves assistive technology with no name for what is busy.
- Empty — zero items, with a message and the action that fills it.
- Partial — some of the data arrived and some failed. It belongs to the region, not to the page.
- Error — inline beside the field, with `aria-invalid="true"` and `aria-describedby` pointing at the message. A red border alone carries meaning in colour alone.
- Success — announced through a polite live region. A confirmation carrying the only undo link never expires on a timer.
- Offline — the queued write, the retry and the marker that says the view is not live.
- Stale — data still rendered after its refresh failed. It says how old it is.
- First-run — one pointer at one action, then the next, which is Law 13's ladder running in time.
- Announcement — a banner, a badge or a what's-new. Each is a region with its own spine, and each is dismissible.

Every region owes rest, hover, focus-visible and disabled. What it owes beyond that comes from what it holds:

| Region                                 | States it also owes                                           |
| -------------------------------------- | ------------------------------------------------------------- |
| Collection: table, list, grid          | Empty, one item, many, loading, partial, stale                |
| Form field                             | Active, error, success, read-only, disabled with a reason     |
| Async action: button, form submit      | Active, loading with the label kept, error, success           |
| Overlay: menu, popover, dialog, drawer | Selected, first-run, and the dismissal that returns focus     |
| Chart or map                           | Empty, loading, partial, stale, and the non-visual equivalent |

## Data edges

- Zero items, and the empty state that has to exist for them.
- One item, against a grid or a layout composed around plural content.
- Two items, where a layout that works at one and at many still splits badly.
- Ten times the realistic count, for missing pagination, an unsticking sticky header and a collapse in render time.
- Truncation, where one long cell must lose its tail so its siblings keep their edges, which is Law 3.
- One unbroken string with no wrap opportunity: a 60-character URL, or `Donaudampfschiffahrtsgesellschaft`.
- A very large number, a negative one, a zero and a null, each distinct on screen. Columns that align use `font-variant-numeric: tabular-nums`.
- A missing image, where a broken `src` leaves alt text sitting in a box sized for a picture.
- Mixed-direction text: an LTR product name inside an RTL sentence, and an RTL name inside an LTR one.
- Emoji alone and mixed into a line, for the line-height jump and the truncation that splits a character.

## Widths

320 CSS px is the floor. WCAG 2.2 SC 1.4.10 asks for reflow with vertical scrolling only at a viewport equivalent to 320 CSS px wide, which is 400% zoom on a 1280px viewport. Genuinely two-dimensional content is the exception, and a table, a map or a code block scrolls inside its own container rather than scrolling the page.

Container widths are the real test, because a region reflows on its own width and not the viewport's. Exercise a 320px container, the region squeezed by a flex or grid sibling until `min-content` blows the layout out, a narrow middle width where the vessel has to change, and a very wide one where the measure runs unbounded and the controls stretch. Render each as a fixed container on one page. Resizing the window scenario by scenario observes a different set of regions each time.

200% zoom is SC 1.4.4, and all content and functionality survives it with the page still zoomable. Enlarged system text is the same width in another costume: a larger base font size pushes text past a fixed `height` first, so anything holding text takes `min-height` and grows. A breakpoint declared in `rem` or `em` switches when the text needs it; the same breakpoint in `px` never does.

## Inputs

Keyboard — DOM order, reading order and tab order stay identical at every width, and a positive `tabindex` is what breaks that match. A composite widget such as a tab list, a menu, a toolbar or a radio group occupies one tab stop and moves inside itself with arrow keys. Escape dismisses whatever opened last. A dialog traps focus, marks the background `inert`, and returns focus to the trigger on close. Tab through a long page and every stop is visible and reachable; a stop that disappears behind a sticky header is a trap with extra steps.

Pointer — anything that looks clickable is clickable across its whole visible extent, with no dead zone between a checkbox and its label. A decorative layer painted over a control absorbs every pointer event its box covers, so a gradient, a glow or a full-bleed pseudo-element takes `pointer-events: none`.

Touch — there is no hover. An action that only appears on approach is unreachable, so it needs another rung on a touch surface. `touch-action: manipulation` removes the double-tap zoom delay on interactive elements. A surface running its own pan, zoom or drag scopes `touch-action: none` to itself and never to the page.

Screen reader — every control has an accessible name, every semantic icon has one and every decorative one is hidden. A client-side route change announces nothing on its own, so the title updates and focus moves into the new view.

Voice control — a user says the visible label. Where the accessible name does not start with the visible text, the spoken command reaches nothing, so an `aria-label` that renames a visibly labelled button breaks the control it was meant to help.

## Environment

- Light and dark, each designed rather than inverted.
- `forced-colors: active`, where authored colours, background images and backdrop filters are dropped and only system colours remain.
- `prefers-contrast: more`, where the foreground and background gap widens by a real, remeasured amount rather than by eye.
- `prefers-reduced-motion`, exercised as a row: every animated region rendered under the preference, checked for feedback that vanished with the movement. Another sheet owns what the implementation looks like.
- `prefers-reduced-transparency`, where every translucent surface goes opaque and still separates.
- Locale, including a translation that runs 30% longer than the English and one that runs shorter.
- Number and date format, where the grouping and decimal separators swap and the date order changes. Format through `Intl`, never by concatenating parts.
- Reading direction, where the whole layout mirrors. Logical properties carry it; physical `left` and `right` do not.

## Floors

- 24 by 24 CSS px — WCAG 2.2 SC 2.5.8, Level AA, the hard floor for a pointer target.
- 44 by 44 CSS px — SC 2.5.5, Level AAA, and the practical size for a primary touch control.
- 44 by 44 pt — the iOS and iPadOS default. 28 by 28 pt on macOS.
- 48 by 48 dp — the Android minimum.
- Spacing exception — an undersized target still passes SC 2.5.8 when a 24px circle centred on it intersects no other target and no other such circle. In the plain case, 20px targets need 4px of gap.

The visible element stays small; the hit area is what grows. Expand it with a pseudo-element on the wrapping `<label>` or `<button>`, never on the `<input>`, since a replaced element does not render `::before` or `::after` reliably. Where the box can simply be bigger, `min-width` and `min-height` with `place-items: center` hands the engine real geometry. Overlapping hit areas send a tap to whichever element paints on top, so an expanded area that collides shrinks to the largest size that does not.

A focus indicator is checked around its whole perimeter, against every colour it crosses: the component fill, the page surface, an image, a gradient, and the hover and selected states underneath it. The browser's own ring adapts to the platform and to forced colours, so adding only `outline-offset: 2px` keeps that adaptation. A custom ring in `currentColor` has been checked against nothing.

A platform minimum and a WCAG criterion are separate floors, and the higher one governs. None of these rows is proved by a still image: hover, focus, disclosure, keyboard order and pointer behaviour each need the interaction actually run, and a row nobody ran stays a prediction.
