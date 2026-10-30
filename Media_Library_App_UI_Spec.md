# Media Library App: Detailed UI Specification

> **Source:** `Media_Library_App_UX_Mockup_Grid.png` (grid of 17 screens, light and dark variants).
> **Purpose:** Describe every screen, component and state precisely enough that the UI can be rebuilt to match the mockup on top of an existing, working (stripped-down) app.
> **Stack:** Written to be framework-neutral (works for Flutter, React Native, SwiftUI, Compose).

## How to read the numbers in this document

The mockup is a small raster image, so nothing could be measured. Every size, colour and spacing value below is an **estimate** read from the picture. Treat them as a very close starting point and correct them against a Figma file or full-size frames if you have them.

| Marker | Meaning |
| --- | --- |
| **Seen** | Visible in the mockup (text, order, layout, state). |
| **Est.** | Estimated value (px, hex, radius). Verify before final polish. |
| **Suggested** | Not visible in the mockup; recommended behaviour so the UI feels complete. |

---

## Table of contents

1. [Product summary and navigation map](#1-product-summary-and-navigation-map)
2. [Design tokens](#2-design-tokens)
3. [Component library](#3-component-library)
4. [Screen specifications](#4-screen-specifications)
5. [State screens (empty, no results, loading, offline, error)](#5-state-screens)
6. [Theming rules (light, dark, system)](#6-theming-rules)
7. [Motion and interaction (suggested)](#7-motion-and-interaction-suggested)
8. [Accessibility](#8-accessibility)
9. [Assets you need to provide](#9-assets-you-need-to-provide)
10. [Mockup inconsistencies to resolve](#10-mockup-inconsistencies-to-resolve)
11. [Implementation order and acceptance checklist](#11-implementation-order-and-acceptance-checklist)

---

## 1. Product summary and navigation map

A personal **media tracker** for movies, series and books. A person signs in with a phone number, builds a library, and tracks each item's status, rating and notes.

### Screen inventory

| # | Screen | Variants in mockup |
| --- | --- | --- |
| 01 | Welcome | Light, Dark |
| 02 | Phone Login | Light |
| 02 | OTP Verification | Light |
| 04 | Profile Setup | Light |
| 05 | Home | Light, Dark |
| 06 | Library | Light, Dark |
| 07 | Search | Light, Dark |
| 08 | Media Details | Light |
| 09 | Add to Library (bottom sheet) | Light |
| 10 | Profile | Light |
| 11 | Settings | Light |
| 12 | Theme Selection | Light |
| 13 | Empty Library | Light, Dark |
| 14 | No Results | Light, Dark |
| 15 | Loading (skeleton) | Light, Dark |
| 16 | Offline | Light, Dark |
| 17 | Error | Light, Dark |

Screens that only appear in light in the mockup must also be built in dark. Dark is a straight token swap (see section 6).

### Navigation map

```text
Welcome ──Get Started──> Phone Login ──Send Code──> OTP ──verified──> Profile Setup ──Continue──> Home
   └──Sign In──> Phone Login

Bottom tab bar (4 tabs, persistent):  Home | Library | Search | Profile

Home      ── tap poster ──> Media Details
          ── "See All" ───> (list of trending items)           [Suggested]
          ── search bar ──> Search tab
          ── category chip > Library filtered by type          [Suggested]
Library   ── tap poster ──> Media Details
          ── search icon ─> Search
Search    ── tap row ─────> Media Details
          ── "+" button ──> Add to Library sheet
Media Details ── "Add to Library" ──> Add to Library sheet
Profile   ── My Library ──> Library tab
          ── Settings ────> Settings ──> Theme / Language / etc.
          ── Theme ───────> Theme Selection
```

The 13 to 17 state screens are not separate destinations. They appear **inside** the screens where the condition occurs (empty Library, no Search results, loading while fetching, offline banner or screen, error with retry).

---

## 2. Design tokens

Overall look: **minimal, monochrome, iOS-like.** Black and white with one blue accent. Content (posters) provides the colour.

### 2.1 Colour tokens (Est.)

| Token | Light | Dark | Used for |
| --- | --- | --- | --- |
| `bg` | `#FFFFFF` | `#0B0B0C` | Screen background |
| `surface` | `#F4F4F5` | `#1C1C1E` | Inputs, unselected chips, cards, skeleton blocks |
| `surfaceRaised` | `#FFFFFF` | `#242426` | Bottom sheet, keypad key backgrounds |
| `border` | `#E4E4E7` | `#2C2C2E` | Hairline dividers, outlined buttons, input outlines |
| `textPrimary` | `#0B0B0C` | `#FFFFFF` | Titles, body, selected chip text (in dark) |
| `textSecondary` | `#6B6B72` | `#9A9AA0` | Subtitles, captions, placeholders, inactive tab |
| `accent` | `#2F7BF5` | `#4C8DFF` | "Resend Code", "Read more", selected Theme card border |
| `primaryFill` | `#0B0B0C` | `#FFFFFF` | Primary button background, selected chip background, "+" button |
| `onPrimaryFill` | `#FFFFFF` | `#0B0B0C` | Text/icon on primary fill |
| `star` | `#F5B301` | `#F5B301` | Rating star (details screen) |
| `starEmpty` | `#B5B5BB` | `#5A5A60` | Unselected rating stars |
| `danger` | `#E5484D` | `#FF5A5F` | Error icon, offline icon (dark mode as seen) |
| `scrim` | `#000000` at 45% | `#000000` at 60% | Dim layer behind bottom sheet |
| `overlayButton` | `#000000` at 35% | `#000000` at 45% | Translucent back button over hero image |

### 2.2 Typography (Est.)

Font: **SF Pro** on iOS, **Inter** (or Roboto) elsewhere. Sizes in logical px / pt.

| Style | Size / line height | Weight | Used for |
| --- | --- | --- | --- |
| `displayLarge` | 30 / 36 | Bold (700) | Welcome title "Your Media Library" |
| `titleLarge` | 26 / 32 | Bold | Screen titles: "Sign In", "My Library", "Search", "Profile" |
| `titleMedium` | 22 / 28 | Bold | "Enter Verification Code", "Complete Your Profile", media title "Dune" |
| `sectionHeading` | 16 / 22 | Bold (700) or Semibold (600) | "Trending Now", "Continue Watching/Reading", "Cast & Crew" |
| `body` | 14 / 20 | Regular | Subtitles, synopsis, descriptions |
| `bodyStrong` | 14 / 20 | Semibold | List row titles, button labels |
| `caption` | 12 / 16 | Regular | Poster type labels, helper text, legal text |
| `captionStrong` | 12 / 16 | Semibold | Poster titles |
| `micro` | 10 / 12 | Medium | Tab bar labels |
| `button` | 15 / 20 | Semibold | Button text |

### 2.3 Spacing, radius, elevation (Est.)

| Token | Value |
| --- | --- |
| Spacing scale | 4, 8, 12, 16, 20, 24, 32, 40 |
| Screen horizontal padding | 20 |
| Section vertical gap | 24 |
| Corner radius: input | 12 |
| Corner radius: poster | 10 |
| Corner radius: card / skeleton block | 12 |
| Corner radius: chip | 999 (pill) |
| Corner radius: primary button | 999 (pill) |
| Corner radius: bottom sheet (top corners) | 24 |
| Corner radius: OTP box | 12 |
| Elevation | None. Flat design. Separation comes from fill colour and hairlines. |

### 2.4 Sizing reference (Est.)

| Element | Size |
| --- | --- |
| Primary button height | 52 |
| Input height | 48 |
| OTP box | 44 wide x 52 tall, 8 gap |
| Chip height (type filter) | 32; status filter chips slightly smaller (28) |
| Tab bar height | 56 + bottom safe area |
| Search result thumbnail | 48 x 68 |
| Poster in horizontal row | about 104 x 150 |
| Poster in Library grid | 3 columns, 12 gap, about 104 x 150 each |
| Large avatar (Profile Setup, Profile) | 96 setup / 80 profile |
| Header avatar (Home) | 36 |
| Cast avatar | 56 |
| Hero image height (Details) | about 40% of screen height |
| Icon size | 22 (tab bar 24) |

Safe areas: the mockup shows a Dynamic Island iPhone. Respect top and bottom safe area insets; do not draw the 9:41 status bar, it is the OS.

---

## 3. Component library

Build these once and reuse across screens.

### 3.1 PrimaryButton
- Full width, height 52, pill radius, centered label (`button` style).
- **Light:** background `primaryFill` (black), text white. **Dark:** background white, text black.
- Disabled: 40% opacity. Loading: label replaced by a small spinner of the text colour.

### 3.2 SecondaryButton (outlined)
- Same size as primary. Transparent background, 1px `border`, label in `textPrimary`. Used for **Cancel** and, in some places, secondary actions.

### 3.3 TextButton
- No background, `bodyStrong` in `textPrimary` (e.g. **Sign In** on Welcome) or `accent` (e.g. **Resend Code**).

### 3.4 IconCircleButton
- 36 to 40 diameter circle. Variants:
  - **Overlay** (back button on hero image): `overlayButton` fill, white chevron.
  - **Add (+)** on search rows: `primaryFill` background, `onPrimaryFill` plus icon, 32 diameter. In dark mode the mockup shows it as a muted grey fill with white plus.
  - **Play:** 64 diameter white circle with black triangle, centred over hero.

### 3.5 SquareIconButton
- 52 x 52, radius 12, 1px `border`, bookmark outline icon. Sits next to "Add to Library".

### 3.6 Chip (filter / status / genre)
- Pill. Horizontal padding 14, height 32.
- **Selected:** `primaryFill` background, `onPrimaryFill` text.
- **Unselected:** `surface` background, `textPrimary` text.
- **With icon** (Home category chips): 16px icon left of label, 6 gap.
- **Genre chip** (details): unselected style, not interactive.
- Chip rows scroll horizontally if they overflow. In the Add to Library sheet, status chips **wrap** to a second line instead.

### 3.7 SearchField
- Height 48, radius 12, `surface` fill, leading magnifier icon, placeholder in `textSecondary`.
- Filled state shows the typed text and a trailing circular **clear (x)** button.
- On Home it is a **tap target** that opens Search (read-only look).

### 3.8 TextField (labelled)
- Small label (`caption`, `textSecondary`) above a 48px field with `surface` fill and radius 12. Placeholder in `textSecondary`.
- Used on Profile Setup (Display Name, Email (Optional)) and the notes area (taller, multi-line, about 72px).

### 3.9 OtpField
- Six individual boxes in one row, equal width, 8 gap, radius 12, `surface` fill (or 1px border). One digit per box, centred, `titleMedium`.
- Auto-advance on input, backspace moves back, paste fills all six.

### 3.10 PosterCard
- Poster image (radius 10, 2:3 ratio), then title (`captionStrong`, 1 line, ellipsis) then type label (`caption`, `textSecondary`): "Movie", "Series" or "Book".
- Used in Home rows and Library grid. Tap opens Media Details.

### 3.11 MediaListRow (search result)
- Row height about 76. Left: thumbnail 48 x 68 radius 8. Middle: title (`bodyStrong`) and subtitle (`caption`, `textSecondary`), e.g. "2021 · Movie" or "Book · Frank Herbert". Right: Add (+) circle button.
- No divider lines, vertical spacing of about 12 between rows.

### 3.12 SectionHeader
- Left: `sectionHeading` text. Right (optional): "See All" in `textSecondary` `caption` or `body`.

### 3.13 SettingsRow
- Height 56. Leading 20px outline icon, 14 gap, title (`body`), optional second line (`caption`, `textSecondary`), trailing either a **value text** (`textSecondary`) plus chevron, or just a chevron.

### 3.14 StatTile
- Number in `titleMedium` bold, label under it in `caption` `textSecondary`. Three tiles equally spaced, separated by thin vertical hairlines (as seen on Profile).

### 3.15 BottomTabBar
- 4 items: **Home, Library, Search, Profile**. Icon 24 over 10px label.
- **Active:** filled icon in `textPrimary`, label bold. **Inactive:** outline icon in `textSecondary`.
- Background `bg` with a 1px top hairline (`border`).
- Persistent on Home, Library, Search, Profile and Settings flow screens as shown (Settings and Theme hide it).

### 3.16 BottomSheet
- Top radius 24, `surfaceRaised` fill, a dim `scrim` behind. Grab handle is **not** visible in the mockup; omit or keep very subtle. Content padded 20.

### 3.17 StateView (empty / no results / offline / error)
- Vertically centred column: 64px icon, 16 gap, title (`sectionHeading` size 18 bold), 8 gap, description (`body`, `textSecondary`, centred, max width about 260), 24 gap, optional PrimaryButton (not full width: about 200 wide, centred).

### 3.18 SkeletonBlock
- Rounded rectangle (radius 12) filled with `surface`. Shimmer: a lighter diagonal band sweeping left to right, 1.2s loop (Suggested).

### 3.19 CircularCountdown (OTP)
- 56px ring (2px stroke in `border`), a progress arc in `textPrimary` shrinking over 60s, centre text "00:45" in `caption` bold.

---

## 4. Screen specifications

Each screen lists layout **top to bottom**. All text is exactly as seen in the mockup.

---

### 01 · Welcome

**Variants:** Light and Dark. Same layout.

**Layout (top to bottom)**
1. **Full-bleed hero illustration** across the top about 58% of the screen, running under the status bar. It **fades into the background colour** at its bottom edge (gradient from transparent to `bg`).
   - *Light:* warm, muted, painterly scene of a person sitting and reading (beige, soft orange and teal tones).
   - *Dark:* night scene with a crescent moon and the same reader silhouette.
2. **Title**, left aligned, two lines, `displayLarge`:
   `Your`
   `Media Library`
3. **Subtitle**, `body`, `textSecondary`, three lines:
   *"Discover, organize and keep track of your movies, series and books all in one place."*
4. **Page indicator:** 4 dots, first one active (solid `textPrimary`), others `textSecondary` at 40%. Indicates a carousel (swipeable onboarding pages). 6px dots, 6 gap.
5. **PrimaryButton:** "Get Started".
6. **TextButton:** "Sign In" (centred under the button).

**Behaviour**
- Get Started goes to Phone Login. Sign In also goes to Phone Login (existing user).
- Swipe changes the hero illustration and copy (only page 1 is designed; pages 2 to 4 are **Suggested** and need content from you).

**Light vs dark**
- Light: black button, white label. Dark: white button, black label.

---

### 02 · Phone Login

**Layout**
1. **Back arrow** (top-left, icon only).
2. **Title:** "Sign In" (`titleLarge`), left aligned.
3. **Subtitle:** "We'll send a verification code to your phone number" (`body`, `textSecondary`).
4. **Phone input row:** two fields side by side with 12 gap:
   - **Country code dropdown**, width about 90, shows `+1` and a down chevron. Opens a country picker.
   - **Phone number field**, fills remaining width, placeholder `987 654 3210`.
5. **PrimaryButton:** "Send Code".
6. **Legal text,** centred, `caption`, `textSecondary`, two lines:
   *"By continuing, you agree to our Terms of Service and Privacy Policy"* (the two policy names are links, shown in `textPrimary` or underlined).
7. **Numeric keypad** is open at the bottom (system keyboard, phone-pad type). The layout above scrolls or compresses so the button and legal text stay above the keyboard.

**Behaviour**
- Autofocus the phone field on open.
- Send Code is disabled until the number is valid for the selected country.
- On tap: loading state on the button, then go to OTP.

---

### 03 · OTP Verification (labelled "02 - OTP Verification" in mockup)

**Layout**
1. **Back arrow** top-left.
2. **Title**, centred: "Enter Verification Code" (`titleMedium`).
3. **Helper**, centred, `body`, `textSecondary`, two lines:
   *"We've sent a 6-digit code to"* / *"+1 987 654 3210"*
4. **OtpField:** six boxes in a row.
5. **CircularCountdown** centred, showing "00:45".
6. **TextButton** in `accent`: "Resend Code" (centred under the ring).

**Behaviour**
- Autofocus first box; numeric keypad open.
- Auto-submit when the sixth digit is entered.
- Resend is disabled and dimmed while the countdown runs; becomes active at 00:00.
- Error state (Suggested): boxes get a `danger` border and a short shake, helper text "Incorrect code. Try again." in `danger`.

---

### 04 · Profile Setup

**Layout**
1. **Back arrow** top-left.
2. **Avatar picker:** 96px circle, `surface` fill, centred camera icon. A **small black circular badge** (28px, white camera or edit icon) overlaps the bottom-right of the circle.
3. **Title**, centred: "Complete Your Profile" (`titleMedium`).
4. **Subtitle**, centred: "This helps personalize your experience" (`body`, `textSecondary`).
5. **Field "Display Name":** label above, value shown as `Alex`.
6. **Field "Email (Optional)":** label above, placeholder `you@example.com`.
7. **PrimaryButton:** "Continue", pinned near the bottom of the screen with the keyboard dismissed.

**Behaviour**
- Tapping the avatar opens a picker sheet (camera, gallery, remove) (Suggested).
- Continue is enabled when Display Name is not empty. Email is optional but validated if filled.

---

### 05 · Home

**Variants:** Light and Dark.

**Layout (top to bottom, scrollable, tab bar fixed)**
1. **Header row**
   - Left: **"Hello Alex 👋"** (`titleMedium`, 20 to 22 size, bold; emoji is a waving hand) with the subtitle **"Your library awaits"** (`body`, `textSecondary`) underneath.
   - Right: **circular profile avatar**, 36px.
2. **SearchField** (tap target): placeholder "Search movies, series, books…".
3. **Category chips row:** three equal-width chips with icons: **Movies**, **Series**, **Books**. Unselected style (`surface` fill). Each has a small outline icon (film, tv, book) left of its label.
4. **SectionHeader:** "Trending Now" with "See All" on the right.
5. **Horizontal poster row** (PosterCard x3 visible, scrolls horizontally): Dune (Movie), The Last of Us (Series), Atomic Habits (Book).
6. **SectionHeader:** "Continue Watching/Reading".
7. **Horizontal poster row:** Oppenheimer (Movie), Breaking Bad (Series), Sapiens (Book). *(No progress bars are visible in the mockup. Adding a thin progress bar under each poster is **Suggested**.)*
8. **BottomTabBar** with **Home** active.

**Behaviour**
- Pull to refresh (Suggested).
- Tapping a poster opens Media Details. "See All" opens a full list (Suggested).

**Light vs dark**
- Dark swaps tokens only; posters unchanged. Note the dark Home shows the tab label for Home slightly bolder than the rest.

---

### 06 · Library ("My Library")

**Variants:** Light and Dark.

**Layout**
1. **Header:** "My Library" (`titleLarge`) left, **search icon** right.
2. **Type filter chips** (row 1): **All** (selected), **Movies**, **Series**, **Books**.
3. **Status filter chips** (row 2, a bit smaller): **All** (selected), **Watching**, **Completed**, **Plan to Watch**. *The row overflows to the right and scrolls horizontally.*
4. **Poster grid,** **3 columns**, 12 gap, title and type under each:
   - Row 1: Dune (Movie), The Last of Us (Series), Atomic Habits (Book)
   - Row 2: Interstellar (Movie), Breaking Bad (Series), Sapiens (Book)
5. **BottomTabBar** with **Library** active.

**Behaviour**
- The two chip rows **combine** (AND filter): type + status.
- Infinite scroll or pagination as the library grows.
- If the filtered result is empty, show the **Empty Library** or **No Results** state (see section 5).
- Long-press a poster for quick actions (change status, remove) (Suggested).

---

### 07 · Search

**Variants:** Light and Dark.

**Layout**
1. **Title:** "Search" (`titleLarge`).
2. **SearchField,** shown filled with the text `Dune`, with a trailing clear (x) button.
3. **Type chips:** **All** (selected), **Movies**, **Series**, **Books**.
4. **Result list** (MediaListRow), as seen:

   | Title | Subtitle |
   | --- | --- |
   | Dune | 2021 · Movie |
   | Dune: Part Two | 2024 · Movie |
   | Dune: Prophecy | 2024 · Series |
   | Dune | Book · Frank Herbert |
   | Children of Dune | Book · Frank Herbert |

   Each row ends with the **Add (+)** circle button.
5. **BottomTabBar** with **Search** active.

**Behaviour**
- Debounce typing by about 400 ms (Suggested), then fetch.
- Tap row opens Media Details. Tap "+" opens the Add to Library sheet directly.
- If the item is already in the library, replace "+" with a check icon (Suggested).
- Empty query: show recent searches (Suggested).
- No matches: **No Results** state. Fetching: **Loading** skeleton. No connection: **Offline** state.

---

### 08 · Media Details

**Variant in mockup:** Light (dark must be built; the page is mostly image-driven so it is a token swap below the hero).

**Layout (top to bottom, scrollable)**
1. **Hero image,** full width, about 40% of screen height, running under the status bar.
   - **Back button** top-left: translucent dark circle with white chevron (Overlay IconCircleButton).
   - **Play button** centred: 64px white circle, black play triangle (opens trailer, Suggested).
   - The hero fades or has a rounded top for the content block; content sits on `bg`.
2. **Title:** "Dune" (`titleMedium`).
3. **Meta line:** "2021 · 2h 35m · Movie" (`body`, `textSecondary`).
4. **Rating row:** yellow star icon + **"8.0/10 (TMDB)"** (`bodyStrong`; "(TMDB)" in `textSecondary`).
5. **Genre chips:** Sci-Fi, Adventure, Drama.
6. **Synopsis,** 3 lines, truncated, followed by a blue link **"Read more"**: *"Feature adaptation of Frank Herbert's groundbreaking novel about a young man who must travel to the most dangerous pla…"*
7. **Action row:** **PrimaryButton "Add to Library"** (fills width minus 64) and a **SquareIconButton** (bookmark) with 12 gap.
8. **SectionHeader:** "Cast & Crew".
9. **Horizontal row of circular cast photos** (56px), with name and role under each (names are cut off in the mockup; Suggested to show name + role in `caption`).

**Behaviour**
- "Read more" expands the synopsis inline.
- "Add to Library" opens the Add to Library sheet. If already added, the button becomes **"In Library"** (outlined, with check) and opens the same sheet in edit mode (Suggested).
- Bookmark button toggles a lightweight "watchlist" mark (behaviour not defined in mockup; confirm).
- For **Books**, the hero is a cover image, the meta line shows year / pages / "Book", and the play button is hidden (Suggested).

---

### 09 · Add to Library (bottom sheet)

**Layout:** a bottom sheet over the **dimmed** Media Details screen. Top radius 24, padding 20.

1. **Header row:** small poster thumbnail (48 x 68, radius 8) + title **"Dune"** (bold) and subtitle **"2021 · Movie"**.
2. **Sheet title:** "Add to Library" (`sectionHeading`).
3. **Status chips** (single select, wrap onto two lines): **Watching** (selected, filled), **Completed**, **Plan to Watch**, and a fourth chip that appears to read **"Drop"** (wrapped to the second line, cut off in the mockup). Treat the fourth as "Dropped".
4. **Rating:** label "Rating" (`caption`, `textSecondary`), then **five stars** (28px, grey when empty, `star` yellow when filled). Tap sets rating 1 to 5; tap the same star again clears (Suggested).
5. **Notes:** label "Notes", multi-line TextField with placeholder **"Add a note…"**.
6. **Footer buttons,** side by side, equal width, 12 gap: **Cancel** (SecondaryButton) and **Save** (PrimaryButton).

**Behaviour**
- Default selected status is **Watching** as shown.
- Save adds or updates the item, closes the sheet, shows a brief confirmation snackbar "Added to your library" (Suggested), and updates the "+" or button state in the background screen.
- Sheet height adapts to the keyboard when Notes is focused.
- For Books, relabel statuses (Suggested): Reading / Completed / Plan to Read / Dropped.

---

### 10 · Profile

**Layout**
1. **Header:** "Profile" (`titleLarge`) left, **search icon** right.
2. **Avatar** centred (80px circle), name **"Alex"** (`titleMedium`), phone **"+1 987 654 3210"** (`body`, `textSecondary`).
3. **Stats row** (StatTile x3): **12 Movies**, **8 Series**, **15 Books**.
4. **Menu list** (SettingsRow, hairline dividers):
   - **My Library** (library icon, chevron)
   - **Settings** (gear icon, chevron)
   - **Theme** (palette icon, value **"Light"**, chevron)
   - **App Language** (globe icon, value **"English"**, chevron)
   - **About** (info icon, chevron)
5. **BottomTabBar** with **Profile** active. *(In the mockup the Search tab is highlighted by mistake; see section 10.)*

**Behaviour**
- Tapping the avatar or name opens edit profile (Suggested).
- Stats come from the library counts per type.

---

### 11 · Settings

**Layout**
1. **Header:** back arrow + **"Settings"** (`titleMedium`).
2. **Section label:** **"Account"** (`caption`, bold, `textSecondary`).
3. **List** (SettingsRow):

   | Icon | Title | Second line / value | Trailing |
   | --- | --- | --- | --- |
   | Phone | Phone Number | `+1 987 654 3210` (second line) | Chevron |
   | Palette | Theme | value **System** | Chevron |
   | Globe | App Language | value **English** | Chevron |
   | Bell | Notifications | none | Chevron |
   | Download | Downloads | "Manage offline content" | Chevron |
   | Storage / database | Data & Storage | "Cache and sync" | Chevron |
   | Help circle | Help & Support | none | Chevron |
   | Info | About | none | Chevron |

4. No tab bar on this screen.

**Behaviour**
- Theme opens **Theme Selection**. App Language opens a language list. The others open their own detail pages (not in the mockup; Suggested placeholders).
- Optional: a destructive "Sign Out" row at the end (Suggested).

---

### 12 · Theme Selection

**Layout**
1. **Header:** back arrow + **"Theme"**.
2. **Three preview cards in a row,** each a miniature phone preview with label beneath:
   - **Light:** white mini-phone. **Selected:** 2px `accent` (blue) border around the card and a small black circular **check badge** at the bottom-left inside the card.
   - **Dark:** dark mini-phone.
   - **System:** split preview, half light and half dark (shown as a narrow dark panel).
3. Labels under each card: **Light**, **Dark**, **System** (selected label bold).

**Behaviour**
- Tapping a card applies the theme **immediately** (live preview) and persists the choice.
- **System** follows the OS setting and reacts live to changes.
- The Settings and Profile rows show the current value text.

---

## 5. State screens

Each state appears in its parent screen's content area. The tab bar remains where the mockup shows it.

### 13 · Empty Library
- **Where:** My Library when the person has no items.
- **Icon:** outline **document** (about 56px), `textSecondary`.
- **Title:** "Your library is empty"
- **Description:** "Start adding your favorite movies, series and books."
- **Button:** "Explore Content" (PrimaryButton, about 200 wide, centred). Goes to Search or Home.
- Tab bar visible (Library active).

### 14 · No Results
- **Where:** Search when the query matches nothing, and Library when filters match nothing.
- **Icon:** large **magnifier** outline.
- **Title:** "No results found"
- **Description:** "Try a different search term or check your spelling."
- No button.

### 15 · Loading (skeleton)
- **Where:** first load of Home, Library or Search results.
- Grey SkeletonBlocks matching the real layout:
  - A wide short bar for the title.
  - A row of pill-shaped chip skeletons.
  - A 3-column grid of tall poster skeletons (radius 10), two rows, with short bars under each for title and type.
- Add shimmer (Suggested). No spinner, no text.

### 16 · Offline
- **Where:** shown full-screen or as the content area when there is no connection and a feature needs one.
- **Icon:** **Wi-Fi-off** (grey in light, **red `danger`** in dark, as seen; pick one treatment for both themes, preferably red).
- **Title:** "You're offline"
- **Description:** "You can still browse your library and see downloaded content. Some features like adding items are not available."
- **Button:** "Got it" (dismisses; PrimaryButton, about 200 wide).
- Suggested: also show a slim **offline banner** at the top of every screen, so the full-screen state is only for screens with nothing cached.

### 17 · Error
- **Where:** any failed request.
- **Icon:** solid **red circle with a white exclamation mark** (about 56px).
- **Title:** "Something went wrong"
- **Description:** "Please try again later."
- **Button:** "Retry" (PrimaryButton, about 200 wide). Re-runs the failed request.

---

## 6. Theming rules

| Rule | Detail |
| --- | --- |
| Single source of truth | All colours come from the token table in section 2.1. No hard-coded hex values in screens. |
| Modes | Light, Dark, System. Default is **System**. Persisted locally. |
| Primary button inversion | Light: black fill, white text. Dark: white fill, black text. |
| Chips | Selected = `primaryFill` / `onPrimaryFill`. Unselected = `surface` / `textPrimary`. |
| Images | Posters and heroes are never tinted. Welcome uses two separate illustrations (light, dark). |
| Status bar | Dark icons on light screens, light icons on dark screens. Over the hero images use light icons. |
| Dividers | Hairline `border`, 1px (0.5 on high-density screens). |

---

## 7. Motion and interaction (suggested)

Not visible in a static mockup, so these are recommendations to make the build feel finished.

| Interaction | Suggested behaviour |
| --- | --- |
| Screen transitions | Standard platform push/pop. Bottom sheet slides up 280 ms ease-out. |
| Tab switch | Instant, state preserved per tab. |
| Chip selection | 150 ms background colour cross-fade. |
| Poster tap | Subtle scale to 0.97 on press, hero transition into Details image. |
| Add (+) | Icon morphs to check on success. |
| Skeleton | 1.2 s shimmer loop. |
| OTP countdown | Ring arc shrinks smoothly, text ticks each second. |
| Theme change | 200 ms cross-fade of colours. |
| Welcome carousel | Parallax on the hero, dots animate width for the active page. |

---

## 8. Accessibility

- Minimum **44 x 44** touch targets (small "+" and icon buttons need extra hit area).
- Contrast: `textSecondary` on `bg` should be at least 4.5:1; adjust the grey if the final value falls below.
- Every icon-only control needs a label: Back, Search, Clear search, Add to library, Play trailer, Bookmark.
- Posters need meaningful labels: "Dune, Movie".
- Support dynamic type: layouts must tolerate 130% text without clipping; chip rows scroll, titles truncate.
- Do not rely on colour alone: selected states also change weight or show a check (Theme cards do).
- Screen readers: announce OTP boxes as "Digit 1 of 6", and the countdown value.

---

## 9. Assets you need to provide

| Asset | Used in | Notes |
| --- | --- | --- |
| Welcome illustration, light | 01 | Warm reader scene, portrait, about 1170 x 1500 |
| Welcome illustration, dark | 01 | Night scene with moon |
| Welcome carousel pages 2 to 4 | 01 | Not designed in the mockup |
| App logo / icon | Splash, launcher | Not shown in the mockup |
| Poster images | 05 to 09 | Dune, The Last of Us, Atomic Habits, Oppenheimer, Breaking Bad, Sapiens, Interstellar and more. Normally loaded from your data source (TMDB for movies and series; a books source is still needed) |
| Hero images | 08 | Backdrop image from the data source |
| Cast photos | 08 | From the data source |
| Icon set | All | Thin outline style (Lucide, Phosphor, SF Symbols style). Needed: arrow-left, chevron-right, chevron-down, search, close, plus, check, bookmark, star, star-outline, play, camera, film, tv, book, home, library, user, settings, palette, globe, bell, download, database, help-circle, info, wifi-off, alert, file-text |
| Country list and flags | 02 | For the dropdown |

Until real assets arrive, use neutral grey placeholders for images so the layout can be finished and verified.

---

## 10. Mockup inconsistencies to resolve

| # | Issue | Recommendation |
| --- | --- | --- |
| 1 | Numbering skips **03**; OTP is labelled "02" and Profile Setup is "04". | Treat as a labelling error; flow is Welcome, Phone Login, OTP, Profile Setup. |
| 2 | One Offline (dark) tile is labelled "**28 - Offline State (Light)**" and shows the dark theme. | Typo; build Offline in both themes. |
| 3 | On **Profile**, the **Search** tab is highlighted instead of **Profile**. | Highlight the Profile tab. |
| 4 | **Theme** shows **"Light"** on Profile but **"System"** on Settings. | Both should display the same current value (default System). |
| 5 | Library status chips say "**Plan to Watch**" even for books. | Use "Plan to Read" and "Reading" when the type filter is Books (or keep generic wording; confirm). |
| 6 | Offline icon is **grey in light** and **red in dark**. | Pick one colour treatment for both modes. |
| 7 | Add to Library fourth status chip is cut off ("Drop"). | Use "Dropped". |
| 8 | Home dark: the Home tab label looks bolder than other mockups. | Use the same active style everywhere. |
| 9 | The bookmark button next to "Add to Library" has no defined behaviour. | Decide: watchlist toggle, or remove it. |
| 10 | Welcome shows 4 page dots but only one page is designed. | Provide pages 2 to 4, or reduce to a single static page. |

---

## 11. Implementation order and acceptance checklist

### Recommended build order
1. **Tokens and theme** (colours, typography, spacing, light/dark/system switching).
2. **Core components** from section 3 (buttons, chips, fields, PosterCard, MediaListRow, SettingsRow, TabBar, BottomSheet, StateView, Skeleton).
3. **Onboarding flow:** Welcome, Phone Login, OTP, Profile Setup.
4. **Main tabs:** Home, Library, Search, Profile, wired to the existing logic.
5. **Details and Add to Library sheet.**
6. **Settings and Theme Selection.**
7. **State screens** (empty, no results, loading, offline, error) hooked into every data-driven screen.
8. **Polish:** motion, accessibility pass, dark-mode pass on every screen, pixel comparison against the mockup.

### Acceptance checklist

- [ ] All 17 screens exist and every light-only screen also works in dark.
- [ ] Text strings match this document exactly (including "Continue Watching/Reading", "Plan to Watch", "Cast & Crew").
- [ ] Both chip rows in Library filter together.
- [ ] Add to Library sheet saves status, rating and note into the existing data layer.
- [ ] Theme choice persists and System follows the OS live.
- [ ] Skeletons appear during first loads; empty, no-result, offline and error states appear in the right situations.
- [ ] Primary buttons invert correctly between light and dark.
- [ ] Tab bar highlights the correct tab on every screen.
- [ ] Safe areas respected (notch, home indicator); keyboard never covers primary actions.
- [ ] Touch targets at least 44 pt; icon-only controls have labels.
- [ ] Side-by-side screenshot comparison with the mockup at the same device size shows no visible layout differences.

---

*End of specification.*
