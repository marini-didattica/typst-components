// Teaching module: level-1 heading, planned hours and a two-column table.

#import "../../theme/palette.typ": palette-didattica, font-sans
#import "../../theme/spacing.typ": spazio-didattica
#import "quadro.typ": registro-sezioni, tabella-sezioni

/// Subheading inside a module column.
#let sottosezione(titolo) = text(
  font: font-sans,
  size: 10pt,
  weight: 700,
)[#titolo]

/// Render one teaching module from `#sezione` entries.
///
/// `titolo` is the full heading text (e.g. `"Modulo 1 – Introduzione
/// all'informatica"`); `ore` is the planned hours, or `none` to omit the line.
#let modulo(titolo, ore: none, body) = {
  heading(level: 1)[#titolo]
  if ore != none {
    block(above: 0pt, below: spazio-didattica.sm)[
      #text(
        fill: palette-didattica.muted,
        size: 10pt,
        tracking: 0.10em,
      )[*Ore previste: #ore*]
    ]
  }

  body
  context {
    let voci = registro-sezioni.get()
    registro-sezioni.update(_ => ())
    tabella-sezioni(voci)
  }
}
