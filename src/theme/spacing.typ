// Shared vertical rhythm.

/// Exam and component rhythm.
///
/// Flowing content uses the `em`-based scale (`xs` … `xxl`); fixed page
/// furniture (cover, footer, answer lines) uses the absolute `page` scale.
/// Components should use these tokens instead of ad-hoc `#v(...)` values.
#let spazio = (
  xs: 0.25em,
  sm: 0.45em,
  md: 0.65em,
  lg: 0.9em,
  xl: 1.5em,
  xxl: 2em,
  page: (
    xs: 4pt,
    sm: 8pt,
    md: 12pt,
    lg: 16pt,
    xl: 20pt,
    xxl: 28pt,
  ),
)

/// Programme rhythm.
///
/// Kept separate from `spazio` because the programme cover is built on a
/// different scale (centimetres above the fold, `em` in flowing content).
#let spazio-didattica = (
  xs: 0.35em,
  sm: 0.4em,
  md: 0.8cm,
  lg: 3em,
  xl: 5em,
  page: (
    xs: 0.9em,
    sm: 4em,
  ),
)
