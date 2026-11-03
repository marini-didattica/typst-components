// Cover page for programme documents.

#import "../../theme/palette.typ": palette-didattica, font-sans
#import "../../theme/spacing.typ": spazio-didattica
#import "../../theme/labels.typ": etichetta

#let copertina-programma(
  classe: none,
  docente: none,
  anno-scolastico: none,
  ore-annue: none,
  ore-consuntivo: "/",
  materia: "Informatica",
  indirizzo: "Liceo Scientifico – Opzione Scienze Applicate",
  istituto: "LICEO B. RUSSELL",
  sede: "Via IV Novembre 35 – 38023 Cles",
  titolo: "PROGRAMMAZIONE DIDATTICA",
) = {
  let obbligatorio(nome, valore) = {
    if valore == none {
      panic("copertina-programma: argomento obbligatorio mancante: " + nome)
    }
  }

  obbligatorio("classe", classe)
  obbligatorio("docente", docente)
  obbligatorio("anno-scolastico", anno-scolastico)
  obbligatorio("ore-annue", ore-annue)

  let etichetta-copertina(txt) = etichetta(
    txt,
    font: font-sans,
    size: 10pt,
    weight: 400,
    tracking: 0.16em,
    fill: palette-didattica.muted,
    maiuscolo: false,
  )

  let dato(
    etichetta-testo,
    valore,
    dimensione: 14pt,
    peso: 400,
    colore: palette-didattica.ink,
  ) = stack(
    dir: ttb,
    spacing: spazio-didattica.sm,
    etichetta-copertina(etichetta-testo),
    text(size: dimensione, weight: peso, fill: colore)[#valore],
  )

  align(center)[
    #text(
      font: font-sans,
      size: 10pt,
      tracking: 0.16em,
      fill: palette-didattica.muted,
    )[#istituto]
    #v(spazio-didattica.xs)
    #text(
      size: 10pt,
      fill: palette-didattica.muted,
      tracking: 0.16em,
    )[#sede]
  ]

  v(spazio-didattica.lg)
  align(center)[#line(length: 5em, stroke: 1pt + palette-didattica.accent)]
  v(spazio-didattica.lg)

  align(center)[
    #block[#text(
      font: font-sans,
      size: 10pt,
      tracking: 0.16em,
      fill: palette-didattica.accent,
    )[#titolo]]
    #v(spazio-didattica.md)
    #block[#text(size: 38pt, weight: 700)[#materia]]
    #v(spazio-didattica.md)
    #block[#text(size: 14pt)[Classe *#classe*]]
    #v(spazio-didattica.md)
    #block[#text(fill: palette-didattica.muted)[#indirizzo]]
  ]

  v(spazio-didattica.xl)

  grid(
    columns: (1fr, 1fr),
    align: center,
    row-gutter: spazio-didattica.page.sm,
    dato("DOCENTE", docente),
    dato("ANNO SCOLASTICO", anno-scolastico),
    dato("ORE ANNUE", ore-annue, dimensione: 30pt, peso: 700),
    dato(
      "ORE A CONSUNTIVO",
      ore-consuntivo,
      dimensione: 30pt,
      peso: 700,
      colore: palette-didattica.accent,
    ),
  )

  v(spazio-didattica.lg)
  v(1fr)

  align(center)[#line(
    length: 100%,
    stroke: 0.5pt + palette-didattica.rule,
  )]
  v(spazio-didattica.page.xs)
  align(center)[
    #text(
      font: font-sans,
      size: 10pt,
      tracking: 0.14em,
      fill: palette-didattica.muted,
    )[A.S. #anno-scolastico]
  ]
}
