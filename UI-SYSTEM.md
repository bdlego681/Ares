# UI System & Non-HP Brand Rules

## Source of Truth: `dope-design.md`

`dope-design.md` defines the visual grammar for this project[cite: 1]:
- Color roles (`primary: "#024ad8"`, `ink: "#1a1a1a"`, `canvas: "#ffffff"`, `cloud: "#f7f7f7"`, `fog: "#e8e8e8"`, and semantic/accent tokens)[cite: 1]
- Typography hierarchy and font stack rules (`Forma DJR Micro` with open-source fallbacks such as `Manrope` or `Inter`)[cite: 1]
- Spacing scale, border radii (`rounded.md` for sharp controls, `rounded.xl` for cards/media frames), and elevation tiers[cite: 1]

## Central Stylesheet Rule (No Per-Page `.scss` Sprawl)

- Implement `dope-design.md` tokens and component styles in a **central stylesheet** (`Ares-UI/src/styles/design-system.scss`) imported once globally rather than maintaining a `.scss` file for every page[cite: 1].
- Expose clear, reusable classes on `.html` templates—such as `text-primary`, `text-ink`, `surface-canvas`, `surface-cloud`, `surface-ink`, `button-primary`, `button-outline`, and `card-product`[cite: 1].
- Keep `.html` templates declarative using those shared classes; avoid duplicating button, card, or typography CSS across individual page components.

## Guardrail: This Product Is Not HP

Even though `dope-design.md` is titled `HP-design-analysis` and references HP layouts/components as design inspiration[cite: 1]:

1. **Never brand the app as HP:** Do not use HP logos, HP wordmarks, HP product names, or HP marketing copy in the UI, seed data, or documentation.
2. **Translate components to our domain:** Map card, hero, navigation, and section patterns from `dope-design.md` to our own brand name, product catalog, `/info` page, and `/admin` views[cite: 1].
3. **Keep navigation multi-page:** Header and footer links must route to dedicated pages (`/catalog`, `/info`, `/cart`, `/checkout`, `/admin`, etc.) via Angular router links rather than scrolling down a single landing page.