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
- `load-exam`, `render-exam` — load and render one set from a JSON exam descriptor
- `load-correction`, `render-correction` — load and render a JSON correction descriptor
- `load-stats`, `render-stats` — load a corrections folder and render per-set class statistics
- `istruzioni-consegna`, `risposta`, `risposta-nel-file`, `commento`, `nessuna-risposta`
- `griglia-punteggi`, `griglia-punteggi2`, `griglia-correzione`, `griglia-correzioni2`
- `cover`, `nota`, `template`, `esempi`
- `dislocazione` — classroom seating plan with automatic numbering
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
│   │   ├── dislocazione.typ
│   │   ├── compatibilita.typ
│   │   ├── copertina.typ
│   │   └── programma/
│   │       ├── copertina.typ
│   │       ├── quadro.typ
│   │       ├── modulo.typ
│   │       └── lib.typ
│   ├── documents/
│   │   ├── exam.typ
│   │   ├── correction.typ
│   │   ├── stats.typ
│   │   └── programma.typ
│   ├── exam.typ                # compatibility wrapper
│   ├── correction.typ          # compatibility wrapper
│   └── stats.typ               # compatibility wrapper
├── bin/
│   └── typst-stats             # command-line wrapper
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

### JSON descriptors

Use Typst's `path` constructor to resolve the descriptor relative to the
document that imports it:

```typ
#import "/typst-components/src/exam.typ": render-exam

#render-exam(path("prova-1.json"), "b")
```

Root-relative strings (starting with `/`) remain supported. Relative paths
inside the descriptor are resolved against the descriptor's directory.

The descriptor may also configure grading for its correction sheets:

```json
{
  "grade-min": 3,
  "grade-max": 10,
  "laude-threshold": 110
}
```

`grade-min` defaults to `3`, `grade-max` to `10`, and `laude-threshold` to the
selected set's maximum score. Scores are mapped from `0..laude-threshold` onto
`grade-min..grade-max`; scores above the threshold add “e lode”.

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

## Seating plans

`dislocazione` renders a classroom seating table with automatic `temi_XX`
numbering.

```typ
#import "/typst-components/src/lib.typ": dislocazione

#dislocazione(
  (
    ("Battocletti Alessandro", "Bonetti Alessandra", none),
    ("Dal Savio Daniele", "Ferrari Carlo", "Filippi Renato"),
  ),
  absent: ("Battocletti Alessandro",),
)
```

- Each row is an array; use `none` for an empty desk.
- `absent` contains the raw student names that should get a dashed border.
- The cattedra spans the first two columns by default; pass `cattedra: none` to
  omit it or an integer to change the span.
- Names are uppercased and split on the last space. Use `"Dal Savio|Daniele"` to
  force the line break.
- Numbering is row-major, skips empty desks, and includes absent students by
  default. Pass `numbering: false` or `start:` to change that.

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
`spazio-didattica`. `quesito`, `risposta`, `griglia-punteggi()`,
`griglia-correzione()` and `griglia-correzioni2()` own the spacing around and
inside their own blocks, so documents should not insert manual `#v(...)`
between questions, answers or summaries.

## Exam manifests

Every class exam folder contains a `manifest.json` next to `testo/` and
`correzioni/`. It is the single source of truth for the exam path and shared
correction defaults:

```json
{
  "$schema": "../../../misc/manifest.schema.json",
  "version": 1,
  "test-json": "../../shared/esercitazione-1/testo/esercitazione-1.json",
  "answer-folder": "risposte",
  "date": "20 ottobre 2026",
  "title": "Correzione — Simulazione 1"
}
```

`test-json` and `answer-folder` are resolved relative to the manifest. The
answer folder is the class-wide folder; the student slug is appended
automatically. `title`, `subtitle` and `import-answers` are optional defaults.

## JSON-driven corrections

A correction descriptor now contains only student-specific data. Its class and
display name are derived from the file name, the folder path and
`content/students.json`. `test-json`, `answer-folder`, `date` and the other
defaults come from the class manifest.

```json
{
  "set": "a",
  "exercises": {
    "E1": {
      "answer-file": "esercizio1.py",
      "score": 10,
      "comment": "Corretto."
    },
    "E2": null
  }
}
```

An absent student needs only:

```json
{ "absent": true }
```

- Every student in the class roster must have a correction file. This lets
  stats discover the complete class without a manually maintained list.
- Every exercise in the selected set must be present, either as an object or
  `null`. `null` renders the “Nessuna risposta consegnata.” placeholder with a
  score of 0.
- Non-null entries require `answer-file` and `score`.
- `date`, `title`, `subtitle` and `import-answers` can override the manifest
  defaults per correction.
- `comment` is interpreted as Typst markup and rendered with `commento`.

An entry point only needs the descriptor path:

```typ
#import "/typst-components/src/correction.typ": render-correction

#render-correction("/content/raw/private/admin/seconde/2c/prova-1/correzioni/battocletti-alessandro.json")
```

`render-correction` renders the header, all answers and comments, and the final
score summary with the answer-file column.

## Statistics

`render-stats` reads one class's `correzioni/` folder. The sibling
`manifest.json` supplies the exam path and the roster supplies the complete
student list. Each set gets its own independent statistics section.

```typ
#import "/typst-components/src/lib.typ": render-stats

#render-stats(path("content/raw/private/admin/seconde/2c/prova-1/correzioni"))
```

For a class exam folder, the usual entry point is simply:

```typ
#render-stats(path("../correzioni"))
```

The command-line wrapper only needs the corrections folder:

```sh
typst-components/bin/typst-stats \
  materiale/content/raw/private/admin/seconde/2c/prova-1/correzioni
```

The output defaults to the class exam's `misc/stats.pdf`; use `--out` to
override it and `--root` if the Typst project root cannot be found
automatically.

Charts use [`@preview/cetz:0.5.0`](https://typst.app/universe/package/cetz).

## Manual correction components

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
