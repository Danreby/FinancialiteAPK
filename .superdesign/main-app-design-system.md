# FinancialiteAPK — Design System (Main App, Light Mode)

## Design Read
Redesign (targeted evolution, not a teardown) of the MAIN APP screens — buttons, form fields,
charts, and the weakest screens (transaction/income forms) — for FinancialiteAPK, a Brazilian
personal-finance Flutter app. Audit finding: the dashboard, list screens (bills, accounts,
goals, transactions) and the "Mais" menu are ALREADY well-crafted (custom cards, curated icon
colors, asymmetric brand shape, grouped lists). The weak spot is FORMS: they fall back to bare
default Material `OutlineInputBorder` text fields, a plain default `Switch`, and — a real defect
— the Débito/Crédito type toggle fills its selected state with the raw semantic "expense" red
(`#DC2626`, Tailwind red-600) PLUS a colored ambient glow shadow, which both clashes with the
rose brand family and violates the app's own documented shadow rule ("color only under the
primary button, never an ambient glow" — that rule is reserved for the ONE brand accent, not
arbitrary semantic colors). Charts (fl_chart line/bar) are functional but generic-Material —
default grid lines, thin flat lines, no fill gradient, generic legend dots.

This is the LIGHT-MODE main app (dashboard/lists/forms), a different scope from the dark
neumorphic auth screens (auth stays exactly as already redesigned — do not touch it, do not
carry neumorphism into this scope). Native mobile screens, not web: no hover, tap targets
>= 48dp.

Dials: `DESIGN_VARIANCE: 6` (this is a daily-use financial tool — legible and calm, but the
asymmetric cardCut shape and confident color use already give it real personality) ·
`MOTION_INTENSITY: 5` (press feedback, smooth toggle transitions, chart entrance animation,
nothing distracting for a numbers-heavy screen) · `VISUAL_DENSITY: 5` ("Daily App" — forms and
lists carry real content, not art-gallery whitespace).

## Color Tokens — "Rose" scheme, LIGHT mode (already defined in app_colors.dart, reuse exactly,
do not invent new hex values)

```
--bg:              #FAFAFA
--surface:         #FFFFFF
--surface-variant: #F1F3F8
--primary:         #BE123C   /* rose-700 */
--primary-light:   #FDA4AF
--primary-dark:    #9F1239
--secondary:       #E11D48
--accent:          #F43F5E   /* rose-500 */
--chip-bg:         #FEF2F2
--on-surface:        #18181B
--on-surface-var:    #52525B
--hint:              #A1A1AA
--divider:           #E5E5E5
--income:            #16A34A
--expense:           #DC2626
--success:           #22C55E
--warning:           #F59E0B
--error:             #EF4444
--info:              #3B82F6
```

Flat neutral card shadow (from AppShadows, reuse): `0 4px 16px rgba(26,29,38,0.05), 0 1px 4px
rgba(26,29,38,0.02)`. Colored shadow (`buttonPrimary`) is RESERVED for the single rose brand CTA
only — never apply a colored glow to a semantic status color (expense/income/warning) at button
scale. A selected semantic-colored control (like the debit/credit toggle) gets a SOFT TINT fill
(color at 12-15% alpha background + full-color icon/text + a 1.5px full-color border), not a
solid color block with a glow — this keeps semantic reds/greens legible without them fighting
the rose brand for visual weight.

## Shape
Reuse `AppRadius.cardCut()` (one 4px tight corner, rest 16px open) for every card-like money
surface — already the convention, keep it. Form fields get a SOFTER, fully-rounded shape (12px
uniform) to read as "input", visually distinct from "card" (cardCut is for containers holding
data, not for the interactive controls inside a form). Buttons: pill (999px) for the single
primary CTA per screen, matching the auth screen's CTA family; secondary/tertiary actions use
12px rounded rectangles, never pill (pill is reserved for the ONE primary action per screen, so
it keeps meaning "this is the main button here").

## Typography
Inter for all UI text (headline 22-28px/800, section label 13px/700, body 14-15px/500, field
label 13px/600 ABOVE the field). Money figures ALWAYS go through `AppMoneyStyle.rich()`
(SpaceGrotesk, tabular figures) — never a raw `TextStyle` for a currency amount, this was the
#1 repeated gap the audit found. No em-dash anywhere.

## Components to (re)design

**Form text field**: white surface, 12px rounded corners, 1px `--divider` border (NOT the bare
Material default outline look), a small icon in `--hint` color OR a DuotoneIconBadge-style
tinted icon slot for fields with strong semantic meaning (e.g. category picker), label ABOVE the
field in `--on-surface-var` 13px/600 (never inside/floating-only), focus = 1.5px `--accent`
border + very subtle accent-tinted background wash (2-3% alpha), error = 1.5px `--error` border
+ helper text below. Character counters (`0/100`) stay but restyled smaller/quieter.

**Segmented type selector** (Débito/Crédito, and similarly "Tipo de renda" elsewhere): two
pill-shaped or 12px-rounded segments side by side. UNSELECTED = `--surface-variant` fill,
`--on-surface-var` text/icon. SELECTED = semantic color (expense red / income green) at 12%
alpha fill + full-color 1.5px border + full-color icon/text (NOT a solid color block, NOT a
glow shadow). This fixes the harsh-red-glow defect while keeping the semantic color meaningful.

**Toggle switch** ("Transação recorrente" etc.): custom-styled to use `--primary`/`--accent`
when on (not default Material grey/blue), track fully rounded, thumb with a subtle shadow.

**Primary button**: pill shape, solid `--primary` (or the rose gradient family used on auth,
reused here for visual continuity across the whole app) fill, white bold text, colored shadow
(`AppShadows.buttonPrimary`) — this is the ONE place per screen the colored glow belongs.

**Category/dropdown picker fields**: same field shell as text fields, chevron-down icon in
`--hint`, selected value shown with its actual DuotoneIconBadge-style icon inline if it has one
(categories already carry icons elsewhere in the app — reuse that, don't show a generic triangle
placeholder glyph).

**Charts** (fl_chart line/bar, e.g. `monthly_line_chart.dart`, `monthly_bar_chart.dart`): line
charts get a soft gradient area-fill under the line (already partially present, make it
consistent), smoother curve (`isCurved: true` with modest curvature, not sharp angles), dot
markers only at hover/selected point rather than every point, gridlines very faint
(`--divider` at low alpha, horizontal only, no vertical gridlines), axis labels in
`--on-surface-var` 11px. Bar charts: `AppRadius.sm`-rounded bar tops, bars in `--income`/
`--expense` (or `--primary`/`--accent` for single-series), no full opaque gridlines.

## Motion
Field focus: border color transition 150ms. Toggle/segmented selection: 200ms color-cross-fade
+ scale-in-place feedback on tap (reuse `PressableScale`, already exists). Chart entrance: bars
grow from baseline / line draws in over ~500ms on first load only (not on every rebuild).

## What NOT to do
- No AI-purple, no neon, no generic Material blue/grey defaults left unstyled.
- No colored ambient glow on anything except the single primary CTA per screen.
- No raw `TextStyle` for money figures — always `AppMoneyStyle`.
- No pill shape on secondary/tertiary buttons.
- Do not touch or reference the dark neumorphic auth screens — separate scope, already done.
- No em-dash anywhere in copy.
