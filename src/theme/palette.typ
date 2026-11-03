// Shared colours and font families.
//
// `palette` is the exam identity (blue, cool tints); `palette-didattica` is
// the warmer identity used by programme documents. They are intentionally
// separate presets, but share the same role names (`ink`, `accent`, `tint`).

#let palette = (
  ink: rgb("#212630"),
  accent: rgb("#3e63dd"),
  accent-dark: rgb("#2c46b8"),
  tint: rgb("#eef3fd"),
  amber: rgb("#e9a13b"),
  amber-dark: rgb("#a86508"),
  amber-tint: rgb("#fdf3e2"),
  code-bg: rgb("#f4f5f7"),
)

#let palette-didattica = (
  ink: rgb("#211f1c"),
  muted: rgb("#6f6a63"),
  rule: rgb("#d8d2c8"),
  accent: rgb("#8a1730"),
  tint: rgb("#f7f3ec"),
)

#let font-mono = "DejaVu Sans Mono"
#let font-sans = "Liberation Sans"
