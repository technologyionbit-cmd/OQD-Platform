# Aqd — Frontend Design Recommendations

Companion to `COMPLETE_APPLICATION_AUDIT.md` (issues FE-03 … FE-09). Status: **proposal, nothing implemented.**

**Basis and limits.** This is derived from the design tokens, shared widgets, router and screen source code, and one committed (stale) screenshot. Screens were not rendered in this audit, so every screen note below must be checked on a device/emulator in light, dark, Arabic RTL and a tablet width before being treated as final. Quality references (Linear, Stripe, Vercel, mature enterprise SaaS) inform restraint and hierarchy only; nothing is copied.

---

## 1. Starting point: what to keep

The app already has a recognisable identity and a disciplined token layer. Keep:

- **Navy** `#12294F` (`AppColors.navy`) as the brand surface (splash, auth header, lawyer header) and the **logo mark** (white gavel on navy rounded square).
- **Action blue** `#0078C0` (`AppColors.primary`) for every interactive element. It passes AA with white text (≈ 4.7:1).
- Token architecture: `AppColors`, `AppSpacing` (4-pt scale), `AppRadii`, `AppStatusColors`, `AppTypography`; the rule "no literal colors in widgets" (currently **0 violations**).
- RTL-safe layout habits (no left/right literals anywhere) and ARB localisation.
- The "coming soon" tagging pattern on the Account screen.

## 2. What to change, and why

| Observed (source) | Problem for a premium, credible product | Direction |
|---|---|---|
| `purpleAccent #7C4DFF`, `violet #6A3FBF`, `violetLight`, `cyanAccent #00A9C0` | Purple/cyan accents read as generic "AI app", unrelated to the navy/blue brand | Retire; map to brand neutrals + blue |
| 15 gradient usages: client-home service tiles (navy→steel, blue→cyan, violet→violet-light, gold→amber), headers, earnings, account | Decoration that does not carry information; four different hues side by side | Flat navy header (keep one subtle navy gradient at most); tiles become flat surface rows with an icon |
| Every block is a bordered `Card` with the same 12 px radius | Visual monotony, weak hierarchy | Group related rows into one container with dividers; reserve cards for independently actionable objects |
| Single platform font, fixed 1.4 line height | Inconsistent Arabic across devices; Arabic needs more leading | Bundle one family with Arabic + Latin |
| Spinner-only loading | Feels unfinished on lists | Skeleton rows |
| Dark theme borrows light constants | Low-contrast dark mode | Derive all from `ColorScheme` |
| Large (24–32 px) hero headings on some auth/onboarding pages (per `AppTypography` display sizes) | Oversized relative to data-dense app screens | Cap in-app headings at 20–22 px |

---

## 3. Colour system

Principle: **one hue (blue) for action, one deep navy for brand surfaces, neutrals for everything else, semantic colours only for status.** Gold is retained solely for ratings and "pro" markers.

### 3.1 Light theme tokens

| Role | Token | Value | Notes |
|---|---|---|---|
| Brand surface | `navy` | `#12294F` | headers, nav selected backgrounds on dark surfaces |
| Brand surface deep | `navyDeep` | `#0C1830` | only for splash/auth top band |
| Action | `primary` | `#0078C0` | buttons, links, focus, selected |
| Action pressed | `primaryPressed` | `#005E96` | |
| Action tint | `primarySubtle` | `#E7F2FA` | selected rows, info chips |
| Canvas | `background` | `#F7F8FA` | page background (existing) |
| Surface | `surface` | `#FFFFFF` | |
| Surface muted | `surfaceMuted` | `#F1F3F6` | inputs disabled, table headers (existing `#EEF1F4` is close; unify) |
| Border | `border` | `#E1E4E8` | 1 px hairline (existing) |
| Border strong | `borderStrong` | `#C9CED6` | inputs on focus-less hover, dividers in dense tables |
| Text primary | `textPrimary` | `#0F1B2B` | ≥ 15:1 on surface |
| Text secondary | `textSecondary` | `#5B6472` | darker than current `#6B7280` for comfortable AA on `#F1F3F6` |
| Text disabled | `textDisabled` | `#8A919B` | **replace `#A1A7AE` (≈ 2.4:1)**; disabled controls should use a muted *fill* plus normal-contrast label |
| Success | `success` / bg | `#188C4E` / `#E6F5EC` | |
| Warning | `warning` / bg | `#A86F00` / `#FBF1DC` | darker than current gold for text AA |
| Error | `error` / bg | `#C73A3A` / `#FBE7E7` | |
| Rating star | `rating` | `#C98A0E` | icon only, never text |

Removed: `purpleAccent`, `violet`, `violetLight`, `cyanAccent`, `amberLight`, and the saturated pastel status backgrounds (`#C8F0D4`, `#FCF0C0`, `#FCD8D8`) in favour of the lighter backgrounds above.

All values above are proposals; verify final contrast with a checker after choosing values, and keep `AppStatusColors` as the single place for status pairs.

### 3.2 Dark theme
Derive, do not duplicate: `background #0C1420`, `surface #152238`, `surfaceMuted #1B2A44`, `border #263650`, `text #F2F3F4`, `textSecondary #9AA1A9`. Borders, disabled fills, nav colours, input outlines all come from `ColorScheme` / `AppStatusColors` — remove the literal `AppColors.border` references in `app_theme.dart`. Wire the stored `themeMode` preference (System / Light / Dark) into `MaterialApp.router`.

### 3.3 Gradients
One allowed gradient: the navy header (`navyDeep → navy`, top-left to bottom-right), on splash/auth only. No gradients on content tiles, buttons, or badges.

---

## 4. Typography

**Recommendation:** bundle **IBM Plex Sans Arabic** (covers Arabic and a matching Latin) as the single app family. Alternative: Noto Sans Arabic + Inter. Pick one, bundle as assets (not runtime download), and load only weights 400/500/600.

| Style | Size / Line height | Weight | Use |
|---|---|---|---|
| `display` | 28 / 36 | 600 | splash/onboarding only |
| `title-lg` | 22 / 30 | 600 | screen title (large app bars) |
| `title` | 18 / 26 | 600 | section headings |
| `subtitle` | 16 / 24 | 500 | list-item titles |
| `body` | 15 / 24 | 400 | default text |
| `body-sm` | 13 / 20 | 400 | secondary text |
| `label` | 13 / 16 | 500 | buttons, chips, form labels |
| `caption` | 12 / 16 | 400 | metadata, timestamps |

Arabic needs ~0.1 more line-height than Latin at the same size; set per-locale `height` in `AppTypography.textTheme(locale)`. Never use letter-spacing on Arabic. Use tabular figures for prices and dates. Respect user font scale up to 1.3× and test layouts at that scale (see §8).

Current scale to retire: `displayLarge 36`, `displayMedium 32`, `displaySmall 28` (too large for in-app use).

---

## 5. Spacing, radii, elevation

- **Spacing:** keep the existing 4-pt scale (`xxs 4, xs 8, sm 12, md 16, lg 20, xl 24, xxl 32, xxxl 48`). Standard screen gutter 16; section gap 24; related-row gap 8–12. Ban literal paddings in screens (currently 0 literal-number `EdgeInsets` calls — keep it that way).
- **Radii:** reduce the vocabulary: `sm 6` (chips, tags), `md 10` (inputs, buttons, cards), `lg 16` (bottom sheets, dialogs). Drop the 24 px radius from content; pills only for status chips and the OTP boxes.
- **Elevation:** none on cards (1 px border only). One shadow token for floating layers (bottom sheet, dialog, menu): `0 8 24 rgba(12,24,48,0.12)`. The codebase currently has a single `BoxShadow` — keep it that way.
- **Borders:** 1 px `border`; use `borderStrong` only to signal interactivity or focus; avoid border + shadow together.

---

## 6. Component standards

| Component | Standard |
|---|---|
| **Primary button** | 48 px high (52 today is heavy on small phones), radius 10, `primary` fill, white 15/16 label 600; loading = inline spinner, label retained; disabled = `surfaceMuted` fill + `textDisabled` label (not a dark grey block) |
| **Secondary** | 1 px `primary` outline, transparent fill |
| **Tertiary** | text button, `primary` |
| **Destructive** | `error` fill only in confirmation dialogs; elsewhere outlined `error` |
| **Text field** | label above (not floating), 48 px, radius 10, 1 px `border`, focus 2 px `primary`, error text 13 px below with icon; phone field shows `+962` prefix and LTR digits inside RTL |
| **List row** | 56–72 px, leading icon in a 36 px tinted square (`primarySubtle`), title 16/500, subtitle 13 `textSecondary`, trailing chevron mirrored in RTL; rows grouped in one container with 1 px dividers |
| **Card** | only for independent objects (lawyer, consultation, contract); padding 16; no nested cards |
| **Status badge** | text + tinted background from `AppStatusColors`, radius 6, 12/16 caption weight 500, never colour alone (always a label) |
| **Section header** | 13/500 `textSecondary` uppercase-free in Arabic, optional trailing "See all" |
| **Bottom nav / rail** | selected = `primary` icon + label + 2 px indicator bar; unselected `textSecondary`; rail ≥ 700 px |
| **Dialog / sheet** | radius 16; title 18; actions right/left per directionality; destructive action never the default |
| **Empty state** | line icon 40 px (not filled blobs), one-sentence explanation, one primary action |
| **Error state** | inline retry with localised message (existing `ErrorView`), keep cached content visible when refresh fails |
| **Loading** | skeleton rows matching the final layout (list row, lawyer card, contract card); button-level spinners for actions; no full-screen spinners except splash |
| **Icons** | one outlined set (Material Symbols Rounded outlined at 24 px, weight 400); no mixed filled/outlined unless indicating selection |
| **Toast/snackbar** | single-line, bottom, 4 s, with Undo where destructive |

---

## 7. Screen-by-screen recommendations

Based on source structure; confirm visually first.

| Area | Screen(s) | Recommendation |
|---|---|---|
| **Splash / onboarding** | `splash_screen`, `onboarding_screen` (247 lines) | Navy field with logo only; onboarding as 3 plain pages with a 22 px title and one sentence, no gradient illustrations; "Skip" top-end |
| **Auth** | login, register (421 lines), OTP, forgot/reset, verify phone | Replace the navy gradient header band with a compact logo + title on `background`; keep the navy only on splash. Register: group into 2–3 labelled sections or a stepper (`StepIndicator` exists) instead of one long form; show password rules inline as a checklist; OTP boxes with auto-advance and a visible resend timer; phone verification banner becomes a slim inline notice |
| **Client home** (519 lines) | greeting, search, service grid, vault banner, activity feed, recommended lawyers | Largest redesign candidate. Remove the four gradient tiles: use a 2×2 grid of flat white tiles (icon in `primarySubtle` square, title, one-line description). Remove the "digital vault" marketing banner until documents are real (FE-01). Put "Upcoming consultation" first when one exists. Cap hero greeting at `title-lg` |
| **AI tab** | `ai_chat_screen` (647), analysis select/result | Hide in release until real (FE-01). When real: clause-by-clause results as a flat list with risk badges rather than coloured cards; always show a persistent "informational, not legal advice" notice |
| **Documents** | `documents_screen` | Hide until real; then a table-like list (name, type, date) with filter chips |
| **Lawyers** | list (235), details (277), `LawyerCard` | Replace the round avatar badge with real photo/initials avatar; show price-from, specialties (max 2 + "+n"), rating with count; filter as a bottom sheet with an active-filter count (exists); details page: sticky "Book" bar, tabs or sections for About / Reviews / Pricing; skeletons for the list |
| **Booking** | type → date/time → details | Use a single stepper with a persistent summary (lawyer, type, price); time slots as a grid of 44 px chips, disabled slots shown struck/greyed with a legend; clear timezone statement |
| **Consultations** | list, details (333) | Group by Upcoming / Past; status badge per item; details page = summary header + timeline + primary action (Join / Cancel / Review) with Join enabled only inside the allowed window (ties to BIZ-01/06) |
| **Waiting / call rooms** | waiting (385), voice (600), video (774) | Consolidate voice/video into one shell with a shared control bar; dark neutral background (not navy gradient); large tap targets (56 px) for mute/camera/end; connection-quality indicator as text + icon |
| **Chat** | `chat_room_screen` (712) | Hide the fabricated replies (FE-01). Message bubbles: sender `primarySubtle`, receiver `surfaceMuted`, 12 px radius with one squared corner, timestamps 12 px; attachments as file rows |
| **Contracts** (28 files) | list, type, form, preview (235), details (224), signature sheet | Template picker as a searchable list with category headers; form screens grouped by section with a progress indicator; preview in a paper-style white page on `surfaceMuted` with serif-free body at 15/26; signature sheet with clear "what you are signing" summary and content hash reference (ties to BIZ-05) |
| **Gov procedures** | hub (169), detail (211) | Checklist with progress ring replaced by a linear progress bar + "3 of 7 steps"; steps as numbered rows (the numbered circle exists) |
| **Notifications** | list (12 files) | Group by day; unread = 6 px `primary` dot, not a tinted row; swipe to delete with undo |
| **Lawyer dashboard** | dashboard (419), schedule (235), requests, clients, earnings | Replace the gradient header with navy flat; KPI row as 3 compact numbers (no cards); requests list with inline Accept/Decline; schedule as a day list with slot chips; earnings chart only when real data exists |
| **Account** | account (337), security & privacy (286), saved signature, payment methods | Single grouped list with section labels; keep the "coming soon" tags; header = avatar initials + name + verified-phone indicator; sessions list with device label, last used, "Sign out" per row |
| **Company** | home (212), team list (180) | Hidden until backend exists (MISS-01); when built, a table on ≥ 700 px, list on phones |
| **Billing** | plans (364), payment panel (286) | Keep out of release until phase 7; plan comparison as a simple 3-column table, highlight current plan with a border, not a gradient |

---

## 8. Responsive, RTL and accessibility rules

- **Breakpoints:** keep `small ≤ 360`, `standard ≤ 430`, `large`, `tablet ≥ 700`. Add a content `maxWidth` of 640 px for forms/detail pages and 960 px for list-detail layouts; centre on wider screens. Two-pane (list | detail) for lawyers, consultations, contracts at ≥ 900 px.
- **RTL:** continue to use only `Directionality`-aware APIs (`EdgeInsetsDirectional`, `AlignmentDirectional`). Mirror chevrons and back arrows; **do not mirror** phone numbers, currency amounts, logos, media controls, or the OTP digit order. Render numerals consistently (decide Western vs Arabic-Indic digits once, app-wide).
- **Touch targets:** ≥ 48×48 dp, 8 dp apart.
- **Contrast:** AA (4.5:1 body, 3:1 large text and UI glyphs); verify final palette with a tool.
- **Semantics:** label every icon-only button; announce loading and error transitions; group list rows so a screen reader reads title + subtitle + status once; status is never colour-only.
- **Text scale:** support 1.0–1.3×; replace fixed-height rows with min-height; add widget tests at 1.3× for lists, forms, buttons in Arabic.
- **Motion:** 150–200 ms ease-out for state changes; respect "reduce motion".

---

## 9. Implementation plan (design only, no behaviour changes)

Order is chosen so each step is safe to ship alone and keeps the existing 599 tests green.

1. **Tokens (S):** add new colour/typography/radius tokens beside the old ones; migrate `AppTheme` to read from `ColorScheme`; wire theme mode; bundle the font. No screen edits.
2. **Primitives (M):** update `AppButton`, `AppTextField`, `AppCard`, `StatusBadge`, `EmptyState`, add `SkeletonList`/`SkeletonLine`, `GroupedListTile`. Update golden/widget tests that assert styling.
3. **High-visibility screens (M):** auth, client home, lawyer cards/details, lawyer dashboard header — removes gradients and violet/cyan.
4. **Remaining screens (M–L):** bookings, consultations, contracts, account, notifications.
5. **Large-screen layouts (M):** max-width wrappers, two-pane.
6. **Cleanup (S):** delete retired tokens and unused gradients; add a lint/test that fails on `Color(0x…)` outside `core/theme` (currently true by convention only).

**Risks:** widget tests that assert specific colours/sizes will need updating; font bundling adds assets; changing button height from 52 to 48 can shift layouts on small phones — check at 320 px width and 1.3× text scale. Brand identity (navy, blue, gavel mark) is unchanged.

**Out of scope here:** logo redesign, illustration/photo system, marketing site, motion branding.
