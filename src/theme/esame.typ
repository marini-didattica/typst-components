// Exam theme: page, typography, code, links and level-1 headings.

#import "palette.typ": palette, font-mono
#import "spacing.typ": spazio
#import "labels.typ": sezione-corrente

/// Apply the shared page, typography, code and heading styles.
/// Use with `#show: doc => theme(doc, ...)`.
#let theme(
  body,
  footer-text: "Verifica di informatica",
  paper: "a4",
  margin: (top: 2.1cm, bottom: 2.4cm, x: 2.2cm),
) = {
  set page(
    paper: paper,
    margin: margin,
    footer: if footer-text == none {
      none
    } else {
      context [
        #set text(size: 8.5pt, fill: luma(140))
        #stack(
          dir: ttb,
          spacing: spazio.page.sm,
          line(length: 100%, stroke: 0.5pt + luma(225)),
          align(center)[
            #footer-text #h(10pt)·#h(10pt) #counter(page).display()
          ],
        )
      ]
    },
  )

  set text(lang: "it", region: "IT", size: 11pt, fill: palette.ink)
  set par(justify: true)
  set heading(numbering: "1.")
  set list(
    marker: (text(fill: palette.accent)[•],),
    indent: 1em,
    spacing: spazio.md,
  )
  set raw(tab-size: 4)

  show raw.where(block: true): it => block(
    width: 100%,
    fill: palette.code-bg,
    radius: 3pt,
    inset: (x: 10pt, y: 9pt),
    outset: (y: 3pt),
    stroke: none,
  )[#it]

  show raw.where(block: false): it => box(
    fill: palette.code-bg,
    inset: (x: 3pt, y: 1pt),
    outset: (y: 2pt),
    radius: 3pt,
  )[#it]

  show link: it => highlight(
    fill: palette.code-bg,
    stroke: 0.4pt + luma(200),
    radius: 3pt,
    extent: 2pt,
  )[
    #text(
      font: (font-mono,),
      size: 0.9em,
      fill: palette.accent-dark,
    )[#it]
  ]

  show heading.where(level: 1): it => {
    sezione-corrente.update(_ => it.body)

    block(
      above: spazio.xl,
      below: spazio.lg,
      width: 100%,
    )[
      #stack(
        dir: ttb,
        spacing: spazio.page.md,
        grid(
          columns: (auto, 1fr),
          column-gutter: 9pt,
          align: horizon,
          box(
            fill: palette.accent,
            inset: (x: 7pt, y: 4pt),
            radius: 3pt,
            baseline: 32%,
          )[
            #text(fill: white, weight: 800, size: 12pt)[
              #counter(heading).display()
            ]
          ],
          text(size: 17pt, weight: 800, fill: palette.ink)[#it.body],
        ),
        line(length: 100%, stroke: 2.2pt + palette.accent),
      )
    ]
  }

  body
}
