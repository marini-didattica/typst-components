// typst-components — reusable blocks built on top of typst-theme.

#import "../../typst-theme/src/lib.typ": palette, font-mono, etichetta

// ------------------------------------------------------------
//  Stars and answer lines
// ------------------------------------------------------------

#let stella(pieno: true, dim: 0.78em, col: palette.amber) = {
  let r = dim / 2
  let pts = ()
  for i in range(10) {
    let a = 90deg - i * 36deg
    let rad = if calc.rem(i, 2) == 0 { r } else { r * 0.42 }
    pts.push((r + rad * calc.cos(a), r - rad * calc.sin(a)))
  }
  box(baseline: 40%)[
    #polygon(fill: if pieno { col } else { none }, stroke: 1pt + col, ..pts)
  ]
}

#let stelle(n) = box(baseline: 40%)[
  #for i in range(5) {
    if i > 0 { h(2pt) }
    stella(pieno: i < n)
  }
]

#let righe-risposta(n) = grid(
  columns: 1,
  row-gutter: 16pt,
  ..range(n).map(_ => line(
    length: 100%,
    stroke: (paint: luma(195), thickness: 0.6pt, dash: "dotted"),
  )),
)

// ------------------------------------------------------------
//  Small labelled blocks
// ------------------------------------------------------------

#let sezione(titolo, corpo) = stack(
  dir: ttb,
  spacing: 0.5em,
  etichetta(titolo),
  corpo,
)

#let nota(corpo) = block(
  width: 100%,
  fill: palette.amber-tint,
  stroke: (left: 2.6pt + palette.amber),
  radius: (top-right: 3pt, bottom-right: 3pt),
  inset: (x: 10pt, y: 7pt),
)[
  #text(fill: palette.amber-dark, weight: 700)[Nota.] #corpo
]

#let consegna(corpo) = [
  #text(weight: 700, fill: palette.accent-dark)[Consegna.] #corpo
]

#let template(codice) = block(breakable: false)[
  #sezione("Template di partenza", codice)
]

#let esempi(righe) = block(breakable: false)[
  #sezione(
    "Esempi di input e output",
    table(
      columns: (auto, auto, 1fr),
      inset: (x: 8pt, y: 5pt),
      align: (left, left, left),
      stroke: 0.5pt + luma(215),
      table.header([*Input*], [*Output*], [*Spiegazione*]),
      ..righe.flatten(),
    ),
  )
]

#let callout(titolo, corpo) = block(
  width: 100%,
  fill: palette.tint,
  stroke: (left: 2.6pt + palette.accent),
  radius: (top-right: 4pt, bottom-right: 4pt),
  inset: (x: 11pt, y: 9pt),
)[
  #stack(
    dir: ttb,
    spacing: 0.6em,
    text(weight: 800, fill: palette.accent-dark, size: 11.5pt)[#titolo],
    corpo,
  )
]

#let checklist(titolo, items) = block(
  breakable: false,
  width: 100%,
  fill: palette.tint,
  stroke: 0.6pt + luma(222),
  radius: 4pt,
  inset: 10pt,
)[
  #stack(
    dir: ttb,
    spacing: 0.6em,
    text(weight: 800, fill: palette.accent-dark)[#titolo],
    list(..items),
  )
]

// ------------------------------------------------------------
//  Question / exercise headers
// ------------------------------------------------------------

#let domanda(n, titolo, punti, righe, corpo) = block(
  breakable: false,
  width: 100%,
)[
  #stack(
    dir: ttb,
    spacing: 0.9em,
    block(
      width: 100%,
      fill: palette.tint,
      radius: (top-right: 3pt, bottom-right: 3pt),
      inset: 8pt,
      stroke: (left: 2.6pt + palette.accent),
    )[
      #grid(
        columns: (auto, 1fr, auto),
        column-gutter: 8pt,
        align: horizon,
        box(fill: palette.accent, inset: (x: 6pt, y: 2.5pt), radius: 999pt)[
          #text(fill: white, size: 0.78em, weight: 700)[Domanda #n]
        ],
        text(weight: 700, size: 12pt, fill: palette.ink)[#titolo],
        text(weight: 700, fill: palette.accent-dark)[#punti punti],
      )
    ],
    corpo,
    v(0.75cm),
    righe-risposta(righe),
  )
]

#let esercizio(n, titolo, punti, diff, corpo) = [
  #block(
    width: 100%,
    fill: palette.tint,
    radius: (top-right: 3pt, bottom-right: 3pt),
    inset: 8pt,
    stroke: (left: 2.6pt + palette.accent),
    below: 0.9em,
  )[
    #grid(
      columns: (auto, 1fr, auto, auto),
      column-gutter: 8pt,
      align: horizon,
      box(fill: palette.accent, inset: (x: 6pt, y: 2.5pt), radius: 999pt)[
        #text(fill: white, size: 0.78em, weight: 700)[Esercizio #n]
      ],
      text(weight: 700, size: 12pt, fill: palette.ink)[#titolo],
      stelle(diff),
      text(weight: 700, fill: palette.accent-dark)[#punti punti],
    )
  ]
  #corpo
]

#let lettura(n, titolo, punti, diff, righe, corpo) = block(
  breakable: false,
  width: 100%,
)[
  #stack(
    dir: ttb,
    spacing: 0.9em,
    block(
      width: 100%,
      fill: palette.tint,
      radius: (top-right: 3pt, bottom-right: 3pt),
      inset: 8pt,
      stroke: (left: 2.6pt + palette.accent),
    )[
      #grid(
        columns: (auto, 1fr, auto, auto),
        column-gutter: 8pt,
        align: horizon,
        box(fill: palette.accent, inset: (x: 6pt, y: 2.5pt), radius: 999pt)[
          #text(fill: white, size: 0.78em, weight: 700)[Snippet #n]
        ],
        text(weight: 700, size: 12pt, fill: palette.ink)[#titolo],
        stelle(diff),
        text(weight: 700, fill: palette.accent-dark)[#punti punti],
      )
    ],
    corpo,
    v(0.75cm),
    righe-risposta(righe),
  )
]

// ------------------------------------------------------------
//  Cover
// ------------------------------------------------------------

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
    spacing: 0.4em,
    etichetta(nome),
    line(length: 100%, stroke: 0.6pt + luma(170)),
  )

  let dato(titolo, valore) = stack(
    dir: ttb,
    spacing: 0.6em,
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
      #v(0.7cm)
      #if top != none [
        #text(
          size: 9pt,
          weight: 700,
          tracking: 0.18em,
          fill: palette.accent,
        )[#top]
      ]
      #v(11pt)
      #if title != none [
        #text(size: 28pt, weight: 800, fill: palette.ink)[#title]
      ]
      #v(2pt)
      #if subtitle != none [
        #text(size: 14pt, fill: luma(110))[#subtitle]
      ]
      #v(0.55cm)
      #if decoration-content != none [
        #decoration-content
      ]
      #v(0.6cm)
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
      #v(0.75cm)
    ]

    #if fields.len() > 0 [
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 18pt,
        row-gutter: 28pt,
        ..fields.map(field => campo(
          student-labels.at(field, default: upper(field)),
        )),
      )
    ]

    #if body != none [
      #v(0.7cm)
      #body
    ]
  ]
}
