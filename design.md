---
version: "alpha-mobile"
name: "De Stijl Abstrato - Mobile App Edition"
description: "De Stijl abstract design system adjusted for mobile applications (Flutter/React Native). AI-ready template."
colors:
  primary: "#FF0000"
  secondary: "#0000FF"
  tertiary: "#FFFF00"
  neutral: "#000000"
  surface: "#FFFFFF"
  accent: "#808080"
typography:
  h1:
    fontFamily: Helvetica
    fontSize: 32.0sp
    fontWeight: 700
  body-md:
    fontFamily: Helvetica
    fontSize: 16.0sp
    fontWeight: 400
spacing:
  sm: 8.0dp
  md: 16.0dp
  lg: 32.0dp
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface}"
    padding: 16dp
    border: "2dp solid {colors.neutral}"
---

## Overview

De Stijl abstract design system adapted for mobile. Based on the 1917 movement by Theo van Doesburg and Piet Mondrian, this design reduces everything to horizontals, verticals, and the three primary colors plus black and white. No curves, no gradients, no compromise. 

For this mobile note-taking app, the rigid structure and asymmetrical balance provide a bold, uncluttered, and ultra-fast user experience. 

- Density: 3/10 — Airy & Clean
- Variance: 7/10 — Dynamic layout (asymmetrical padding/margins)
- Motion: 4/10 — Subtle & Snappy

- **Style:** Geometric, Minimalist, Structured, Brutalist Mobile
- **Keywords:** de stijl, abstract, geometric, minimalist, structured, primary colors, grid, bold lines, asymmetrical, neoplasticism
- **Light/Dark:** ✓ Full Light Mode (De Stijl relies heavily on White backgrounds with Black lines)

## Colors

- **Primary Red** (#FF0000) — Destructive actions, important alerts.
- **Primary Blue** (#0000FF) — Primary CTAs (e.g., Floating Action Button).
- **Primary Yellow** (#FFFF00) — Text Highlight Color (Crucial for the "Deep Search" feature).
- **Black** (#000000) — Thick borders, dividers, primary text.
- **White** (#FFFFFF) — App background, Note surface.
- **Grey** (#808080) — Secondary text, metadata (timestamps).

## Typography (Mobile Scale)

- **Display / H1:** Helvetica — Weight 700, 32sp, tight tracking (Used for App Bar Title / Note Title).
- **Body:** Helvetica — Weight 400, 16sp, 1.5 line-height (Used for the main note editor).
- **UI Labels / Snippets:** Helvetica — 14sp, weight 500 (Used for search result snippets).
- **Metadata:** JetBrains Mono — 12sp (Used for dates, character counts, or current index "1/4").

## Layout & App Structure

- **Screen Constraints:** Full width, relying on device `SafeArea`. Base horizontal padding is 16dp.
- **Spacing rhythm:** Base unit 8dp. 
- **Borders:** Heavy reliance on thick black lines (`border: 2dp solid #000000`) separating components (e.g., header, search bar, list items) instead of shadows.
- **Asymmetry in Lists:** Note cards can have alternating padding (e.g., left 16dp, right 8dp for odd items; left 8dp, right 16dp for even items) to create dynamic tension.

## Elevation & Depth (Mobile Physics)

- **Shadows:** Hard, sharp drop shadows (e.g., `offset: Offset(4, 4), color: Colors.black, blurRadius: 0`). No soft/blurred shadows.
- **Physics:** BouncingScrollPhysics (iOS) or ClampingScrollPhysics (Android), but keep it snappy.
- **Auto-Jump Motion:** When jumping to a search keyword, use `Curves.easeOut` with a 300ms duration.
- **Touch States:** Hard color fill on tap (e.g., transparent to black with white text), or a sharp 2dp translation down-right to simulate a mechanical button press. No soft ripples if possible.

## Shapes

- **Corner Radius:** STRICTLY 0px. Absolutely no rounded corners on any component (Cards, Buttons, Dialogs, TextFields).

## Components (App Specific)

- **Search Bar:** Fixed at the top. 0px radius. 2dp Black border. White background. Focus state: Border turns Primary Blue (#0000FF).
- **Note Cards (List Item):** White background, 2dp Black border bottom (as a divider). Title in Black, Snippet in Grey. Matched search term highlighted with Yellow (#FFFF00) background.
- **Floating Action Button (FAB):** Square (0px radius). Primary Blue (#0000FF) background. 2dp Black border. Hard black shadow (4dp offset, no blur). 
- **Text Highlight (In-Editor):** Any matched search query inside the Note Editor must be wrapped in a `TextSpan` with a Yellow (#FFFF00) background and Black text.
- **Mini-Navigator (Search Jump):** A sticky bottom bar or floating square widget. Thick borders, Sharp edges. Uses JetBrains Mono for the "2 / 5" counter.

## Do's and Don'ts

- Do Strong rigid layouts.
- Do Bold black lines (2dp - 4dp thickness).
- Do Blocks of primary colors for accents.
- Do Asymmetrical balance.
- Do Minimalist typography.
- Do Sharp corners (0px radius everywhere).

- No rounded corners (Remove all `BorderRadius.circular`).
- No blurred drop shadows (Use solid offset shadows only).
- No emojis in UI.
- No gradients.
- No pure grey backgrounds for surfaces (Stick to white with black lines).