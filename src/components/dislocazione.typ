// Seating-plan table for exams.

#import "../theme/palette.typ": font-sans

#let dislocazione-ink = rgb("#0f172a")
#let dislocazione-grid = rgb("#cbd5e1")
#let dislocazione-cell = luma(200)
#let dislocazione-absent = rgb("#94a3b8")

#let dislocazione-number(n) = if n < 10 { "0" + str(n) } else { str(n) }

#let dislocazione-name(value, font) = {
  let parts = if value.contains("|") {
    value.split("|")
  } else {
    let words = value.split(" ")
    if words.len() <= 1 {
      (value,)
    } else {
      (words.slice(0, -1).join(" "), words.last())
    }
  }

  let lines = parts.map(part => upper(part.trim()))
  text(font: font)[#lines.join(linebreak())]
}

#let dislocazione-empty = table.cell(
  fill: none,
  stroke: none,
)[]

/// Render a classroom seating plan.
///
/// `rows` is an array of rows; each cell is a student name or `none` for an
/// empty desk. Names are uppercased and split on the last space by default;
/// use `"Surname|Name"` to force the split point.
///
/// `absent` is a list of raw student names (the same strings used in `rows`).
/// Those cells get a dashed border.
///
/// `cattedra` is the number of columns spanned by the top-left desk; pass
/// `none` to omit it. Numbering is automatic, row-major, and includes absent
/// students.
#let dislocazione(
  rows,
  absent: (),
  columns: auto,
  cattedra: 2,
  numbering: true,
  start: 1,
  font: font-sans,
) = {
  if type(rows) != array {
    panic("dislocazione: rows must be an array")
  }
  if type(absent) != array {
    panic("dislocazione: absent must be an array")
  }
  if cattedra != none and type(cattedra) != int {
    panic("dislocazione: cattedra must be an integer or none")
  }

  let widths = rows.map(row => {
    if type(row) != array {
      panic("dislocazione: every row must be an array")
    }
    row.len()
  })
  let inferred = widths.fold(0, (acc, width) => calc.max(acc, width))
  let column-count = if columns == auto { inferred } else { columns }

  if type(column-count) != int or column-count <= 0 {
    panic("dislocazione: columns must be a positive integer")
  }
  for row in rows {
    if row.len() > column-count {
      panic(
        "dislocazione: a row has more than "
          + str(column-count)
          + " cells",
      )
    }
  }

  for name in absent {
    if type(name) != str {
      panic("dislocazione: absent must contain only strings")
    }
    let found = false
    for row in rows {
      if name in row {
        found = true
      }
    }
    if not found {
      panic("dislocazione: absent student not found: " + name)
    }
  }

  let cells = ()
  let n = start

  if cattedra != none and cattedra > 0 {
    let span = calc.min(cattedra, column-count)
    cells.push(table.cell(
      colspan: span,
      fill: dislocazione-ink,
      inset: 8pt,
    )[#text(font: font, fill: white, size: 15pt)[CATTEDRA]])
    for _ in range(column-count - span) {
      cells.push(dislocazione-empty)
    }
  }

  for row in rows {
    for i in range(column-count) {
      let value = if i < row.len() { row.at(i) } else { none }

      if value == none {
        cells.push(dislocazione-empty)
      } else if type(value) == str {
        let is-absent = value in absent
        cells.push(table.cell(
          stroke: if is-absent {
            (
              paint: dislocazione-absent,
              thickness: 1pt,
              dash: (4pt, 3pt),
            )
          } else {
            dislocazione-cell
          },
          inset: 8pt,
          stack(
            spacing: 8pt,
            dislocazione-name(value, font),
            if numbering {
              text(font: font, size: 8pt)[
                temi\_#dislocazione-number(n)
              ]
            },
          ),
        ))
        n = n + 1
      } else {
        panic("dislocazione: cells must be strings or none")
      }
    }
  }

  align(center + horizon, table(
    columns: column-count,
    align: center + horizon,
    stroke: dislocazione-grid,
    column-gutter: 10pt,
    row-gutter: 10pt,
    ..cells,
  ))
}
