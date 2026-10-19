# typst-components

Reusable blocks for the Liceo Russell Typst materials, built on top of
[`typst-theme`](https://github.com/marini-didattica/typst-theme).

Main exports:

- `cover`
- `domanda`
- `esercizio`
- `lettura`
- `nota`, `template`, `esempi`
- `callout`, `checklist`, `consegna`
- `stelle`, `righe-risposta`

## Usage

The theme must be available as a sibling directory (or git submodule):

```text
project/
├── typst-theme/
└── typst-components/
```

```typ
#import "../typst-theme/src/lib.typ": theme
#import "../typst-components/src/lib.typ": cover, domanda, esercizio

#show: doc => theme(doc, footer-text: "Verifica di informatica")

#cover(
  title: "Simulazione verifica 1",
  descriptors: (("Durata", "80 minuti"),),
)
```

Compile from the project root with `--root .` so the components can import the
sibling theme package.

## Development

Check out both repositories side by side. The `misc` and `riservato`
repositories consume them as git submodules.
