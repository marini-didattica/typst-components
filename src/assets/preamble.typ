// Shared exam preamble content. The exam renderer includes this file after
// the automatic cover and before the delivery instructions.

#import "../theme/lib.typ": palette, spazio

#block(
  width: 100%,
  fill: palette.tint,
  stroke: (left: 2.6pt + palette.accent),
  radius: (top-right: 3pt, bottom-right: 3pt),
  inset: (x: 11pt, y: 9pt),
)[
  #text(weight: 800, fill: palette.accent-dark, size: 11.5pt)[Istruzioni generali]
  #v(spazio.md)
  - Per gli esercizi scrivi un programma in *Python*, in un file separato. Sono valutate la
    correttezza, la gestione dei casi limite e la chiarezza del codice.
  - Nella parte di lettura spiega a parole che cosa fa ciascun frammento e riporta il suo
    output, senza riscrivere il codice.
  - Il programma deve stampare *soltanto* il risultato richiesto e non deve chiedere dati con
    `input()`: usa le variabili già presenti nel template.
  - Non è consentito consultare appunti, libri o Internet. È possibile usare il *cheatsheet*
    messo a disposizione.
]
