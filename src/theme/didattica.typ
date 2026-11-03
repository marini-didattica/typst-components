// Programme theme: warm paper, serif body, sans labels, no footer.

#import "palette.typ": palette-didattica

/// Apply the page and typography used by `programma-didattica`.
///
/// The body font is intentionally left at Typst's serif default: programme
/// documents are prose, not exam sheets. Only labels switch to `font-sans`.
#let tema-didattica(
  body,
  paper: "a4",
  margin: (x: 2.4cm, y: 2.4cm),
) = {
  set page(paper: paper, margin: margin, footer: none)
  set text(lang: "it", region: "IT", fill: palette-didattica.ink)
  set par(leading: 0.75em)
  body
}
