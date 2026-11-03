// Shared labels and running state.

/// Small uppercase label used above values and sections.
///
/// The defaults reproduce the exam theme. The programme theme passes
/// `font: font-sans`, `weight: 400`, `size: 10pt` and `maiuscolo: false`.
#let etichetta(
  txt,
  size: 7.6pt,
  weight: 700,
  tracking: 0.14em,
  fill: luma(118),
  font: none,
  maiuscolo: true,
) = {
  let contenuto = if maiuscolo { upper(txt) } else { txt }
  if font == none {
    text(size: size, weight: weight, tracking: tracking, fill: fill)[#contenuto]
  } else {
    text(
      font: font,
      size: size,
      weight: weight,
      tracking: tracking,
      fill: fill,
    )[#contenuto]
  }
}

/// Text of the last level-1 heading. Components use it to group automatic
/// summaries by the section they appear in.
#let sezione-corrente = state("sezione-corrente", none)
