# FinancialiteAPK — Design System (Auth Redesign)

## Design Read
Redesign (targeted, brand-unification) of the Login / Cadastro screens for **FinancialiteAPK**,
a Brazilian personal-finance Flutter mobile app (companion to the "Financialite" Laravel/React
web app). Adopting the web app's dark neumorphic soft-UI auth language — scoped EXCLUSIVELY to
auth screens, mirroring the web codebase's own precedent ("Neumorphic surface used only by the
Login/Register auth screens") — built on tokens the mobile app ALREADY owns (rose dark palette,
SpaceGrotesk money type, Inter UI type), not an invented arbitrary palette. This is a native
mobile screen, not a web landing page: no hover states, tap targets >= 48dp, safe-area aware,
one-hand reachable primary action.

Dials: `DESIGN_VARIANCE: 7` (distinctive soft-UI depth, still legible/trustworthy — this is a
finance app) · `MOTION_INTENSITY: 6` (staggered entrance, spring press feedback, nothing
gratuitous) · `VISUAL_DENSITY: 4` (auth screens are sparse, generous breathing room).

## Product Context
- Personal finance tracker: bank accounts, cards, bills (faturas), budgets, transactions,
  savings goals, income, projections. Portuguese (Brazil) copy throughout.
- Platform: Flutter (Material 3 base, heavily overridden with custom tokens below). Target
  viewport for these screens: mobile portrait, ~390x844 (iPhone-class) and ~360x800 (Android).
- UPDATE (post-launch iteration): the app now ships **dark mode as the default app-wide
  appearance** (not just an auth-only exception) — background/surface/accent tokens below are
  now the WHOLE APP's default look, not scoped to auth. Card shadows were also boosted app-wide
  (bigger blur/offset, "lifted" not flat) and border-hairlines were softened toward "shadow
  defines the edge" rather than a visible stroke. See "Main App Screens" section below for the
  CURRENT brief: reimagining the dashboard's LAYOUT/COMPOSITION (not just its color/shadow
  tokens, which are already applied in code).

## Main App Screens — Round 2: Break Away From the Card-Grid Vocabulary

The round-1 dashboard (bento grid of rounded rose tiles + gradient hero card) was judged
"still visibly the same app" despite genuinely different composition -- because the underlying
VOCABULARY didn't change: soft-rounded rectangles, tinted icon badges in rounded squares, a
gradient card for the hero, shadows for depth. That vocabulary itself reads as "generic fintech
app" regardless of how the tiles are arranged. This round is about changing the vocabulary, not
just the arrangement.

Non-negotiable constraints (keep these, everything else is open):
- Same rose/crimson family as the accent (do not invent a brand-new hue), Inter for UI text,
  Space Grotesk for money figures, dark background. This is brand identity, not decoration.
- All the same functional content/information from the earlier brief must still be present.

Everything else is explicitly OPEN to reinvent:
- Do NOT default to "gradient card + rounded rectangle + icon badge + soft shadow" for
  every surface. Consider: no cards at all for some content (numbers directly on the page
  background with a rule/underline); hard/sharp corners instead of soft-rounded; flat solid
  color fills instead of gradients; borders instead of shadows; a completely different
  icon treatment (or no icons at all for some rows); different typographic scale (much
  bigger, more confident numerals; tighter tracking; mixed weight contrast).
- Consider a genuinely different generating idea for the WHOLE screen, not a rearranged
  version of the same idea: e.g. an editorial/ledger-like reading order where the balance is
  the biggest thing on the page with no container at all, or a bold graphic-poster block
  layout with hard edges and flat color fields, or something else entirely -- as long as it
  reads as a deliberate, different design system, not a reshuffled version of round 1.

Two directions to generate as separate branches for the user to compare:

**Branch A - "Editorial Ledger":** Radically reduce chrome. No gradient hero card -- the
balance is a massive number directly on the dark background (SpaceGrotesk, very large, tight
tracking) with a single thin rose rule underneath, no box around it at all. Stats presented as
a simple text list (label + large number, no icon badges, no boxes) separated by hairline
dividers, not tiles. Quick actions as plain text-with-arrow links, not pill buttons. Chart
bleeds edge-to-edge with no card container. This is "confidence through restraint" -- premium
via typography and whitespace, not via decoration.

**Branch B - "Bold Graphic Blocks":** High-contrast poster-like blocks with SHARP corners (no
rounding), flat solid color fills (no gradients, no soft shadows -- use a solid 2px border
instead of a shadow for depth), thick color blocking. Introduce the app's existing "gold"
accent family alongside rose for graphic contrast on secondary blocks (this app's design
system already has a documented gold color scheme -- use its hue family, do not invent a new
color). Stats as large flat-color rectangles in a Swiss-poster-style asymmetric grid. Numbers
in SpaceGrotesk at a bold, oversized, tightly-tracked scale.

## Main App Screens — Dashboard Reimagining Brief (round 1, superseded by round 2 above,
kept for reference on the functional content inventory only)

**Problem being solved:** the color/shadow/shape tokens were already pushed app-wide in code
(dark bg, boosted shadows, softer radii), but the actual LAYOUT of the dashboard is untouched —
still a predictable top-to-bottom stack: hero balance card, then a 2-column stat row, then a
2-column quick-action row, then a boxed line-chart card, then boxed list sections. That's the
"AI-default vertical stack of equal-width cards" pattern the taste skill flags — reskinning it
in dark rose doesn't make it feel reimagined. This brief is about RECOMPOSING the same
information into a genuinely different structure, not just how each element is painted.

**Content inventory to preserve (do not drop any of these, recompose freely):**
1. Month balance (title "Saldo do Mês", signed amount, a "Negativo"/"Positivo" trend badge,
   a small trend sparkline)
2. Four sub-stats under the balance: Receitas, Despesas, Crédito, Débito (each an amount)
3. Bills-due count ("Contas a pagar", a number)
4. Savings total ("Metas", an amount)
5. Two quick actions: "Nova Saída" (expense) and "Nova Entrada" (income)
6. A monthly credit/debit line chart with legend
7. "Próximas Contas" (upcoming bills) — a short list
8. "Gastos por Categoria" (category spending) — a short list/breakdown
9. Top bar: screen title "Visão Geral" + a notification bell (with unread badge)
10. Persistent bottom navigation (5 destinations, already a floating pill nav — keep that
    pattern, it's already good and distinct)

**Directive:** Recompose this into an asymmetric bento-style single scroll, not a stack of
equal-width sectioned cards. Concretely:
- The balance hero and the two quick actions should feel like ONE connected "money moment"
  (e.g. quick actions as inline pill buttons docked into/overlapping the bottom edge of the
  hero card) instead of three separate stacked blocks.
- The four sub-stats (Receitas/Despesas/Crédito/Débito) and the two secondary stats
  (Contas a pagar/Metas) should live in ONE asymmetric bento grid with mixed tile sizes
  (e.g. one wide tile + two narrow tiles, or a 2fr/1fr/1fr split), not two separate uniform
  2-column rows stacked on top of each other.
- The monthly chart should NOT be a plain boxed white/dark card floating alone — integrate it
  more boldly: bleed it closer to full width, or pair it inline with one stat as a combined
  tile, or give it a distinct elevated treatment that reads as the visual anchor of the scroll
  (this is a finance app, the trend line is the second most important thing after the balance).
- "Próximas Contas" and "Gastos por Categoria" can share a row (side-by-side condensed
  previews with "ver todas") instead of two full-width stacked sections, if it fits; if not,
  vary their internal layout from each other (don't make both look like the same list-row
  template).
- Vary corner radius/shape per tile deliberately (some tiles use the asymmetric `cardCut`
  signature shape, at least one uses a fully rounded pill/circle accent) rather than every
  tile being the same uniform rounded-rect.
- Keep ONE accent color family (the rose tokens below) and the boosted shadow language
  already in code. Use ONLY Inter for UI text and Space Grotesk (tabular figures) for every
  money amount shown.

Dials for this brief: `DESIGN_VARIANCE: 8` (bento asymmetry, mixed tile sizes) ·
`MOTION_INTENSITY: 5` (scroll-reveal on sections, no gimmicks) · `VISUAL_DENSITY: 6`
(this is a daily-use finance app home screen, denser than the auth screens, but still with
real breathing room between bento tiles — not a cockpit).

## Main App Color Tokens — dark (now the app-wide default, current code values)
```
--bg:        #0A0404
--surface:   #150707
--accent:    #F43F5E
--primary:   #BE123C  (also the light-mode primary; dark mode's "primary" role reads #FB7185)
--primary-alt: #FB7185
--on-surface: #F4F4F5
--on-surface-var: #A1A1AA
--income:    #34D399   --expense: #F87171   --divider/cardBorder: rgba(69,10,10,0.2) very faint
Card shadow (current, boosted): 0 10px 20px rgba(0,0,0,0.14), 0 -3px 6px rgba(0,0,0,0.06)
  -- soft, "lifted", NOT a hairline border doing the definition work.
Radii in code now: sm=8 md=12 lg=14 xl=18 xxl=24 pill=999. cardCut = one 4px corner + the
  rest at the tile's own radius (reserved for money/data tiles specifically).
```

## Color Tokens — "Rose" scheme, dark mode (the ONLY mode auth screens render in,
regardless of the user's in-app theme preference — matches web's GuestLayout, which is
always dark since a guest has no saved preference yet)

```
--bg:            #0A0404   /* page background */
--surface:       #150707   /* neumorphic card body */
--surface-inset: #100505   /* slightly darker, for carved/inset fields */
--accent:        #F43F5E   /* rose-500, primary CTA gradient start, focus rings */
--primary:       #BE123C   /* rose-700, primary CTA gradient end, hero elements */
--primary-alt:   #FB7185   /* rose-400, used as "primary" text/icon tint in dark mode */
--on-surface:      #F4F4F5
--on-surface-var:  #A1A1AA
--hint:            #71717A
--divider:         rgba(69, 10, 10, 0.5)   /* #450A0A at 50% */
--error:           #F87171
--success:         #34D399
--badge-bg:        #0B0B0B   /* AppLogoMark badge background, brand-neutral near-black */

Neumorphic shadow (outset, raised surfaces — the auth card, the circular Google button):
  6px 6px 14px rgba(0,0,0,0.55), -6px -6px 14px rgba(255,255,255,0.04)
Neumorphic shadow (inset, carved surfaces — text fields):
  inset 4px 4px 8px rgba(0,0,0,0.5), inset -4px -4px 8px rgba(255,255,255,0.03)
Neumorphic press feedback (:active on the circular Google button only):
  inset 3px 3px 7px rgba(0,0,0,0.6), inset -3px -3px 7px rgba(255,255,255,0.03)
Primary CTA shadow (color ONLY appears here, never as an ambient page/card glow):
  0 4px 15px rgba(244,63,94,0.35)
```

Ambient background: two soft blurred circles behind the card, low opacity, one tinted
`--primary` (top-left), one neutral near-black (bottom-right) — subtle depth, not a hero
gradient mesh. `blur ~80px`, opacity 8-10%.

## Typography
- **UI font: Inter** (already the app's font family — do NOT introduce a second sans font).
  Headline (screen title, e.g. "Entrar"): 28-32px / weight 800 / letterSpacing -0.8.
  Subtitle: 15px / weight 500 / on-surface-var.
  Body / labels: 14-15px / weight 500-600.
  Button label: 14-15px / weight 700 / uppercase / letterSpacing 0.5-1px (pill CTA only;
  Google button and text links stay sentence case).
- **Money font: Space Grotesk**, tabular figures — NOT used on auth screens (no money
  figures here), but keep it in the system doc for consistency with the rest of the app.
- No serif anywhere. No second display font. No em-dash anywhere in copy.

## Shape
- Auth card / inputs / Google button: **fully rounded, soft** — radius 28-32px on the card,
  pill (999px) on the primary CTA and the divider-less Google circle, 16px on text fields.
  This is a DELIBERATE, DOCUMENTED split from the app-wide "cardCut" asymmetric-corner shape
  (one tight 4px corner + open corners elsewhere) used on money/data cards elsewhere in the
  app — cardCut is reserved for financial data surfaces; soft-uniform-round is reserved for
  auth. Do not mix the two on one screen.
- Icons: rounded/outlined style (Material rounded icon set equivalent), stroke-based, no
  filled glyphs, consistent 22-24px sizing.

## Components (auth-scoped)

**AppLogoMark** (reuse, do not redesign): a dark `#0B0B0B` rounded-square badge (radius ~16
at 64px size) containing 3 stacked horizontal "ledger" bars in `--primary-alt`, top bar
shortest, bottom bar longest is WRONG — actually all 3 bars are equal width (10/24 of size),
equal height, evenly gapped, centered. Do not invent a different mark.

**Primary CTA button**: full-width capped at ~220-260px, pill shape, gradient
`--accent` -> `--primary` (135deg), white bold uppercase label ("ENTRAR" / "CRIAR CONTA"),
press = scale 0.95, shadow = Primary CTA shadow above. Loading state = white circular
spinner replacing label, same pill.

**Google sign-in button**: circular, 56-64dp, `--surface` fill, neumorphic outset shadow,
press = neumorphic inset shadow (scale unchanged), centered real 4-color Google "G" mark
(blue #4285F4, green #34A853, yellow #FBBC05, red #EA4335) — NEVER a generic letter/icon
substitute. Loading state = spinner in place of the G.

**Text field** (email / password): `--surface-inset` fill, fully rounded (16px), NO visible
border, neumorphic inset shadow as the only depth cue, floating label above the field (small,
`--on-surface-var`, NOT a placeholder-only pattern — always show a real label, placeholder
optional/redundant), focus = 1.5px `--accent` ring replacing the inset shadow's outer edge,
error = red-tinted ring + helper text below in `--error`. Password field has a trailing
eye-toggle icon button (44x44 tap target) in `--hint`, turns `--accent` when password visible.

**Divider row**: hairline `--divider` on both sides of small centered "ou continue com" label
in `--hint`.

**Footer link row**: centered, "Não tem conta? " in `--on-surface-var` + "Cadastre-se" in
`--primary-alt` bold, single tap target combining both (or the bold word is the tap target).

**Back button** (register screen only): 40x40 rounded-square, `white 15% alpha` fill over the
gradient hero, rounded-corner (8-10px) container, back-arrow icon, white.

## Motion
- Screen entrance: staggered fade + rise (translateY 8-16px -> 0, opacity 0 -> 1), ~350-450ms,
  ease-out, sequence: logo -> headline -> Google button -> divider -> fields -> CTA -> footer
  link, ~50-70ms stagger between groups.
- Button press: scale to 0.95-0.97 on press, spring back on release (150-200ms).
- Route transition Login <-> Register: horizontal slide (36px) + slight scale (0.97->1) +
  blur-out/in (6px->0), ~260-420ms — mirrors the web app's existing AnimatePresence transition.
- Respect reduced-motion: entrance becomes instant fade only, no slide/blur.

## What NOT to do
- No AI-purple, no neon glow, no generic Material blue.
- No pure black (#000000) or pure white — use the near-black tokens above and off-white text.
- No placeholder-as-label on inputs.
- No hover states (native mobile, touch only).
- No em-dash anywhere in copy.
- No generic "Continue with Google" button drawn as a rectangle — it is a circle, matching the
  web app's own signature auth pattern.
- Do not invent a new brand mark — reuse AppLogoMark as specified.
