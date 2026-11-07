// JSON-driven correction sheets.

#import "exam.typ": load-exam, parent-path, path-string, resolve-path
#import "manifest.typ": (
  class-from-corrections-dir,
  file-name,
  file-stem,
  load-manifest,
  load-roster,
  manifest-path-for,
  roster-entry,
  student-name-from-entry,
)
#import "../components/lib.typ": (
  commento,
  griglia-correzioni2,
  intestazione-correzione,
  risposta,
  risposta-nel-file,
)
#import "../components/nomi-file.typ": nome-risposta
#import "../theme/esame.typ": theme

/// Infer the raw language from an answer file name.
#let answer-language(file) = {
  let parts = file-name(file).split(".")
  let extension = if parts.len() > 1 { lower(parts.last()) } else { "" }

  if extension == "py" {
    "python"
  } else if extension == "c" or extension == "h" {
    "c"
  } else if extension == "cpp" or extension == "hpp" {
    "cpp"
  } else if extension == "java" {
    "java"
  } else if extension == "js" {
    "javascript"
  } else if extension == "ts" {
    "typescript"
  } else if extension == "md" {
    "markdown"
  } else if extension == "typ" {
    "typ"
  } else {
    "text"
  }
}

/// Load and validate a correction descriptor.
#let load-correction(
  correction-path,
  manifest-file: none,
  students-json: "/content/students.json",
) = {
  if type(correction-path) == str and not correction-path.starts-with("/") {
    panic("correction: json-path must start with '/': " + correction-path)
  }

  let descriptor = json(correction-path)
  let corrections-dir = parent-path(path-string(correction-path))
  let fail(message) = panic("correction: " + message)

  let slug = file-stem(path-string(correction-path))
  let class-name = class-from-corrections-dir(corrections-dir)
  let manifest-path = manifest-path-for(corrections-dir, manifest-file: manifest-file)
  let manifest = load-manifest(manifest-path)
  let roster = load-roster(students-json)
  let roster-entry-value = roster-entry(roster, class-name, slug)
  let student-name = student-name-from-entry(roster-entry-value, slug)
  let student-class = upper(class-name)

  let is-dict(value) = type(value) == dictionary
  let is-array(value) = type(value) == array
  let has-key(dict, key) = dict.keys().contains(key)

  let required-string(object, key, label) = {
    if not has-key(object, key) {
      fail(label + " manca \"" + key + "\"")
    }
    let value = object.at(key)
    if type(value) != str {
      fail(label + "." + key + " deve essere una stringa")
    }
    if value.len() == 0 {
      fail(label + "." + key + " non può essere vuoto")
    }
    value
  }

  let optional-string(object, key, default, label) = {
    if not has-key(object, key) { return default }
    let value = object.at(key)
    if type(value) != str {
      fail(label + "." + key + " deve essere una stringa")
    }
    value
  }

  let optional-bool(object, key, default, label) = {
    if not has-key(object, key) { return default }
    let value = object.at(key)
    if type(value) != bool {
      fail(label + "." + key + " deve essere un booleano")
    }
    value
  }

  let allowed-keys = (
    "absent",
    "set",
    "import-answers",
    "date",
    "title",
    "subtitle",
    "exercises",
  )

  if not is-dict(descriptor) {
    fail("il descrittore deve essere un oggetto JSON")
  }
  for key in descriptor.keys() {
    if not (key in allowed-keys) {
      fail("chiave sconosciuta: \"" + key + "\"")
    }
  }

  let absent = optional-bool(descriptor, "absent", false, "descriptor")
  if absent {
    for key in descriptor.keys() {
      if key != "absent" {
        fail("un descrittore assente può contenere solo \"absent\"")
      }
    }
    return (
      absent: true,
      student: slug,
      student-name: student-name,
      class: student-class,
    )
  }

  let set-name = required-string(descriptor, "set", "descriptor")
  let exam = load-exam(manifest.test-json, set-name)
  let answer-folder = resolve-path(manifest.answer-folder, slug)
  let import-answers = optional-bool(
    descriptor,
    "import-answers",
    manifest.import-answers,
    "descriptor",
  )

  let date = optional-string(descriptor, "date", manifest.date, "descriptor")
  let default-title = if manifest.title == none {
    "Correzione — " + exam.metadata.title
  } else {
    manifest.title
  }
  let title = optional-string(
    descriptor,
    "title",
    default-title,
    "descriptor",
  )
  let default-subtitle = "Classe " + student-class + (
    if date == none {
      ""
    } else {
      " · " + date
    }
  )
  let subtitle = optional-string(
    descriptor,
    "subtitle",
    if manifest.subtitle == none {
      default-subtitle
    } else {
      manifest.subtitle
    },
    "descriptor",
  )

  if not has-key(descriptor, "exercises") {
    fail("descriptor manca \"exercises\"")
  }
  let entries = descriptor.at("exercises")
  if not is-dict(entries) {
    fail("descriptor.exercises deve essere un oggetto")
  }

  let expected-ids = ()
  for category in exam.categories {
    for exercise in category.exercises {
      expected-ids = expected-ids + (exercise.id,)
    }
  }

  for key in entries.keys() {
    if not (key in expected-ids) {
      fail("esercizio sconosciuto per il set \"" + set-name + "\": " + key)
    }
  }
  for id in expected-ids {
    if not has-key(entries, id) {
      fail("manca l'esercizio \"" + id + "\" (usa null se non è stato consegnato)")
    }
  }

  let resolved-categories = ()
  let total = 0
  let maximum = 0

  for category in exam.categories {
    let resolved-exercises = ()
    for exercise in category.exercises {
      let label = "exercise " + exercise.id
      let entry = entries.at(exercise.id)
      let fallback-file = nome-risposta(exercise)
      let resolved = (
        id: exercise.id,
        numero: exercise.numero,
        category: exercise.category,
        tag: exercise.tag,
        title: exercise.title,
        points: exercise.points,
        difficulty: exercise.difficulty,
        answer-file: fallback-file,
        score: 0,
        comment: none,
        import-answer: false,
        body: none,
        delivered: false,
      )

      if entry != none {
        if not is-dict(entry) {
          fail(label + " deve essere un oggetto oppure null")
        }

        let allowed-entry-keys = (
          "answer-file",
          "score",
          "import-answer",
          "import-answers",
          "comment",
        )
        for key in entry.keys() {
          if not (key in allowed-entry-keys) {
            fail(label + " contiene la chiave sconosciuta \"" + key + "\"")
          }
        }

        let answer-file = required-string(entry, "answer-file", label)
        if not has-key(entry, "score") {
          fail(label + " manca \"score\"")
        }
        let score = entry.at("score")
        if type(score) != int and type(score) != float {
          fail(label + ".score deve essere un numero")
        }
        if score < 0 {
          fail(label + ".score non può essere negativo")
        }
        if score > exercise.points {
          fail(
            label + ".score (" + str(score) + ") supera il massimo ("
              + str(exercise.points) + ")",
          )
        }

        let import-override = none
        if has-key(entry, "import-answer") and has-key(entry, "import-answers") {
          if entry.at("import-answer") != entry.at("import-answers") {
            fail(label + ": import-answer e import-answers sono in conflitto")
          }
        }
        if has-key(entry, "import-answer") {
          import-override = entry.at("import-answer")
        } else if has-key(entry, "import-answers") {
          import-override = entry.at("import-answers")
        }
        if import-override != none and type(import-override) != bool {
          fail(label + ".import-answer deve essere un booleano")
        }

        let import-answer = if import-override == none {
          import-answers
        } else {
          import-override
        }
        let comment = optional-string(entry, "comment", none, label)
        let body = if import-answer {
          let path = resolve-path(answer-folder, answer-file)
          raw(read(path), block: true, lang: answer-language(answer-file))
        } else {
          risposta-nel-file(answer-file)
        }

        resolved = (
          id: resolved.id,
          numero: resolved.numero,
          category: resolved.category,
          tag: resolved.tag,
          title: resolved.title,
          points: resolved.points,
          difficulty: resolved.difficulty,
          answer-file: answer-file,
          score: score,
          comment: comment,
          import-answer: import-answer,
          body: body,
          delivered: true,
        )
      }

      total = total + resolved.score
      maximum = maximum + resolved.points
      resolved-exercises = resolved-exercises + (resolved,)
    }

    resolved-categories = (
      resolved-categories
        + (
          (
            id: category.id,
            tag: category.tag,
            title: category.title,
            exercises: resolved-exercises,
          ),
        )
    )
  }

  (
    absent: false,
    variant: set-name,
    student: slug,
    student-name: student-name,
    class: student-class,
    exam: exam,
    title: title,
    subtitle: subtitle,
    categories: resolved-categories,
    total: total,
    maximum: maximum,
  )
}

/// Render a full JSON-driven correction sheet.
#let render-correction(
  correction-path,
  manifest-file: none,
  students-json: "/content/students.json",
) = {
  let correction = load-correction(
    correction-path,
    manifest-file: manifest-file,
    students-json: students-json,
  )
  if correction.absent {
    panic("correction: " + correction.student-name + " is absent")
  }
  let exam = correction.exam

  set document(title: correction.title, author: exam.metadata.author)
  show: doc => theme(doc, footer-text: correction.title)

  intestazione-correzione(
    correction.student-name,
    totale: correction.total,
    massimo: correction.maximum,
    title: correction.title,
    subtitle: correction.subtitle,
    base: exam.laude-threshold,
    voto-min: exam.grade-min,
    voto-max: exam.grade-max,
    lode-soglia: exam.laude-threshold,
    voci: (),
  )

  for pair in correction.categories.enumerate() {
    let index = pair.at(0)
    let category = pair.at(1)

    if index > 0 {
      pagebreak()
    }

    heading(level: 1)[#category.title]

    for exercise in category.exercises {
      risposta(
        exercise.body,
        category: exercise.category,
        tag: exercise.tag,
        title: exercise.title,
        points: exercise.points,
        score: exercise.score,
        diff: exercise.difficulty,
        numero: exercise.numero,
      )

      if exercise.comment != none {
        commento(eval(exercise.comment, mode: "markup"))
      }
    }
  }

  griglia-correzioni2(
    correction.categories,
    base: exam.laude-threshold,
    voto-min: exam.grade-min,
    voto-max: exam.grade-max,
    lode-soglia: exam.laude-threshold,
    titolo: "Riepilogo dei punteggi",
  )
}
