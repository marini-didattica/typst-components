# typst-theme

Shared colours, typography, page setup, code-block styling and heading style
for the Liceo Russell Typst materials.

The package exports `palette`, `font-mono`, `etichetta`, `sezione-corrente`,
`spazio` and `theme`. `sezione-corrente` is updated by the level-1 heading show
rule so other packages can group content by the section it appears in. `spazio`
is the shared vertical rhythm: `xs` … `xxl` are `em`-based tokens for flowing
content, while `spazio.page.xs` … `spazio.page.xxl` are absolute tokens for
fixed page furniture such as the cover, footer and answer lines. Components
should use these tokens instead of ad-hoc vertical spacing. Links are rendered
as inline monospace “verb” chips: code background, thin border, and
accent-coloured text, while remaining clickable.

`src/preamble.typ` contains the shared general instructions included by the
JSON exam renderer after the generated cover. Documents can override it with
the `preamble-file` key in their descriptor.

## Usage

Keep the theme next to the document that imports it (as a sibling directory or
a git submodule):

```typ
#import "../typst-theme/src/lib.typ": theme

#show: doc => theme(doc, footer-text: "Verifica di informatica")
```

Compile with the root that contains the theme so Typst's sandbox can read it:

```sh
typst compile --root . path/to/document.typ
```

## Development

This repository is designed to sit side by side with
[`typst-components`](https://github.com/marini-didattica/typst-components).
The `materiale` repository consumes both as git submodules; `misc` and
`riservato` are legacy.
