// Small labelled blocks used by questions and generated exams.

#import "../theme/palette.typ": palette
#import "../theme/spacing.typ": spazio
#import "../theme/labels.typ": etichetta

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
#let istruzioni-consegna(titolo: "Istruzioni per la consegna") = callout(titolo)[
  - Crea una cartella `cognome-nome`, tutto minuscolo. Se hai più nomi o più cognomi,
    mettili tutti, concatenati dal carattere `-`.
  - Crea un file per ciascun esercizio. Il nome è quello indicato nell'intestazione,
    tutto minuscolo e senza spazi: estensione `.py` per gli esercizi di programmazione,
    `.txt` per le risposte alle domande e agli snippet.
  - Non modificare i file di partenza e non consegnare cartelle compresse.
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
