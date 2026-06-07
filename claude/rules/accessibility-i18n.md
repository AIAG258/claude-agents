## Accessibility & i18n Rules — Always Active for Frontend Work

WCAG 2.1 AA — accessibility standard for all web applications. Owned by **frontend-engineer**.

### WCAG 2.1 AA
- All interactive elements must be keyboard navigable (Tab, Enter, Space, Esc, arrow keys where applicable)
- Images must have `alt` text (or `alt=""` for decorative)
- Form fields must have `<label>` or `aria-label` / `aria-labelledby`
- Error messages must use `role="alert"` or `aria-live="polite"`
- Color contrast minimum:
  - **4.5:1** for normal text
  - **3:1** for large text (≥18pt or ≥14pt bold)
  - **3:1** for UI components and graphical objects
- Use **semantic HTML** — `<button>`, `<nav>`, `<main>`, `<header>`, `<footer>`, `<article>`, `<section>`. Never `<div onClick>`.
- Focus rings visible — `outline: 2px solid var(--brand-accent); outline-offset: 2px;` (set `--brand-accent` to your project's brand color)
- ARIA only when semantic HTML is insufficient — first rule of ARIA is don't use ARIA

### Light theme contrast advantage
On light themes, target **AAA contrast (7:1)** where possible — light backgrounds make this achievable for content-heavy interfaces.

### i18n
- `react-i18next` for ALL user-facing strings — no hardcoded copy
- Translations in `frontend/src/locales/{en,...}.json`
  - **English default**
  - Add additional locales as needed
- Keys hierarchical: `feature.section.element.action` (e.g., `auth.login.button.submit`)
- Date/number/currency formatting via `Intl.DateTimeFormat`, `Intl.NumberFormat` (locale-aware)
- Plural forms via i18next ICU plural syntax — never string concatenation

### Testing
**tester** validates:
- Keyboard-only flow for critical paths
- Screen reader announcement of error states (`role="alert"`)
- Color contrast via automated tools (axe-core, Lighthouse) for both dark and light themes
- All locales render without overflow
