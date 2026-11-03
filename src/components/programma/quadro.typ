// Framework table and module table primitives.
//
// Typst cannot spread a content body of `#sezione(...)` calls directly into
// table cells. Sections therefore register themselves in a document-local
// state; `quadro` and `modulo` consume and clear the registry after laying
// out their body.

#import "../../theme/palette.typ": palette-didattica, font-sans

#let registro-sezioni = state("programma-sezioni", ())

/// Register one section for the enclosing `quadro` or `modulo`.
#let sezione(titolo, corpo) = registro-sezioni.update(voci => (
  voci + ((titolo: titolo, corpo: corpo),)
))

#let intestazione-sezione(titolo) = text(
  font: font-sans,
  size: 10pt,
  weight: 700,
  fill: palette-didattica.accent,
)[#titolo]

#let tabella-sezioni(voci) = table(
  columns: (0.3fr, 1fr),
  stroke: 0.5pt,
  ..voci
    .map(voce => (
      [#intestazione-sezione(voce.titolo)],
      voce.corpo,
    ))
    .flatten(),
)

/// Render the first-page framework table from `#sezione` entries.
#let quadro(body) = {
  body
  context {
    let voci = registro-sezioni.get()
    registro-sezioni.update(_ => ())
    tabella-sezioni(voci)
  }
}
