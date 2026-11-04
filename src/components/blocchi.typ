// Small labelled blocks used by questions and generated exams.

#import "../theme/palette.typ": palette
#import "../theme/spacing.typ": spazio
#import "../theme/labels.typ": etichetta
#import "nomi-file.typ": nome-file
#import "testata.typ": testata

/// Internal labelled block used by templates and answers.
#let sezione-blocco(titolo, corpo) = stack(
  dir: ttb,
  spacing: spazio.md,
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
  #sezione-blocco("Template di partenza", codice)
]

#let esempi(righe) = block(breakable: false)[
  #sezione-blocco(
    "Esempi di input e output",
    block(
      radius: 3pt,
      clip: true,
      stroke: 0.5pt + luma(195),
    )[
      #table(
        columns: (auto, auto, 1fr),
        inset: (x: 8pt, y: 5pt),
        align: (left, left, left),
        stroke: 0.5pt + luma(215),
        table.header([*Input*], [*Output*], [*Spiegazione*]),
        ..righe.flatten(),
      )],
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

/// Standard delivery instructions for generated exams.
///
/// `categories` is the resolved category list of the exam. When provided, the
/// callout adds the table of files the students must submit, generated from
/// each category's title and each exercise's tag and number.
#let istruzioni-consegna(
  categories: (),
  titolo: "Istruzioni per la consegna",
) = {
  let righe = ()
  for category in categories {
    if category.exercises.len() > 0 {
      let files = category
        .exercises
        .map(exercise => raw(nome-file(exercise)))
        .join(", ")
      righe = righe + ((category.title, files),)
    }
  }

  callout(titolo)[
    - Aprite il *file explorer* (icona cartella sulla barra degli strumenti in basso) e navigate nella cartella `Questo Pc -> temi_xx`.

    - Create una nuova cartella, denominata `cognome-nome`, *tutto minuscolo*. Se avete più nomi o più cognomi, metteteli tutti, concatenati dal carattere
      `-` (trattino). Ad esempio:

      #box(fill: luma(255), inset: 9pt, radius: 3pt)[
        #block(
          radius: 3pt,
          clip: true,
          stroke: 0.5pt + luma(195),
        )[
          #table(
            columns: (auto, 1fr),
            inset: (x: 9pt, y: 6pt),
            align: left,
            stroke: 0.5pt + luma(215),
            table.header([*Vostro nome*], [*Nome cartella*]),
            [Marini Mattia], [`marini-mattia`],
            [Olaizola Elisa Maitea], [`olaizola-elisa-maitea`],
          )
        ]
      ]

    - Dentro a questa cartella, va creato *un file per ciascun esercizio*. Il nome del file è quello indicato
      nell'intestazione dell'esercizio, trasformato in modo che sia *tutto minuscolo e senza
      spazi*: l'estensione deve essere `.py` per gli esercizi di programmazione e `.txt` per le
      risposte alle domande e agli snippet.


      #box(fill: luma(255), inset: 9pt, radius: 3pt)[
        #testata("Esercizio", 1, "Esempio esercizio")
        #v(0.5em)
        #text(size: 8.5pt, fill: luma(120), style: "italic")[
          Ad esempio, per questo esercizio va creato un file `esercizio1.py`
        ]
      ]

    #if righe.len() > 0 [
      Per questa prova nello specifico mi aspetto che consegniate i seguenti file:

      #box(fill: luma(255), inset: 9pt, radius: 3pt)[
        #block(
          radius: 3pt,
          clip: true,
          stroke: 0.5pt + luma(195),
        )[
          #table(
            columns: (auto, 1fr),
            inset: (x: 9pt, y: 6pt),
            align: left,
            stroke: 0.5pt + luma(215),
            table.header([*Parte*], [*File da consegnare*]),
            ..righe.flatten(),
          )
        ]
      ]
    ]
  ]
}

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
