// Dotted answer lines.

#import "../theme/spacing.typ": spazio

#let righe-risposta(n) = rect(
  stroke: 0.5pt + luma(195),
  radius: 3pt,
  inset: spazio.page.lg,
  grid(
    columns: 1,
    row-gutter: spazio.page.lg,
    ..range(n).map(_ => line(
      length: 100%,
      stroke: (paint: luma(195), thickness: 0.6pt, dash: "dotted"),
    )),
  ),
)
