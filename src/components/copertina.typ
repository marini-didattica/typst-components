// Full cover page for generated exams.

#import "../theme/palette.typ": palette, font-mono
#import "../theme/spacing.typ": spazio
#import "../theme/labels.typ": etichetta

/// Full cover page.
///
/// - `top`: small kicker above the title (or `none`)
/// - `title`, `subtitle`: main cover text (or `none`)
/// - `decoration`: `auto` for the default bit strip, `none` to hide it,
///   or a function returning custom content
/// - `descriptors`: array of `(label, value)` pairs
/// - `student-data`: `none`, or a subset of `("nome", "cognome", "classe", "data")`
/// - `body`: optional extra content below the student fields
#let cover(
  top: "LICEO RUSSELL · INFORMATICA · CLASSE PRIMA",
  title: "Simulazione verifica 1",
  subtitle: "Teoria, scrittura e lettura di codice base in python",
  decoration: auto,
  descriptors: (),
  student-data: ("nome", "cognome", "classe", "data"),
  body: none,
) = {
  let campo(nome) = stack(
    dir: ttb,
    spacing: spazio.sm,
    etichetta(nome),
    line(length: 100%, stroke: 0.6pt + luma(170)),
  )

  let dato(titolo, valore) = stack(
    dir: ttb,
    spacing: spazio.md,
    etichetta(titolo),
    text(weight: 800, fill: palette.accent)[#valore],
  )

  let bitbox(v) = box(
    width: 1.55em,
    height: 1.55em,
    inset: 0pt,
    radius: 3pt,
    fill: if v == "1" { palette.accent } else { white },
    stroke: 0.6pt + luma(185),
  )[#align(center + horizon)[#text(
    font: (font-mono,),
    size: 0.9em,
    weight: 700,
    fill: if v == "1" { white } else { luma(120) },
  )[#v]]]

  let default-decoration() = box(baseline: 30%)[
    #for (i, b) in ("0", "1", "0", "1", "1", "0", "0", "1").enumerate() {
      if i > 0 { h(3pt) }
      bitbox(b)
    }
  ]

  let student-labels = (
    nome: "Nome",
    cognome: "Cognome",
    classe: "Classe",
    data: "Data",
  )

  let fields = if student-data == none { () } else { student-data }
  let decoration-content = if decoration == none {
    none
  } else if decoration == auto {
    default-decoration()
  } else {
    decoration()
  }

  page(footer: none)[
    #align(center)[
      #v(spazio.page.xl)
      #if top != none [
        #text(
          size: 9pt,
          weight: 700,
          tracking: 0.18em,
          fill: palette.accent,
        )[#top]
        #v(spazio.page.md)
      ]
      #if title != none [
        #text(size: 28pt, weight: 800, fill: palette.ink)[#title]
        #v(spazio.page.xs)
      ]
      #if subtitle != none [
        #text(size: 14pt, fill: luma(110))[#subtitle]
        #v(spazio.page.lg)
      ]
      #if decoration-content != none [
        #decoration-content
        #v(spazio.page.lg)
      ]
    ]

    #if descriptors.len() > 0 [
      #block(
        width: 100%,
        fill: white,
        stroke: 0.7pt + luma(218),
        radius: 4pt,
        inset: (x: 11pt, y: 9pt),
      )[
        #grid(
          columns: (1fr,) * descriptors.len(),
          column-gutter: 10pt,
          align: center,
          ..descriptors.map(pair => dato(pair.at(0), pair.at(1))),
        )
      ]
      #v(spazio.page.lg)
    ]

    #if fields.len() > 0 [
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 18pt,
        row-gutter: spazio.page.xxl,
        ..fields.map(field => campo(
          student-labels.at(field, default: upper(field)),
        )),
      )
    ]

    #if body != none [
      #body
    ]
  ]
}
