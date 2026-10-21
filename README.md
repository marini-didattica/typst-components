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

// The summary can be placed before the questions: it reads the final state.
#griglia-punteggi(titolo: "Riepilogo dei punteggi")

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
```

`quesito` automatically numbers items per `category` (`D1`, `D2`, `E1`, …) and
registers each item in a document-global state. `griglia-punteggi()` reads that
state with `state.final()`, so it can be placed before the questions, after
them, or anywhere in between. It groups rows by the last level-1 heading, so the
section titles and totals do not have to be repeated by hand. Pass `titolo:` to
add an unnumbered title above the table, or `voci:` to render an explicit list
of items instead of the automatic registry.

## Corrections

`risposta` has the same fields as `quesito`, plus `score` (points awarded):

```typ
#import "../typst-components/src/lib.typ": (
  intestazione-correzione, risposta, commento, griglia-correzione,
)

#intestazione-correzione(
  "Mario Rossi",
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

`intestazione-correzione` computes the total and the maximum from all `risposta`
calls with `state.final()`, so the score at the top of the page matches
`griglia-correzione()`. Pass `totale:` or `massimo:` explicitly only to override
the computed values.

`griglia-correzione()` shows awarded/max for every item, the total and the grade
in tenths. Like `griglia-punteggi()`, it reads the final registry, so it can be
placed before the answers or at the end. Pass `titolo:` for an unnumbered title
and `voci:` for an explicit list. By default the first 100 points map to 10/10
and the remaining 10 points count as lode; pass `base:` to change the threshold.

Compile from the project root with `--root .` so the components can import the
sibling theme package.

## Development

Check out both repositories side by side. The `materiale` repository consumes
them as git submodules; `misc` and `riservato` are legacy.
