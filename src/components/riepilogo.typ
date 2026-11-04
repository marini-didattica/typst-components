// Registries and automatic score summaries.

#import "../theme/palette.typ": palette
#import "../theme/spacing.typ": spazio
#import "../theme/labels.typ": etichetta
#import "nomi-file.typ": nome-risposta
#import "punteggi.typ": fmt-punti, fmt-voto, calcola-voto

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
  voto-min: 3,
  voto-max: 10,
  lode-soglia: auto,
  voci: auto,
) = context {
  let dati = totali-risposte(voci: voci)
  let tot = if totale == auto { dati.totale } else { totale }
  let max = if massimo == auto { dati.massimo } else { massimo }
  let voto = calcola-voto(tot, base: base, voto-min: voto-min, voto-max: voto-max)
  let lode = if lode-soglia == auto { tot > base } else { tot > lode-soglia }

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
  voto-min: 3,
  voto-max: 10,
  lode-soglia: auto,
  titolo: none,
) = {
  let gruppi = raggruppa-per-sezione(voci)
  let massimo = voci.fold(0, (acc, voce) => acc + voce.max)
  let totale = if correzione {
    voci.fold(0, (acc, voce) => acc + voce.got)
  } else {
    massimo
  }
  let voto = calcola-voto(totale, base: base, voto-min: voto-min, voto-max: voto-max)
  let lode = if lode-soglia == auto { totale > base } else { totale > lode-soglia }

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
    #block(
      radius: 3pt,
      clip: true,
      stroke: 0.5pt + luma(195),
    )[
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

/// Summary table built directly from resolved exam data.
///
/// `categories` is an array of dictionaries with `id`, `title`, and
/// `exercises`. Each exercise must contain `numero`, `title`, and `points`.
/// The answer file is taken from `answer-file` when present, otherwise it is
/// derived from the badge tag and number. Section rows use `category.title`
/// from the descriptor; nothing is derived from the document's heading state.
#let griglia-voti2(categories, titolo: none) = {
  let righe = ()
  let totale = 0

  for category in categories {
    let category-points = category.exercises.fold(0, (acc, exercise) => acc + exercise.points)
    totale = totale + category-points

    righe = righe + (table.cell(
      colspan: 4,
      fill: palette.tint,
      inset: (x: 9pt, y: 6pt),
      align: left,
    )[#text(weight: 800, fill: palette.accent-dark)[#category.title]],)

    for exercise in category.exercises {
      righe = righe + (
        [#(category.id + str(exercise.numero))],
        exercise.title,
        raw(nome-risposta(exercise, padding: 2)),
        text(weight: 700)[#fmt-punti(exercise.points)],
      )
    }
  }

  let footer = (
    table.cell(colspan: 3, align: right)[*Totale*],
    text(weight: 800)[#fmt-punti(totale) punti],
  )

  block(above: spazio.xl, below: spazio.lg, breakable: false, width: 100%)[
    #if titolo != none {
      titolo-griglia(titolo)
    }
    #block(
      radius: 3pt,
      clip: true,
      stroke: 0.5pt + luma(195),
    )[
      #table(
        columns: (auto, 1fr, auto, auto),
        inset: (x: 9pt, y: 5pt),
        align: (left, left, left, right),
        stroke: 0.5pt + luma(215),
        table.header([*Voce*], [*Dettaglio*], [*File risposta*], [*Punteggio*]),
        ..righe,
        ..footer,
      )
    ]
  ]
}

/// Summary table for a JSON-driven correction.
///
/// `categories` uses the same shape as the exam summary, with each exercise
/// also containing `score` and `answer-file`.
#let griglia-correzioni2(
  categories,
  base: 100,
  voto-min: 3,
  voto-max: 10,
  lode-soglia: auto,
  titolo: none,
) = {
  let righe = ()
  let totale = 0
  let massimo = 0

  for category in categories {
    let category-score = category.exercises.fold(0, (acc, exercise) => acc + exercise.score)
    let category-points = category.exercises.fold(0, (acc, exercise) => acc + exercise.points)
    totale = totale + category-score
    massimo = massimo + category-points

    righe = righe + (table.cell(
      colspan: 4,
      fill: palette.tint,
      inset: (x: 9pt, y: 6pt),
      align: left,
    )[#text(weight: 800, fill: palette.accent-dark)[#category.title]],)

    for exercise in category.exercises {
      righe = righe + (
        [#(category.id + str(exercise.numero))],
        exercise.title,
        raw(exercise.answer-file),
        text(weight: 700)[
          #fmt-punti(exercise.score) / #fmt-punti(exercise.points)
        ],
      )
    }
  }

  let voto = calcola-voto(totale, base: base, voto-min: voto-min, voto-max: voto-max)
  let lode = if lode-soglia == auto { totale > base } else { totale > lode-soglia }

  let footer = (
    table.cell(colspan: 2, align: right)[*Totale*],
    table.cell(colspan: 2, align: right)[
      #text(weight: 800)[#fmt-punti(totale) / #fmt-punti(massimo)]
    ],
    table.cell(colspan: 3, align: right)[*Voto in decimi*],
    text(weight: 800)[
      #fmt-voto(voto) / #fmt-voto(voto-max) #if lode [ e lode]
    ],
  )

  block(above: spazio.xl, below: spazio.lg, breakable: false, width: 100%)[
    #if titolo != none {
      titolo-griglia(titolo)
    }
    #block(
      radius: 3pt,
      clip: true,
      stroke: 0.5pt + luma(195),
    )[
      #table(
        columns: (auto, 1fr, auto, auto),
        inset: (x: 9pt, y: 5pt),
        align: (left, left, left, right),
        stroke: 0.5pt + luma(215),
        table.header([*Voce*], [*Dettaglio*], [*File risposta*], [*Punteggio*]),
        ..righe,
        ..footer,
      )
    ]
  ]
}

/// Backwards-compatible alias for `griglia-voti2`.
#let griglia-punteggi2(categories, titolo: none) = griglia-voti2(categories, titolo: titolo)

/// Automatic summary of a correction: awarded/max per item, total and grade.
///
/// Can be placed before the answers: the registry is read with
/// `state.final()`. Pass `voci:` to render an explicit list instead and
/// `titolo:` to add an unnumbered title above the table.
#let griglia-correzione(
  voci: auto,
  base: 100,
  voto-min: 3,
  voto-max: 10,
  lode-soglia: auto,
  titolo: none,
) = context {
  griglia-voci(
    totali-risposte(voci: voci).voci,
    correzione: true,
    base: base,
    voto-min: voto-min,
    voto-max: voto-max,
    lode-soglia: lode-soglia,
    titolo: titolo,
  )
}
