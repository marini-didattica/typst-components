// Question header: badge, title, difficulty stars and score.

#import "../theme/palette.typ": palette
#import "../theme/spacing.typ": spazio
#import "punteggi.typ": fmt-punti
#import "stelle.typ": stelle

#let badge(fill: palette.accent, corpo) = box(
  fill: fill,
  inset: (x: 6pt, y: 2.5pt),
  radius: 3pt,
)[#text(fill: white, size: 0.78em, weight: 700)[#corpo]]

#let testata(
  tag,
  numero,
  titolo,
  diff: none,
  massimo: 0,
  ottenuto: none,
  file: none,
) = {
  let left-badge = badge([#tag #numero])

  let testo-titolo = if titolo == none {
    []
  } else {
    text(weight: 700, size: 12pt, fill: palette.ink)[#titolo]
  }

  let testo-punti = if ottenuto == none {
    text(weight: 700, fill: palette.accent-dark)[#fmt-punti(massimo) punti]
  } else {
    text(weight: 700, fill: palette.accent-dark)[
      #fmt-punti(ottenuto) / #fmt-punti(massimo) punti
    ]
  }

  let celle = if diff == none {
    (left-badge, testo-titolo, testo-punti)
  } else {
    (left-badge, testo-titolo, stelle(diff), testo-punti)
  }

  block(
    width: 100%,
    above: 0pt,
    below: 0pt,
    fill: palette.tint,
    radius: (top-right: 3pt, bottom-right: 3pt),
    inset: spazio.page.sm,
    outset: (left: -1.3pt),
    stroke: (left: 2.6pt + palette.accent),
  )[
    #grid(
      columns: if diff == none { (auto, 1fr, auto) } else { (auto, 1fr, auto, auto) },
      column-gutter: 8pt,
      align: horizon,
      ..celle,
    )
  ]

  if file != none {
    v(spazio.sm)
    text(size: 8.5pt, fill: luma(120), style: "italic")[
      Consegna questo esercizio nel file #raw(file)
    ]
  }
}
