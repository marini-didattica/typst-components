// Correction blocks: student answers, comments and missing answers.

#import "../theme/labels.typ": sezione-corrente
#import "../theme/spacing.typ": spazio
#import "blocchi.typ": sezione-blocco
#import "riepilogo.typ": registro-risposte
#import "testata.typ": testata

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
    #sezione-blocco(
      "Risposta",
      if corpo == none { nessuna-risposta } else { corpo },
    )
  ]
}

/// Small comment shown under a corrected answer.
#let commento(corpo) = block(
  breakable: false,
  width: 100%,
  fill: luma(248),
  stroke: (left: 2pt + luma(185)),
  inset: (x: 9pt, y: 6pt),
  above: spazio.md,
  below: spazio.md,
)[
  #text(fill: luma(85))[
    #text(weight: 700)[Commento.] #corpo
  ]
]
