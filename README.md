# typst-components

Reusable blocks for the Liceo Russell Typst materials, built on top of
[`typst-theme`](https://github.com/marini-didattica/typst-theme).

Main exports:

- `quesito` — one component for theory questions, exercises and snippets
- `risposta` — the corresponding correction block
- `griglia-punteggi` — automatic test summary
- `griglia-correzione` — automatic correction summary
- `cover`
- `nota`, `template`, `esempi`
- `callout`, `checklist`, `consegna`
- `stelle`, `righe-risposta`
- `nessuna-risposta`, `commento`, `intestazione-correzione`

The old `domanda`, `esercizio`, `lettura`, `risposta-domanda`,
`risposta-esercizio` and `risposta-snippet` names remain as compatibility
wrappers.

## Usage

The theme must be available as a sibling directory (or git submodule):

```text
project/
├── typst-theme/
└── typst-components/
```

```typ
#import "../typst-theme/src/lib.typ": theme
#import "../typst-components/src/lib.typ": cover, quesito, griglia-punteggi

#show: doc => theme(doc, footer-text: "Verifica di informatica")

#cover(
  title: "Simulazione verifica 1",
  descriptors: (("Durata", "80 minuti"),),
)

= Teoria (20 punti)

#quesito(
  category: "D",
  tag: "Domanda",
  title: [Le componenti di un computer],
  points: 7,
  righe: 6,
)[
  Descrivi le principali componenti di un personal computer.
]

= Scrittura del codice (60 punti)

#quesito(
  category: "E",
  tag: "Esercizio",
  title: [Conta i numeri pari],
  points: 10,
  diff: 1,
)[
  #consegna[Conta i numeri pari fra `0` e `n`.]
]

= Riepilogo dei punteggi

#griglia-punteggi()
```

`quesito` automatically numbers items per `category` (`D1`, `D2`, `E1`, …) and
registers each item in a document-global state. `griglia-punteggi()` reads that
state and groups rows by the last level-1 heading, so the section titles and
totals do not have to be repeated by hand.

## Corrections

`risposta` has the same fields as `quesito`, plus `score` (points awarded):

```typ
#import "../typst-components/src/lib.typ": (
  intestazione-correzione, risposta, commento, griglia-correzione,
)

#intestazione-correzione(
  "Mario Rossi",
  87,
  title: "Correzione — Simulazione 1",
  subtitle: "Classe 1D",
)

= Teoria (20 punti)

#risposta(
  category: "D",
  tag: "Domanda",
  title: [Le componenti di un computer],
  points: 7,
  score: 6,
)[
  La risposta dello studente.
]
#commento[Corretto, ma manca una componente.]

= Riepilogo dei punteggi

#griglia-correzione()
```

If an answer is missing, pass `none` as the first positional argument (for
example `#risposta(none, category: "D", ..., points: 7, score: 0)`); the
component shows a dotted placeholder.

`griglia-correzione()` shows awarded/max for every item, the total and the grade
in tenths. By default the first 100 points map to 10/10 and the remaining 10
points count as lode; pass `base:` to change the threshold.

Compile from the project root with `--root .` so the components can import the
sibling theme package.

## Development

Check out both repositories side by side. The `misc` and `riservato`
repositories consume them as git submodules.
