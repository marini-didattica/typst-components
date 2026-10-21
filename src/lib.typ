// typst-components — reusable blocks built on top of typst-theme.

#import "../../typst-theme/src/lib.typ": etichetta, font-mono, palette, sezione-corrente, spazio

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
  row-gutter: spazio.page.lg,
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
  spacing: spazio.sm,
  etichetta(titolo),
  corpo,
)

#let nota(corpo) = block(
  width: 100%,
  fill: palette.amber-tint,
  stroke: (left: 2.6pt + palette.amber),
  radius: (top-right: 3pt, bottom-right: 3pt),
  inset: (x: 10pt, y: spazio.page.sm),
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
  radius: (top-right: 3pt, bottom-right: 3pt),
  inset: (x: 11pt, y: 9pt),
)[
  #stack(
    dir: ttb,
    spacing: spazio.md,
    text(weight: 800, fill: palette.accent-dark, size: 11.5pt)[#titolo],
    corpo,
  )
]

#let checklist(titolo, items) = block(
  breakable: false,
  width: 100%,
  fill: palette.tint,
  stroke: 0.6pt + luma(222),
  radius: 3pt,
  inset: 10pt,
)[
  #stack(
    dir: ttb,
    spacing: spazio.md,
    text(weight: 800, fill: palette.accent-dark)[#titolo],
    list(..items),
  )
]

// ------------------------------------------------------------
//  Question / exercise components
// ------------------------------------------------------------

/// Format a score using the Italian decimal comma.
#let fmt-punti(x) = str(x).replace(".", ",")

/// Format a grade in tenths with one decimal digit.
#let fmt-voto(x) = fmt-punti(calc.round(x, digits: 1))

/// Placeholder shown when a student did not submit an answer.
#let nessuna-risposta = block(
  width: 100%,
  fill: luma(249),
  stroke: (paint: luma(195), thickness: 0.6pt, dash: "dotted"),
  radius: 3pt,
  inset: (x: 10pt, y: 8pt),
)[
  #text(fill: luma(125), style: "italic")[Nessuna risposta consegnata.]
]

/// Items registered by `quesito`, grouped automatically by section.
#let registro-quesiti = state("registro-quesiti", ())

/// Items registered by `risposta`, grouped automatically by section.
#let registro-risposte = state("registro-risposte", ())

#let raggruppa-per-sezione(voci) = {
  let gruppi = ()
  for voce in voci {
    let key = repr(voce.heading)
    let idx = gruppi.position(g => g.key == key)
    if idx == none {
      gruppi = gruppi + ((key: key, titolo: voce.heading, voci: (voce,)),)
    } else {
      let gruppo = gruppi.at(idx)
      let aggiornato = (
        key: key,
        titolo: gruppo.titolo,
        voci: gruppo.voci + (voce,),
      )
      gruppi = gruppi.slice(0, idx) + (aggiornato,) + gruppi.slice(idx + 1)
    }
  }
  gruppi
}

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
    fill: palette.tint,
    radius: (top-right: 3pt, bottom-right: 3pt),
    inset: spazio.page.sm,
    stroke: (left: 2.6pt + palette.accent),
  )[
    #grid(
      columns: if diff == none { (auto, 1fr, auto) } else { (auto, 1fr, auto, auto) },
      column-gutter: 8pt,
      align: horizon,
      ..celle,
    )
  ]
}

/// Single component for theory questions, exercises and code snippets.
///
/// - `category`: short code used in the summary (e.g. `"D"`, `"E"`, `"S"`)
/// - `tag`: label shown in the badge (e.g. `"Domanda"`)
/// - `title`: item title
/// - `diff`: number of difficulty stars, or `none`
/// - `points`: maximum score
/// - `righe`: number of answer lines, or `none`
/// - `numero`: explicit number; when `auto` a counter per category is used
#let quesito(
  corpo,
  category: "D",
  tag: "Domanda",
  title: none,
  diff: none,
  points: 0,
  righe: none,
  numero: auto,
) = {
  let contatore = counter("quesito-" + category)
  if numero == auto { contatore.step() }

  context {
    let n = if numero == auto { contatore.get().first() } else { numero }
    let sezione = sezione-corrente.get()
    registro-quesiti.update(voci => (
      voci
        + (
          (
            category: category,
            tag: tag,
            title: title,
            max: points,
            numero: n,
            heading: sezione,
          ),
        )
    ))
  }

  let etichetta-numero = if numero == auto {
    context contatore.display()
  } else {
    numero
  }

  let contenuto = [
    #testata(tag, etichetta-numero, title, diff: diff, massimo: points)
    #v(spazio.sm)
    #corpo
    #if righe != none [
      #v(spazio.page.xl)
      #righe-risposta(righe)
    ]
  ]

  if righe == none {
    block(above: spazio.xl, width: 100%)[#contenuto]
  } else {
    block(above: spazio.xl, breakable: false, width: 100%)[#contenuto]
  }
}

/// Answer component used in corrections. Same fields as `quesito`, plus
/// `score` (points awarded).
#let risposta(
  corpo,
  category: "D",
  tag: "Domanda",
  title: none,
  diff: none,
  points: 0,
  score: 0,
  numero: auto,
) = {
  let contatore = counter("risposta-" + category)
  if numero == auto { contatore.step() }

  context {
    let n = if numero == auto { contatore.get().first() } else { numero }
    let sezione = sezione-corrente.get()
    registro-risposte.update(voci => (
      voci
        + (
          (
            category: category,
            tag: tag,
            title: title,
            max: points,
            got: score,
            numero: n,
            heading: sezione,
          ),
        )
    ))
  }

  let etichetta-numero = if numero == auto {
    context contatore.display()
  } else {
    numero
  }

  block(above: spazio.lg, breakable: false, width: 100%)[
    #testata(
      tag,
      etichetta-numero,
      title,
      diff: diff,
      massimo: points,
      ottenuto: score,
    )
    #v(spazio.sm)
    #sezione(
      "Risposta",
      if corpo == none { nessuna-risposta } else { corpo },
    )
  ]
}

// Backward-compatible wrappers for existing documents.
#let domanda(n, titolo, punti, righe, corpo) = quesito(
  corpo,
  category: "D",
  tag: "Domanda",
  title: titolo,
  points: punti,
  righe: righe,
  numero: n,
)

#let esercizio(n, titolo, punti, diff, corpo) = quesito(
  corpo,
  category: "E",
  tag: "Esercizio",
  title: titolo,
  diff: diff,
  points: punti,
  numero: n,
)

#let lettura(n, titolo, punti, diff, righe, corpo) = quesito(
  corpo,
  category: "S",
  tag: "Snippet",
  title: titolo,
  diff: diff,
  points: punti,
  righe: righe,
  numero: n,
)

#let risposta-domanda(n, titolo, punti, totale, corpo) = risposta(
  corpo,
  category: "D",
  tag: "Domanda",
  title: titolo,
  points: totale,
  score: punti,
  numero: n,
)

#let risposta-esercizio(n, titolo, punti, totale, diff, corpo) = risposta(
  corpo,
  category: "E",
  tag: "Esercizio",
  title: titolo,
  diff: diff,
  points: totale,
  score: punti,
  numero: n,
)

#let risposta-snippet(n, titolo, punti, totale, diff, corpo) = risposta(
  corpo,
  category: "S",
  tag: "Snippet",
  title: titolo,
  diff: diff,
  points: totale,
  score: punti,
  numero: n,
)

/// Small comment shown under a corrected answer.
#let commento(corpo) = block(
  breakable: false,
  width: 100%,
  fill: luma(248),
  stroke: (left: 2pt + luma(185)),
  inset: (x: 9pt, y: 6pt),
  above: spazio.sm,
  below: spazio.md,
)[
  #text(fill: luma(85))[
    #text(weight: 700)[Commento.] #corpo
  ]
]

/// Totals computed from every `risposta` in the document.
///
/// Uses `state.final()` so it can be called before the answers are laid out.
/// Pass `voci:` to use an explicit list instead.
#let totali-risposte(voci: auto) = {
  let voci = if voci == auto { registro-risposte.final() } else { voci }
  (
    voci: voci,
    totale: voci.fold(0, (acc, voce) => acc + voce.got),
    massimo: voci.fold(0, (acc, voce) => acc + voce.max),
  )
}

/// Totals computed from every `quesito` in the document.
///
/// Uses `state.final()` so it can be called before the questions are laid out.
/// Pass `voci:` to use an explicit list instead.
#let totali-quesiti(voci: auto) = {
  let voci = if voci == auto { registro-quesiti.final() } else { voci }
  (
    voci: voci,
    totale: voci.fold(0, (acc, voce) => acc + voce.max),
  )
}

/// Header for a correction sheet.
///
/// `totale` and `massimo` default to `auto`: the values are computed from all
/// `risposta` calls in the document.
#let intestazione-correzione(
  studente,
  totale: auto,
  title: "Correzione verifica",
  subtitle: "",
  massimo: auto,
  base: 100,
  voci: auto,
) = context {
  let dati = totali-risposte(voci: voci)
  let tot = if totale == auto { dati.totale } else { totale }
  let max = if massimo == auto { dati.massimo } else { massimo }
  let voto = calc.min(tot, base) / 10
  let lode = tot > base

  block(
    width: 100%,
    fill: palette.tint,
    stroke: (left: 2.6pt + palette.accent),
    radius: (top-right: 3pt, bottom-right: 3pt),
    inset: (x: 12pt, y: 10pt),
    below: spazio.lg,
  )[
    #grid(
      columns: (1fr, auto),
      column-gutter: 14pt,
      align: horizon,
      stack(
        dir: ttb,
        spacing: spazio.lg,
        etichetta(title),
        text(size: 18pt, weight: 800, fill: palette.ink)[#studente],
        text(size: 9.5pt, fill: luma(110))[#subtitle],
      ),
      align(right)[
        #stack(
          dir: ttb,
          spacing: spazio.lg,
          etichetta("Punteggio"),
          text(size: 19pt, weight: 800, fill: palette.accent-dark)[
            #fmt-punti(tot) / #fmt-punti(max)
          ],
          text(size: 10.5pt, weight: 700)[
            Voto #fmt-voto(voto) / 10 #if lode [ e lode]
          ],
        )
      ],
    )
  ]
}

/// Unnumbered section title for a score table.
#let titolo-griglia(titolo) = block(
  below: spazio.md,
  width: 100%,
)[
  #stack(
    dir: ttb,
    spacing: spazio.page.md,
    text(size: 17pt, weight: 800, fill: palette.ink)[#titolo],
    line(length: 100%, stroke: 2.2pt + palette.accent),
  )
]

/// Render a score table from a list of registered items.
///
/// With `correzione: false` each row shows the maximum score; with
/// `correzione: true` it shows awarded/max and adds the grade row.
/// Pass `titolo:` to add an unnumbered title above the table.
#let griglia-voci(
  voci,
  correzione: false,
  base: 100,
  titolo: none,
) = {
  let gruppi = raggruppa-per-sezione(voci)
  let massimo = voci.fold(0, (acc, voce) => acc + voce.max)
  let totale = if correzione {
    voci.fold(0, (acc, voce) => acc + voce.got)
  } else {
    massimo
  }
  let voto = calc.min(totale, base) / 10
  let lode = totale > base

  let righe = gruppi
    .map(gruppo => {
      let titolo = if gruppo.titolo == none { "Quesiti" } else { gruppo.titolo }
      let header = table.cell(
        colspan: 3,
        fill: palette.tint,
        inset: (x: 9pt, y: 6pt),
        align: left,
      )[#text(weight: 800, fill: palette.accent-dark)[#titolo]]
      let corpo = gruppo
        .voci
        .map(voce => (
          [#(voce.category + str(voce.numero))],
          if voce.title == none { [] } else { voce.title },
          if correzione {
            text(weight: 700)[#fmt-punti(voce.got) / #fmt-punti(voce.max)]
          } else {
            text(weight: 700)[#fmt-punti(voce.max)]
          },
        ))
        .flatten()
      (header,) + corpo
    })
    .flatten()

  let footer = if correzione {
    (
      table.cell(colspan: 2, align: right)[*Totale*],
      text(weight: 800)[#fmt-punti(totale) / #fmt-punti(massimo)],
      table.cell(colspan: 2, align: right)[*Voto in decimi*],
      text(weight: 800)[#fmt-voto(voto) / 10 #if lode [ e lode]],
    )
  } else {
    (
      table.cell(colspan: 2, align: right)[*Totale*],
      text(weight: 800)[#fmt-punti(totale) punti],
    )
  }

  block(above: spazio.xl, below: spazio.lg, breakable: false, width: 100%)[
    #if titolo != none {
      titolo-griglia(titolo)
    }
    #table(
      columns: (auto, 1fr, auto),
      inset: (x: 9pt, y: 5pt),
      align: (left, left, right),
      stroke: 0.5pt + luma(215),
      table.header([*Voce*], [*Dettaglio*], [*Punteggio*]),
      ..righe,
      ..footer,
    )
  ]
}

/// Automatic summary of a test: one row per item and the sum of the points.
///
/// Can be placed before the questions: the registry is read with
/// `state.final()`. Pass `voci:` to render an explicit list instead and
/// `titolo:` to add an unnumbered title above the table.
#let griglia-punteggi(voci: auto, titolo: none) = context {
  griglia-voci(totali-quesiti(voci: voci).voci, titolo: titolo)
}

/// Automatic summary of a correction: awarded/max per item, total and grade.
///
/// Can be placed before the answers: the registry is read with
/// `state.final()`. Pass `voci:` to render an explicit list instead and
/// `titolo:` to add an unnumbered title above the table.
#let griglia-correzione(voci: auto, base: 100, titolo: none) = context {
  griglia-voci(
    totali-risposte(voci: voci).voci,
    correzione: true,
    base: base,
    titolo: titolo,
  )
}

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
      ]
      #v(spazio.page.md)
      #if title != none [
        #text(size: 28pt, weight: 800, fill: palette.ink)[#title]
      ]
      #v(spazio.page.xs)
      #if subtitle != none [
        #text(size: 14pt, fill: luma(110))[#subtitle]
      ]
      #v(spazio.page.lg)
      #if decoration-content != none [
        #decoration-content
      ]
      #v(spazio.page.lg)
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
      #v(spazio.page.xl)
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
      #v(spazio.page.xl)
      #body
    ]
  ]
}
