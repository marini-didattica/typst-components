// JSON-driven statistics for an exam and its corrections.

#import "exam.typ": load-exam, parent-path, path-string, resolve-path
#import "manifest.typ": (
  class-from-corrections-dir,
  correction-path-for,
  file-name,
  file-stem,
  load-manifest,
  load-roster,
  manifest-path-for,
)
#import "correction.typ": load-correction
#import "../components/lib.typ": calcola-voto, fmt-punti, fmt-voto
#import "../theme/lib.typ": palette, spazio, theme
#import "@preview/cetz:0.5.0": canvas

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

/// Load one class's corrections and the shared exam manifest.
///
/// `corrections-folder` is a Typst `path` or a root-relative string to the
/// class's `correzioni/` folder. The manifest is read from `../manifest.json`;
/// the roster is read from `/content/students.json` by default. Every student
/// in the class must have a correction descriptor. Absent students use a file
/// containing only `{"absent": true}`.
#let load-stats(
  corrections-folder,
  manifest-file: none,
  students-json: "/content/students.json",
) = {
  if type(corrections-folder) == str and not corrections-folder.starts-with("/") {
    panic("stats: corrections-folder must be a path or a root-relative string")
  }

  let corrections-dir = trim-trailing-slash(path-string(corrections-folder))
  let manifest-path = manifest-path-for(corrections-dir, manifest-file: manifest-file)
  let manifest = load-manifest(manifest-path)
  let class-name = class-from-corrections-dir(corrections-dir)
  let roster = load-roster(students-json)
  let prefix = class-name + "/"
  let roster-keys = roster.keys().filter(key => key.starts-with(prefix)).sorted()

  if roster-keys.len() == 0 {
    panic("stats: no students for class \"" + class-name + "\" in " + students-json)
  }

  let records = roster-keys.map(key => {
    let slug = key.split("/").last()
    let correction = load-correction(
      correction-path-for(corrections-dir, slug),
      manifest-file: manifest-path,
      students-json: students-json,
    )
    (key: key, slug: slug, correction: correction)
  })

  let absent = records
    .filter(record => record.correction.absent)
    .map(record => (slug: record.slug, name: record.correction.student-name))
  let present = records.filter(record => not record.correction.absent)

  let unique(values) = {
    let seen = ()
    for value in values {
      if not (value in seen) {
        seen.push(value)
      }
    }
    seen
  }

  let test-name-of(test-path) = {
    let record = present.find(record => record.correction.test-path == test-path)
    if record == none {
      file-stem(test-path)
    } else {
      record.correction.test
    }
  }

  // The cohort's default test comes first; any test a student sat as a
  // substitute follows, sorted by name. A class whose students all sat the
  // default test therefore keeps exactly the previous behaviour.
  let default-test-path = manifest.test-path
  let substitute-tests = unique(
    present.map(record => record.correction.test-path),
  ).filter(test-path => test-path != default-test-path)
  let test-paths = (default-test-path,) + substitute-tests.sorted(
    key: test-path => test-name-of(test-path),
  )

  let default-sets = json(default-test-path).at("sets")
  if type(default-sets) != array or default-sets.len() == 0 {
    panic("stats: exam descriptor has no sets")
  }

  let set-data = ()
  for test-path in test-paths {
    let test-descriptor = json(test-path)
    let test-sets = test-descriptor.at("sets")
    if type(test-sets) != array or test-sets.len() == 0 {
      panic("stats: exam descriptor has no sets: " + test-path)
    }

    for set-name in test-sets {
      let exam = load-exam(test-path, set-name)
      let exercises = exam.categories
        .map(category => category.exercises)
        .flatten()

      let student-rows = present
        .filter(record => (
          record.correction.test-path == test-path
            and record.correction.variant == set-name
        ))
        .map(record => {
          let correction = record.correction
          let entries = correction.categories
            .map(category => category.exercises)
            .flatten()
            .map(exercise => (
              exercise.id,
              if exercise.delivered { exercise.score } else { none },
            ))

          (
            name: correction.student-name,
            slug: correction.student,
            variant: set-name,
            scores: entries.to-dict(),
            total: correction.total,
          )
        })
        .sorted(key: row => row.name)

      let max-points = exam.at("max-points", default: none)
      set-data.push((
        variant: set-name,
        test: test-name-of(test-path),
        test-path: test-path,
        exam: exam,
        exercises: exercises,
        exercise-ids: exercises.map(exercise => exercise.id),
        exercise-titles: exercises.map(exercise => exercise.title),
        student-rows: student-rows,
        total-values: student-rows.map(row => row.total),
        max-points: if max-points == none { exam.total } else { max-points },
        grade-min: exam.at("grade-min"),
        grade-max: exam.at("grade-max"),
        laude-threshold: exam.at("laude-threshold"),
        lode-count: student-rows.filter(row => row.total > exam.at("laude-threshold")).len(),
      ))
    }
  }

  let sets = default-sets
  let tests = test-paths.map(test-path => (
    name: test-name-of(test-path),
    path: test-path,
  ))

  (
    corrections-folder: corrections-dir,
    manifest-path: manifest-path,
    manifest: manifest,
    test: manifest.test,
    test-json: manifest.test-path,
    tests: tests,
    class: class-name,
    roster-count: roster-keys.len(),
    absent: absent,
    sets: sets,
    set-data: set-data,
    exam: set-data.first().exam,
  )
}

/// Render the statistics document for one class.
///
/// `corrections-folder` points at the class's `correzioni/` folder. The exam
/// manifest and the roster provide all other metadata; each set gets its own
/// independent statistics section.
#let render-stats(
  corrections-folder,
  manifest-file: none,
  students-json: "/content/students.json",
) = {
  let stats = load-stats(
    corrections-folder,
    manifest-file: manifest-file,
    students-json: students-json,
  )
  let first-exam = stats.exam
  let title = "Statistiche — " + first-exam.metadata.title

  set document(title: title, author: first-exam.metadata.author)
  show: doc => theme(doc, footer-text: title)

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

  // ----------------------------------------------------------
  // One section per set
  // ----------------------------------------------------------

  let render-set(set-stats) = {
    let exam = set-stats.exam
    let set-title = if stats.tests.len() > 1 {
      set-stats.test + " · Set " + upper(set-stats.variant)
    } else {
      "Set " + upper(set-stats.variant)
    }
    let rows = set-stats.student-rows
    let exercises = set-stats.exercises
    let ids = set-stats.exercise-ids
    let titles = set-stats.exercise-titles
    let totals = set-stats.total-values
    let values-for(id) = rows
      .map(row => row.scores.at(id))
      .filter(score => score != none)
    let percentages-for(id) = {
      let selected = rows.filter(row => row.scores.at(id) != none)
      selected.map(row => {
        let exercise = exercises.find(exercise => exercise.id == id)
        row.scores.at(id) / exercise.points * 100
      })
    }

    let point-step = 10
    let point-bucket-count = int(calc.ceil(set-stats.max-points / point-step))
    let point-labels = range(point-bucket-count).map(i => {
      let start = i * point-step
      let end = if i == point-bucket-count - 1 {
        set-stats.max-points
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
      for total in totals {
        counts.at(point-bucket-index(total)) += 1
      }
      counts
    }

    let grade-step = 0.5
    let grade-bucket-count = int(
      calc.round((set-stats.grade-max - set-stats.grade-min) / grade-step),
    ) + 1
    let grade-labels = range(grade-bucket-count).map(i => fmt-stat(
      set-stats.grade-min + i * grade-step,
      digits: 1,
    ))
    let grade-counts = {
      let counts = range(grade-bucket-count).map(_ => 0)
      for row in rows {
        let grade = round-half(grade-for(exam, row.total))
        let index = int(calc.round((grade - set-stats.grade-min) / grade-step))
        if index >= 0 and index < counts.len() {
          counts.at(index) += 1
        }
      }
      counts
    }

    if rows.len() == 0 {
      [
        = #set-title

        _Nessuno studente ha svolto questo set._
      ]
    } else {
      [
        = #set-title

        #text(size: 8.5pt, fill: luma(105))[
          #rows.len() #student-word(rows.len()) ·
          Punti max #fmt-stat(set-stats.max-points) ·
          Voti #fmt-stat(set-stats.grade-min)–#fmt-stat(set-stats.grade-max) ·
          Lode oltre #fmt-stat(set-stats.laude-threshold) ·
          Media #fmt-stat(mean(totals), digits: 1) ·
          Dev. std. #fmt-stat(standard-deviation(totals), digits: 1)
        ]

        == Punteggi per studente ed esercizio

        #figure(
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
                #text(size: 6.5pt, fill: luma(110))[#fmt-stat(set-stats.max-points)]
              ],
              table.cell(fill: palette.tint, align: right)[
                #text(size: 6.5pt, fill: luma(110))[
                  #fmt-stat(set-stats.grade-max)
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
                align(right)[#text(size: 7pt)[#grade-with-lode(exam, row.total)]],
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
                #text(size: 7.5pt)[#fmt-stat(mean(rows.map(row => grade-for(exam, row.total))), digits: 2)]
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
                #text(size: 7.5pt)[#fmt-stat(standard-deviation(rows.map(row => grade-for(exam, row.total))), digits: 2)]
              ],
            ),
          ),
          caption: [
            Set #upper(set-stats.variant) — punteggi per studente ed esercizio
            (#rows.len() #student-word(rows.len())). La seconda riga riporta il
            punteggio massimo di ciascun esercizio nel set. Media e deviazione
            standard sono calcolate sui punteggi grezzi; le risposte mancanti
            valgono 0. La deviazione standard è quella di popolazione. Il voto
            usa la conversione del descrittore della prova:
            #fmt-stat(set-stats.grade-min)–#fmt-stat(set-stats.grade-max), con
            base #fmt-stat(set-stats.laude-threshold) punti. La lode scatta solo
            oltre la soglia.
          ],
        )

        #pagebreak()

        == Distribuzione dei punteggi per esercizio

        I grafici mostrano la distribuzione del punteggio ottenuto in ciascun
        esercizio, espresso in percentuale del punteggio massimo dell'esercizio
        per lo studente.

        #grid(
          columns: (1fr, 1fr),
          column-gutter: spazio.xl,
          row-gutter: spazio.xxl,
          ..ids.enumerate().map(pair => {
            let id = pair.at(1)
            let values = percentages-for(id)
            let counts = band-counts(values)
            block(breakable: false, width: 100%)[
              #align(center)[
                #text(weight: 700)[#id — #titles.at(pair.at(0))]
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

        === Punteggi (0–#set-stats.max-points)

        #figure(
          align(center)[
            #bar-chart(
              point-counts,
              point-labels,
              value-format: value => str(value),
            )
          ],
          caption: [
            Distribuzione del punteggio totale del set #upper(set-stats.variant)
            in bucket da #point-step punti (0–#set-stats.max-points).
            Media: #fmt-stat(mean(totals), digits: 1) /
            #set-stats.max-points (#fmt-stat(mean(totals) / set-stats.max-points * 100, digits: 1)%);
            deviazione standard: #fmt-stat(standard-deviation(totals), digits: 1).
          ],
        )

        === Voti (#fmt-stat(set-stats.grade-min)–#fmt-stat(set-stats.grade-max), passo 0,5)

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
            Distribuzione dei voti del set #upper(set-stats.variant),
            arrotondati al mezzo punto più vicino. Il voto è compresso fra
            #fmt-stat(set-stats.grade-min) e #fmt-stat(set-stats.grade-max).
            #if set-stats.lode-count > 0 [
              #set-stats.lode-count #student-word(set-stats.lode-count) hanno
              raggiunto la lode.
            ]
          ],
        )

        == Percentuale media per esercizio

        #figure(
          align(center)[
            #bar-chart(
              ids.map(id => mean(percentages-for(id))),
              ids,
              max-value: 100,
              value-format: value => fmt-stat(value, digits: 0) + "%",
            )
          ],
          caption: [
            Media della percentuale ottenuta in ciascun esercizio del set
            #upper(set-stats.variant). Un valore basso indica un esercizio con
            prestazioni medie più deboli.
          ],
        )
      ]
    }
  }

  [
    Statistiche calcolate sulle #stats.roster-count #student-word(stats.roster-count)
    della classe #upper(stats.class).
    #if stats.tests.len() > 1 [
      Ogni prova ha una sezione separata, e ogni set ha statistiche calcolate
      solo sugli studenti che hanno svolto quella prova in quel set.
    ] else [
      Ogni set ha una sezione separata, con statistiche calcolate solo sugli
      studenti di quel set.
    ]

    #if stats.absent.len() > 0 [
      #text(size: 8.5pt, fill: luma(105))[
        Assenti: #stats.absent.map(student => student.name).join(", ").
      ]
    ]

    #for (index, set-stats) in stats.set-data.enumerate() {
      if index > 0 { pagebreak() }
      render-set(set-stats)
    }
  ]
}
