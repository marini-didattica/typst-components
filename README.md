# typst-components

Shared visual identity, reusable blocks and document templates for the Liceo
Russell Typst materials.

This package merges the former `typst-theme` and `typst-components`
repositories. The theme is no longer a separate dependency: colours, spacing,
labels, page setup and document templates all live here.

JSON-generated exams no longer ship a shared preamble. The descriptor can point
to an optional `preamble-file`; without it, the renderer goes straight from the
cover to the default delivery-instructions callout.

## What is exported

**Theme**

- `palette`, `palette-didattica` — exam and programme colour presets
- `font-mono`, `font-sans`
- `spazio`, `spazio-didattica` — vertical rhythm tokens
- `etichetta` — configurable uppercase/small-caps label
- `sezione-corrente` — running level-1 heading state
- `theme` — exam page/typography/heading show rule
- `tema-didattica` — programme page/typography show rule

**Exam components**

- `quesito`, `quesito2` — theory questions, exercises and snippets; `quesito2` also shows the answer file name
- `render-exam` — load and render one set from a JSON exam descriptor
- `istruzioni-consegna`, `risposta`, `commento`, `nessuna-risposta`
- `griglia-punteggi`, `griglia-punteggi2`, `griglia-correzione`
- `cover`, `nota`, `template`, `esempi`
- `callout`, `checklist`, `consegna`
- `stelle`, `righe-risposta`, `intestazione-correzione`

**Programme components**

- `programma-didattica` — full document template
- `copertina-programma` — cover page
- `quadro`, `sezione` — first-page framework table
- `modulo`, `sottosezione` — teaching modules

The old `domanda`, `esercizio`, `lettura`, `risposta-domanda`,
`risposta-esercizio` and `risposta-snippet` names remain as compatibility
wrappers.

## Layout

```text
typst-components/
├── examples/
│   └── programma.typ
├── src/
│   ├── lib.typ                 # umbrella entry point
│   ├── theme/
│   │   ├── palette.typ
│   │   ├── spacing.typ
│   │   ├── labels.typ
│   │   ├── esame.typ
│   │   ├── didattica.typ
│   │   └── lib.typ
│   ├── components/
│   │   ├── stelle.typ
│   │   ├── righe-risposta.typ
│   │   ├── punteggi.typ
│   │   ├── blocchi.typ
│   │   ├── testata.typ
│   │   ├── quesito.typ
│   │   ├── risposta.typ
│   │   ├── riepilogo.typ
│   │   ├── nomi-file.typ
│   │   ├── compatibilita.typ
│   │   ├── copertina.typ
│   │   └── programma/
│   │       ├── copertina.typ
│   │       ├── quadro.typ
│   │       ├── modulo.typ
│   │       └── lib.typ
│   ├── documents/
│   │   ├── exam.typ
│   │   └── programma.typ
│   └── exam.typ                # compatibility wrapper
└── typst.toml
```

## Usage: exam

The package must be available from the Typst root (as a sibling directory or a
git submodule):

```text
project/
└── typst-components/
```

```typ
#import "/typst-components/src/lib.typ": (
  theme, cover, quesito, griglia-punteggi,
)

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
```

`quesito` automatically numbers items per `category` (`D1`, `D2`, `E1`, …) and
registers each item in a document-global state. `griglia-punteggi()` reads that
state with `state.final()`, so it can be placed before the questions, after
them, or anywhere in between. It groups rows by the last level-1 heading.

## Answer files

Each exercise can declare the name of the file where the answer must be
written:

```json
{
  "id": "E1",
  "file": "domande/E1.typ",
  "answer-file": "esercizio{ordinal}.py",
  "sets": ["a", "b"],
  "title": "Media degli elementi",
  "points": 12,
  "difficulty": 2
}
```

`answer-file` may contain these placeholders:

- `{ordinal}` — position of the exercise inside its category for the current set;
- `{id}` — exercise id from the descriptor (e.g. `E4`);
- `{category}` — category id (e.g. `E`);
- `{tag}` — lowercase badge label (e.g. `esercizio`);
- `{set}` — current exam variant (e.g. `b`).

`{ordinal}` depends on the set: an exercise excluded from a set does not consume
a number. If `answer-file` is omitted, the renderer falls back to the
conventional name derived from the badge tag and number. The answer file is
shown below the question header and in the `griglia-voti2` summary table.

## Usage: programme

```typ
#import "/typst-components/src/lib.typ": (
  programma-didattica, modulo, quadro, sezione, sottosezione,
)

#show: programma-didattica.with(
  classe: "1D",
  docente: "Prof. Mattia Marini",
  anno-scolastico: "2026/27",
  ore-annue: 66,
)

#quadro[
  #sezione("COMPETENZE DA RAGGIUNGERE AL TERMINE DELL’ANNO SCOLASTICO")[
    - Saper analizzare un problema e formulare una soluzione algoritmica.
  ]
  #sezione("METODOLOGIE DIDATTICHE")[
    - Lezione frontale e dialogata.
  ]
]

#modulo("Modulo 1 – Introduzione all’informatica", ore: 5)[
  #sezione("CONOSCENZE E/O CONTENUTI")[
    - Concetto di algoritmo.
  ]
  #sezione("ABILITÀ E COMPETENZE")[
    - Riconoscere i principali componenti hardware.
  ]
]
```

`classe`, `docente`, `anno-scolastico` and `ore-annue` are required. The school
name, address and programme type have defaults; pass `istituto:`, `sede:` and
`indirizzo:` to override them.

`#sezione(...)` registers a row; `#quadro` and `#modulo` consume and clear the
registry after laying out their body. This keeps the source readable while
still producing a real table.

Compile from the project root with `--root .`:

```sh
typst compile --root . content/raw/public/prime/1d/programma.typ
```

## Spacing

The exam rhythm comes from `spazio`; the programme rhythm from
`spazio-didattica`. `quesito`, `risposta`, `griglia-punteggi()` and
`griglia-correzione()` own the spacing around and inside their own blocks, so
documents should not insert manual `#v(...)` between questions, answers or
summaries.

## Corrections

`risposta` has the same fields as `quesito`, plus `score` (points awarded):

```typ
#import "/typst-components/src/lib.typ": (
  theme, intestazione-correzione, risposta, commento, griglia-correzione,
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
placed before the answers or at the end. By default the first 100 points map to
10/10 and the remaining 10 points count as lode; pass `base:` to change the
threshold.

## Migration from typst-theme

Documents that used to import two packages now import one:

```typ
// before
#import "/typst-theme/src/lib.typ": theme
#import "/typst-components/src/lib.typ": cover, quesito

// after
#import "/typst-components/src/lib.typ": theme, cover, quesito
```

The former shared preamble path no longer exists. A JSON exam descriptor can
still add exam-specific content after the cover:

```json
{
  "preamble-file": "preamble.typ"
}
```

The path is relative to the descriptor's directory (or root-relative when it
starts with `/`). The referenced Typst file is included after the cover and
before the automatic delivery-instructions callout. If the key is omitted, no
preamble is included.

## Development

Compile the runnable programme example from the package root:

```sh
typst compile --root . examples/programma.typ /tmp/programma.pdf
```

The `materiale` repository consumes this package as a git submodule; `misc` is
legacy.
