// JSON-driven statistics for an exam and its corrections.

#import "exam.typ": load-exam, path-string, resolve-path
#import "../components/lib.typ": calcola-voto, fmt-punti, fmt-voto
#import "../theme/lib.typ": palette, spazio, theme
#import "@preview/cetz:0.5.0": canvas

/// Return the last segment of a POSIX path.
#let file-name(value) = {
  let parts = value.trim("/").split("/")
  if parts.len() == 0 { value } else { parts.last() }
}

/// Return a path's file stem (name without the final extension).
#let file-stem(value) = {
  let name = file-name(value)
  let parts = name.split(".")
  if parts.len() <= 1 { name } else { parts.slice(0, -1).join(".") }
}

/// Remove a single trailing slash, preserving the leading one.
#let trim-trailing-slash(value) = if value.ends-with("/") {
  value.slice(0, -1)
} else {
  value
}

#let mean(values) = if values.len() == 0 { 0 } else { values.sum() / values.len() }

#let variance(values) = {
  if values.len() == 0 {
    return 0
  }
  let average = mean(values)
  values.map(value => (value - average) * (value - average)).sum() / values.len()
}

#let standard-deviation(values) = calc.sqrt(variance(values))

#let fmt-stat(value, digits: 2) = fmt-punti(calc.round(value, digits: digits))

#let student-word(count) = if count == 1 { "studente" } else { "studenti" }

/// Abbreviate first names to initials, keeping the surname intact.
///
/// The correction stem is surname-first (`dal-savio-daniele`), so the first
/// slug segment identifies where the surname starts in the display name.
#let short-name(row) = {
  let words = row.name.split(" ").filter(word => word.len() > 0)
  let slug-parts = row.slug.split("-").filter(part => part.len() > 0)

  if words.len() <= 1 or slug-parts.len() == 0 {
    return row.name
  }

  let surname-word = slug-parts.first()
  let surname-start = none
  for (index, word) in words.enumerate() {
    if lower(word) == surname-word {
      surname-start = index
      break
    }
  }

  let surname-start = if surname-start == none {
    words.len() - 1
  } else {
    surname-start
  }
  let first-names = words.slice(0, surname-start)
  let surname = words.slice(surname-start).join(" ")

  if first-names.len() == 0 {
    surname
  } else {
    first-names.map(word => upper(word.slice(0, 1)) + ".").join(" ") + " " + surname
  }
}

/// Last-resort abbreviation: every name becomes an initial.
#let initials-name(row) = {
  row.name
    .split(" ")
    .filter(word => word.len() > 0)
    .map(word => upper(word.slice(0, 1)) + ".")
    .join(" ")
}

#let round-half(value) = calc.round(value * 2) / 2

/// Load an exam and the correction descriptors listed in `students`.
///
/// `test-folder` is a Typst `path` or a root-relative string. The exam
/// descriptor is resolved as `testo/<test-folder-name>.json` unless
/// `exam-file` overrides it.
///
/// Every student in `students` must have a correction descriptor. Use the
/// `typst-stats` command to skip missing files automatically.
#let load-stats(test-folder, students, exam-file: none) = {
  if type(test-folder) == str and not test-folder.starts-with("/") {
    panic("stats: test-folder must be a path or a root-relative string")
  }
  if type(students) != array {
    panic("stats: students must be an array of strings")
  }
  for student in students {
    if type(student) != str or student.len() == 0 {
      panic("stats: every student must be a non-empty string")
    }
  }

  let folder = trim-trailing-slash(path-string(test-folder))
  let selected = students

  if selected.len() == 0 {
    panic("stats: no correction descriptors selected")
  }

  let corrections = selected.map(student => {
    let correction-path = resolve-path(folder, "correzioni/" + student + ".json")
    let descriptor = json(correction-path)
    if type(descriptor) != dictionary {
      panic("stats: correction descriptor is not an object: " + correction-path)
    }
    if not descriptor.keys().contains("set") {
      panic("stats: correction descriptor has no \"set\": " + correction-path)
    }
    (student: student, descriptor: descriptor)
  })

  let sets = corrections
    .map(correction => correction.descriptor.at("set"))
    .dedup()
    .sorted()

  let name = file-stem(folder)
  let default-exam = "testo/" + name + ".json"
  let exam-path = if exam-file == none {
    resolve-path(folder, default-exam)
  } else {
    if type(exam-file) != str or exam-file.len() == 0 {
      panic("stats: exam-file must be a non-empty string")
    }
    resolve-path(folder, exam-file)
  }

  let exams = sets
    .map(set-name => (set-name, load-exam(exam-path, set-name)))
    .to-dict()

  let exercises-of(exam) = exam.categories.map(category => category.exercises).flatten()
  let find-exercise(exam, id) = exercises-of(exam).find(exercise => exercise.id == id)

  let all-exercises = {
    let best = ()
    for set-name in sets {
      let current = exercises-of(exams.at(set-name))
      if current.len() > best.len() {
        best = current
      }
    }
    best
  }
  let exercise-ids = all-exercises.map(exercise => exercise.id)
  let exercise-titles = all-exercises.map(exercise => exercise.title)

  let student-rows = corrections
    .map(correction => {
      let exam = exams.at(correction.descriptor.at("set"))
      let entries = exercise-ids.map(id => {
        let exercise = find-exercise(exam, id)
        if exercise == none {
          (id, none)
        } else {
          let entry = correction.descriptor.exercises.at(id, default: none)
          (id, if entry == none { 0 } else { entry.at("score") })
        }
      })
      (
        name: correction.descriptor.at("student-name", default: correction.student),
        slug: correction.student,
        variant: correction.descriptor.at("set"),
        scores: entries.to-dict(),
        total: entries.map(pair => pair.at(1)).filter(score => score != none).sum(),
      )
    })
    .sorted(key: row => row.name)

  let exam = exams.at(sets.first())
  let max-points = exam.at("max-points", default: none)
  let max-points = if max-points == none { exam.total } else { max-points }
  let laude-threshold = exam.at("laude-threshold")

  (
    folder: folder,
    exam-path: exam-path,
    corrections: corrections,
    sets: sets,
    exams: exams,
    exam: exam,
    all-exercises: all-exercises,
    exercise-ids: exercise-ids,
    exercise-titles: exercise-titles,
    student-rows: student-rows,
    total-values: student-rows.map(row => row.total),
    max-points: max-points,
    grade-min: exam.at("grade-min"),
    grade-max: exam.at("grade-max"),
    laude-threshold: laude-threshold,
    lode-count: student-rows.filter(row => row.total > laude-threshold).len(),
  )
}

/// Render a statistics document for one exam.
#let render-stats(test-folder, students, exam-file: none) = {
  let stats = load-stats(
    test-folder,
    students,
    exam-file: exam-file,
  )
  let exam = stats.exam
  let title = "Statistiche — " + exam.metadata.title

  set document(title: title, author: exam.metadata.author)
  show: doc => theme(doc, footer-text: title)

  let exercises-of(exam) = exam.categories.map(category => category.exercises).flatten()
  let find-exercise(exam, id) = exercises-of(exam).find(exercise => exercise.id == id)

  let grade-for(exam, total) = calcola-voto(
    total,
    base: exam.at("laude-threshold"),
    voto-min: exam.at("grade-min"),
    voto-max: exam.at("grade-max"),
  )
  let has-lode(exam, total) = total > exam.at("laude-threshold")
  let grade-with-lode(exam, total) = {
    let label = fmt-voto(grade-for(exam, total))
    if has-lode(exam, total) { label + " e lode" } else { label }
  }

  let name-cell(row) = context {
    let available = 3.3cm - 5pt
    let full = text(size: 7.5pt)[#row.name]
    if measure(full).width <= available {
      full
    } else {
      let short = text(size: 7.5pt)[#short-name(row)]
      if measure(short).width <= available {
        short
      } else {
        text(size: 7.5pt)[#initials-name(row)]
      }
    }
  }

  let column-values(id) = stats.student-rows
    .map(row => row.scores.at(id))
    .filter(score => score != none)

  let percentages-for(id) = {
    let rows = stats.student-rows.filter(row => row.scores.at(id) != none)
    rows.map(row => {
      let exercise = find-exercise(stats.exams.at(row.variant), id)
      row.scores.at(id) / exercise.points * 100
    })
  }

  // ----------------------------------------------------------
  // Bar charts
  // ----------------------------------------------------------

  let bar-chart(
    values,
    labels,
    max-value: none,
    value-format: value => str(value),
    color: palette.accent,
    height: 2.8,
  ) = {
    let chart-max = if max-value == none {
      values.fold(0, (a, b) => calc.max(a, b))
    } else {
      max-value
    }
    let chart-max = if chart-max == 0 { 1 } else { chart-max }

    canvas(length: 0.85cm, {
      import "@preview/cetz:0.5.0": draw
      import draw: *

      let count = values.len()
      let y-top = height

      line((0, 0), (count, 0), stroke: 0.6pt + luma(145))
      line((0, 0), (0, y-top), stroke: 0.6pt + luma(145))

      for (i, value) in values.enumerate() {
        let bar-height = value / chart-max * height
        if value > 0 {
          rect(
            (i + 0.13, 0),
            (i + 0.87, bar-height),
            fill: color,
            stroke: none,
          )
        }
        content(
          (i + 0.5, bar-height + 0.16),
          text(size: 7pt, fill: luma(65))[#value-format(value)],
        )
        content(
          (i + 0.5, -0.27),
          text(size: 6.5pt)[#labels.at(i)],
          anchor: "north",
        )
      }

      content((-0.12, 0), text(size: 6.5pt)[0], anchor: "east")
      content((-0.12, y-top), text(size: 6.5pt)[#chart-max], anchor: "east")
    })
  }

  // ----------------------------------------------------------
  // Buckets
  // ----------------------------------------------------------

  let bands = ("0", "1–25%", "26–50%", "51–75%", "76–99%", "100%")
  let band-index(percentage) = {
    if percentage <= 0 { 0 }
    else if percentage <= 25 { 1 }
    else if percentage <= 50 { 2 }
    else if percentage <= 75 { 3 }
    else if percentage < 100 { 4 }
    else { 5 }
  }
  let band-counts(percentages) = {
    let counts = range(bands.len()).map(_ => 0)
    for percentage in percentages {
      let index = band-index(percentage)
      counts.at(index) += 1
    }
    counts
  }

  let point-step = 10
  let point-bucket-count = int(calc.ceil(stats.max-points / point-step))
  let point-labels = range(point-bucket-count).map(i => {
    let start = i * point-step
    let end = if i == point-bucket-count - 1 {
      stats.max-points
    } else {
      start + point-step - 1
    }
    str(start) + "–" + str(end)
  })
  let point-bucket-index(points) = calc.min(
    int(points / point-step),
    point-bucket-count - 1,
  )
  let point-counts = {
    let counts = range(point-bucket-count).map(_ => 0)
    for total in stats.total-values {
      counts.at(point-bucket-index(total)) += 1
    }
    counts
  }

  let grade-step = 0.5
  let grade-bucket-count = int(
    calc.round((stats.grade-max - stats.grade-min) / grade-step),
  ) + 1
  let grade-labels = range(grade-bucket-count).map(i => fmt-stat(
    stats.grade-min + i * grade-step,
    digits: 1,
  ))
  let grade-counts = {
    let counts = range(grade-bucket-count).map(_ => 0)
    for row in stats.student-rows {
      let grade = round-half(grade-for(stats.exams.at(row.variant), row.total))
      let index = int(calc.round((grade - stats.grade-min) / grade-step))
      if index >= 0 and index < counts.len() {
        counts.at(index) += 1
      }
    }
    counts
  }

  // ----------------------------------------------------------
  // Per-set tables
  // ----------------------------------------------------------

  let variant-table(variant) = {
    let set-exam = stats.exams.at(variant)
    let exercises = exercises-of(set-exam)
    let ids = exercises.map(exercise => exercise.id)
    let rows = stats.student-rows.filter(row => row.variant == variant)
    let values-for(id) = rows
      .map(row => row.scores.at(id))
      .filter(score => score != none)
    let totals = rows.map(row => row.total)
    let grades = rows.map(row => grade-for(set-exam, row.total))

    figure(
      table(
        columns: (3.3cm,) + (1fr,) * ids.len() + (1.1cm, 1.35cm),
        inset: (x: 2.5pt, y: 3.5pt),
        stroke: 0.4pt + luma(205),
        align: center,
        table.header(
          align(left)[#text(size: 7.5pt, weight: "bold")[Studente]],
          ..ids.map(id => text(size: 7.5pt, weight: "bold")[#id]),
          align(right)[#text(size: 7pt, weight: "bold")[Totale]],
          align(right)[#text(size: 7pt, weight: "bold")[Voto]],
        ),
        // Second line: maximum points for each exercise in this set.
        ..(
          table.cell(fill: palette.tint, align: left)[
            #text(size: 6.5pt, fill: luma(110))[Punti]
          ],
          ..exercises.map(exercise => {
            table.cell(fill: palette.tint)[
              #text(size: 6.5pt, fill: luma(110))[#fmt-stat(exercise.points)]
            ]
          }),
          table.cell(fill: palette.tint, align: right)[
            #text(size: 6.5pt, fill: luma(110))[#fmt-stat(set-exam.total)]
          ],
          table.cell(fill: palette.tint, align: right)[
            #text(size: 6.5pt, fill: luma(110))[
              #fmt-stat(set-exam.at("grade-max"))
            ]
          ],
        ),
        ..rows.map(row => {
          (
            align(left)[#name-cell(row)],
            ..ids.map(id => {
              let score = row.scores.at(id)
              if score == none {
                text(size: 7.5pt, fill: luma(150))[—]
              } else {
                text(size: 7.5pt)[#fmt-stat(score)]
              }
            }),
            align(right)[#text(size: 7.5pt, weight: "bold")[#fmt-stat(row.total)]],
            align(right)[#text(size: 7pt)[#grade-with-lode(set-exam, row.total)]],
          )
        }).flatten(),
        table.hline(stroke: 0.8pt + luma(120)),
        ..(
          table.cell(fill: palette.tint, align: left)[
            #text(size: 7.5pt, weight: "bold")[Media]
          ],
          ..ids.map(id => {
            table.cell(fill: palette.tint)[
              #text(size: 7.5pt)[#fmt-stat(mean(values-for(id)), digits: 2)]
            ]
          }),
          table.cell(fill: palette.tint, align: right)[
            #text(size: 7.5pt, weight: "bold")[#fmt-stat(mean(totals), digits: 2)]
          ],
          table.cell(fill: palette.tint, align: right)[
            #text(size: 7.5pt)[#fmt-stat(mean(grades), digits: 2)]
          ],
        ),
        ..(
          table.cell(fill: palette.tint, align: left)[
            #text(size: 7.5pt, weight: "bold")[Deviazione standard]
          ],
          ..ids.map(id => {
            table.cell(fill: palette.tint)[
              #text(size: 7.5pt)[#fmt-stat(standard-deviation(values-for(id)), digits: 2)]
            ]
          }),
          table.cell(fill: palette.tint, align: right)[
            #text(size: 7.5pt, weight: "bold")[#fmt-stat(standard-deviation(totals), digits: 2)]
          ],
          table.cell(fill: palette.tint, align: right)[
            #text(size: 7.5pt)[#fmt-stat(standard-deviation(grades), digits: 2)]
          ],
        ),
      ),
      caption: [
        Set #upper(variant) — punteggi per studente ed esercizio
        (#rows.len() #student-word(rows.len())). La seconda riga riporta il
        punteggio massimo di ciascun esercizio nel set. Media e deviazione standard
        sono calcolate sui punteggi grezzi; le risposte mancanti valgono 0. La
        deviazione standard è quella di popolazione. Il voto usa la conversione del
        descrittore della prova: #fmt-stat(stats.grade-min)–#fmt-stat(stats.grade-max),
        con base #fmt-stat(stats.laude-threshold) punti. La lode scatta solo
        oltre la soglia.
      ],
    )
  }

  // ----------------------------------------------------------
  // Document
  // ----------------------------------------------------------

  [

  = Statistiche generali

  Statistiche calcolate sulle #stats.corrections.len() correzioni presenti in
  `correzioni/`. Le tabelle sono separate per set; i grafici per esercizio
  normalizzano invece il punteggio sul massimo dell'esercizio, così i set
  restano confrontabili.

  == Punteggi per studente ed esercizio

  #for variant in stats.sets [
    #block(above: spazio.xl, below: spazio.sm)[
      #text(size: 12pt, weight: 700)[Set #upper(variant)]
      #text(size: 9pt, fill: luma(110))[
        \ — #stats.student-rows.filter(row => row.variant == variant).len() #student-word(stats.student-rows.filter(row => row.variant == variant).len())
      ]
    ]
    #variant-table(variant)
  ]

  #pagebreak()

  == Distribuzione dei punteggi per esercizio

  I grafici mostrano la distribuzione del punteggio ottenuto in ciascun
  esercizio, espresso in percentuale del punteggio massimo dell'esercizio per
  lo studente. In questo modo studenti di set diversi restano confrontabili.

  #grid(
    columns: (1fr, 1fr),
    column-gutter: spazio.xl,
    row-gutter: spazio.xxl,
    ..stats.exercise-ids.enumerate().map(pair => {
      let id = pair.at(1)
      let values = percentages-for(id)
      let counts = band-counts(values)
      block(breakable: false, width: 100%)[
        #align(center)[
          #text(weight: 700)[#id — #stats.exercise-titles.at(pair.at(0))]
          #linebreak()
          #text(size: 8pt, fill: luma(105))[
            #values.len() #student-word(values.len()) · media #fmt-stat(mean(values), digits: 1)%
          ]
          #bar-chart(counts, bands, value-format: value => str(value))
        ]
      ]
    }),
  )

  == Distribuzione del punteggio totale

  === Punteggi (0–#stats.max-points)

  #figure(
    align(center)[
      #bar-chart(
        point-counts,
        point-labels,
        value-format: value => str(value),
      )
    ],
    caption: [
      Distribuzione del punteggio totale in bucket da #point-step punti
      (0–#stats.max-points). Media: #fmt-stat(mean(stats.total-values), digits: 1) /
      #stats.max-points (#fmt-stat(mean(stats.total-values) / stats.max-points * 100, digits: 1)%);
      deviazione standard: #fmt-stat(standard-deviation(stats.total-values), digits: 1).
    ],
  )

  === Voti (#fmt-stat(stats.grade-min)–#fmt-stat(stats.grade-max), passo 0,5)

  #figure(
    align(center)[
      #bar-chart(
        grade-counts,
        grade-labels,
        value-format: value => str(value),
        color: palette.accent,
      )
    ],
    caption: [
      Distribuzione dei voti, arrotondati al mezzo punto più vicino. Il voto è
      compresso fra #fmt-stat(stats.grade-min) e #fmt-stat(stats.grade-max).
      #if stats.lode-count > 0 [
        #stats.lode-count #student-word(stats.lode-count) hanno raggiunto la lode.
      ]
    ],
  )

  == Percentuale media per esercizio

  #figure(
    align(center)[
      #bar-chart(
        stats.exercise-ids.map(id => mean(percentages-for(id))),
        stats.exercise-ids,
        max-value: 100,
        value-format: value => fmt-stat(value, digits: 0) + "%",
      )
    ],
    caption: [
      Media della percentuale ottenuta in ciascun esercizio. Un valore basso
      indica un esercizio con prestazioni medie più deboli.
    ],
  )
  ]
}
