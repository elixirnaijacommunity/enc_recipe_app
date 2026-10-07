# ENC Recipes theme

The app currently has one theme: `enc`. Both Phoenix and Hologram root layouts
select `data-theme="enc"`, and the CSS also provides it as the default. OS dark
mode and previously saved Phoenix theme preferences do not change this palette.

The source is `enc_recipes_current_design_system.pdf`. This change implements the
shared styling foundation; the document's complete page layouts and hero dish
illustrations are separate page work. Existing responsive layouts remain intact.

## CSS structure

- `assets/css/app.css`: imports, template sources, plugins, and LiveView variants.
- `assets/css/tokens.css`: exact reference colors, font stacks, radii, and shadows.
- `assets/css/theme.css`: maps those tokens into daisyUI's semantic roles.
- `assets/css/components.css`: common typography, buttons, fields, cards, chips,
  modal surfaces, nutrition labels, and dish placeholders.
- `assets/css/fonts.css`: locally hosted Fraunces, Inter, and IBM Plex Mono. Latin
  and extended Latin subsets and their open font licenses live in `priv/static/fonts`.

Edit palette values in `tokens.css`. Use semantic utilities for standard UI:
`btn-primary`, `text-base-content`, `bg-base-100`. For specific design roles use
`bg-parchment`, `text-ink-soft`, `bg-panel`, `text-turmeric`, `border-line`, etc.
Do not introduce hard-coded colors in templates or additional theme toggles.

| Role | Token / utility |
| --- | --- |
| Page background | `--parchment` / `bg-parchment` |
| Card and input surface / base-100 | `--white` / `bg-base-100` |
| Deeper surface / base-300 | `--parchment-2` / `bg-base-300` |
| Main text / base-content | `--ink` / `text-base-content` |
| Muted text | `--ink-soft` / `text-ink-soft` |
| Primary action | `--chili` / `btn-primary` |
| Primary hover | `--chili-dark` |
| Secondary highlight | `--turmeric` / `text-secondary` |
| Tertiary accent | `--sage` / `text-accent` |
| Tag fill | `--sage-soft` / `tag-chip` |
| Footer/dark surface | `--panel` / `bg-panel text-white` |
| Outer backdrop | `--bg` / `bg-backdrop` |
| Light borders | `--line` / `border-line` |

The reference does not specify separate status colors. Info and success use sage
soft with ink text, warning uses turmeric with ink text, and error uses chili with
white text. Status messages should include text or an icon explaining the status.

## Shared components

Buttons are pills with 12px/20px padding; `btn-sm` uses 9px/15px. `btn-ghost`
provides the reference's bordered secondary action and `btn-link` the text action.
Primary solid buttons hover to chili dark. Explicit utility classes may override
shared styles when a component needs a different size.

Fields have white fills, 10px radii, 1.5px borders, and chili focus indicators.
Use `label` and `field-hint` for labels and hints. Cards have white fills, 16px
radii, 1px borders, and soft shadows. `modal-box` uses parchment with an 18px
radius. `nutrition-box` has the reference's ink border. `dish-art` provides the
130px dark gradient placeholder; apply `text-sage` for its alternate icon color.

Headings use Fraunces, body text uses Inter, and `font-mono`, `recipe-meta`, and
`tag-chip` use IBM Plex Mono. Heading defaults are 38px (h1), 25px (h2), and 16px
(h3/card titles). Font loading uses `font-display: swap` and system fallbacks.

## Preview and validation

Run `mix assets.build`, start the app with `mix holo`, and visit `/components`
for the palette and examples of shared styles. Check the same page with the OS set
to light and dark; its appearance should remain the same. The Phoenix `/` starter
page also uses the fixed palette and no longer includes a theme switcher.
