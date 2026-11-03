#import "lib.typ": cover, griglia-voti2, istruzioni-consegna, quesito2
#import "/typst-theme/src/lib.typ": theme

/// Return the directory portion of a POSIX path.
#let parent-path(value) = {
  let parts = value.split("/")
  if parts.len() <= 1 { "" } else { parts.slice(0, -1).join("/") }
}

/// Resolve a descriptor-relative path against the descriptor directory.
#let resolve-path(base-dir, value) = {
  if value.starts-with("/") {
    value
  } else if base-dir == "" {
    value
  } else {
    base-dir + "/" + value
  }
}

/// Render one exam variant from a JSON descriptor.
///
/// `json-path` must be root-relative (it must start with `/`) so paths inside
/// the descriptor can be resolved against the descriptor's directory.
#let render-exam(json-path, set-name) = {
  if not json-path.starts-with("/") {
    panic("exam: json-path must start with '/': " + json-path)
  }

  let descriptor = json(json-path)
  let all-sets = descriptor.at("sets")
  let base-dir = parent-path(json-path)

  let fail(message) = panic("exam: " + message)

  let is-dict(value) = type(value) == dictionary
  let is-array(value) = type(value) == array
  let has-key(dict, key) = dict.keys().contains(key)

  let validate-set-list(value, label, parent-sets) = {
    if not is-array(value) {
      fail(label + " deve essere un array di set")
    }
    if value.len() == 0 {
      fail(label + " non può essere vuoto")
    }

    let seen = ()
    for set-name in value {
      if type(set-name) != str {
        fail(label + " contiene un set non stringa")
      }
      if not (set-name in all-sets) {
        fail(label + " contiene il set sconosciuto \"" + set-name + "\"")
      }
      if set-name in seen {
        fail(label + " contiene il set duplicato \"" + set-name + "\"")
      }
      if not (set-name in parent-sets) {
        fail(label + " contiene il set \"" + set-name + "\" non presente nel livello superiore")
      }
      seen = seen + (set-name,)
    }

    value
  }

  let effective-sets(object, parent-sets, label) = {
    if has-key(object, "sets") {
      validate-set-list(object.at("sets"), label + ".sets", parent-sets)
    } else {
      parent-sets
    }
  }

  let resolve-value(value, set-name, effective, label) = {
    if is-dict(value) {
      for key in value.keys() {
        if not (key in all-sets) {
          fail(label + ": chiave di set sconosciuta \"" + key + "\"")
        }
      }

      for required in effective {
        if not has-key(value, required) {
          fail(label + ": manca il valore per il set \"" + required + "\"")
        }
      }

      value.at(set-name)
    } else {
      value
    }
  }

  let resolve-attribute(object, key, default, set-name, effective, label) = {
    let value = if has-key(object, key) { object.at(key) } else { default }
    resolve-value(value, set-name, effective, label + "." + key)
  }

  let required-string(object, key, label) = {
    if not has-key(object, key) {
      fail(label + " manca \"" + key + "\"")
    }

    let value = object.at(key)
    if type(value) != str {
      fail(label + "." + key + " deve essere una stringa")
    }
    value
  }

  let validate-descriptor() = {
    if not is-dict(descriptor) {
      fail("il descrittore deve essere un oggetto JSON")
    }
    if descriptor.at("version") != 1 {
      fail("versione del descrittore non supportata")
    }
    if not is-array(all-sets) {
      fail("sets deve essere un array")
    }
    if all-sets.len() == 0 {
      fail("sets non può essere vuoto")
    }

    let seen = ()
    for set-name in all-sets {
      if type(set-name) != str {
        fail("sets contiene un valore non stringa")
      }
      if set-name in seen {
        fail("sets contiene il duplicato \"" + set-name + "\"")
      }
      seen = seen + (set-name,)
    }
  }

  let resolve-metadata(set-name) = {
    if not has-key(descriptor, "metadata") {
      fail("manca metadata")
    }

    let meta = descriptor.at("metadata")
    if not is-dict(meta) {
      fail("metadata deve essere un oggetto")
    }

    let class = resolve-attribute(meta, "class", none, set-name, all-sets, "metadata")
    let title = resolve-attribute(meta, "title", none, set-name, all-sets, "metadata")
    let subtitle = resolve-attribute(meta, "subtitle", "", set-name, all-sets, "metadata")
    let top = resolve-attribute(meta, "top", none, set-name, all-sets, "metadata")
    let author = resolve-attribute(meta, "author", "Marini Mattia", set-name, all-sets, "metadata")
    let duration = resolve-attribute(meta, "duration", none, set-name, all-sets, "metadata")

    if class == none {
      fail("metadata.class è obbligatorio")
    }
    if type(class) != str {
      fail("metadata.class deve essere una stringa")
    }
    if title == none {
      fail("metadata.title è obbligatorio")
    }
    if type(title) != str {
      fail("metadata.title deve essere una stringa")
    }
    if type(subtitle) != str {
      fail("metadata.subtitle deve essere una stringa")
    }
    if top != none and type(top) != str {
      fail("metadata.top deve essere una stringa")
    }
    if type(author) != str {
      fail("metadata.author deve essere una stringa")
    }
    if duration == none {
      fail("metadata.duration è obbligatorio")
    }
    if type(duration) != int and type(duration) != float {
      fail("metadata.duration deve essere un numero")
    }
    if duration <= 0 {
      fail("metadata.duration deve essere positivo")
    }

    (
      class: class,
      title: title,
      subtitle: subtitle,
      top: top,
      author: author,
      duration: duration,
    )
  }

  let resolve-exercises(category, category-id, category-tag, category-sets, set-name) = {
    if not has-key(category, "exercises") {
      fail("la categoria " + category-id + " non ha exercises")
    }

    let exercises = category.at("exercises")
    if not is-array(exercises) {
      fail("category " + category-id + ".exercises deve essere un array")
    }

    let resolved = ()
    let numero = 0
    let points = 0

    for exercise in exercises {
      if not is-dict(exercise) {
        fail("category " + category-id + ": ogni esercizio deve essere un oggetto")
      }

      let exercise-id = required-string(exercise, "id", "category " + category-id + " exercise")
      let exercise-sets = effective-sets(
        exercise,
        category-sets,
        "exercise " + exercise-id,
      )

      if set-name in exercise-sets {
        let file = resolve-path(base-dir, required-string(exercise, "file", "exercise " + exercise-id))
        let title = resolve-attribute(
          exercise,
          "title",
          none,
          set-name,
          exercise-sets,
          "exercise " + exercise-id,
        )
        let points-value = resolve-attribute(
          exercise,
          "points",
          none,
          set-name,
          exercise-sets,
          "exercise " + exercise-id,
        )
        let difficulty = resolve-attribute(
          exercise,
          "difficulty",
          none,
          set-name,
          exercise-sets,
          "exercise " + exercise-id,
        )

        if title == none {
          fail("exercise " + exercise-id + ".title è obbligatorio")
        }
        if type(title) != str {
          fail("exercise " + exercise-id + ".title deve essere una stringa")
        }
        if points-value == none {
          fail("exercise " + exercise-id + ".points è obbligatorio")
        }
        if type(points-value) != int and type(points-value) != float {
          fail("exercise " + exercise-id + ".points deve essere un numero")
        }
        if points-value < 0 {
          fail("exercise " + exercise-id + ".points deve essere non negativo")
        }
        if difficulty == none {
          fail("exercise " + exercise-id + ".difficulty è obbligatorio")
        }
        if type(difficulty) != int {
          fail("exercise " + exercise-id + ".difficulty deve essere un intero")
        }
        if difficulty < 1 or difficulty > 5 {
          fail("exercise " + exercise-id + ".difficulty deve essere fra 1 e 5")
        }

        numero = numero + 1
        points = points + points-value

        resolved = (
          resolved
            + (
              (
                id: exercise-id,
                file: file,
                category: category-id,
                tag: category-tag,
                title: title,
                points: points-value,
                difficulty: difficulty,
                numero: numero,
              ),
            )
        )
      }
    }

    (
      exercises: resolved,
      points: points,
    )
  }

  let resolve-exam(set-name) = {
    validate-descriptor()

    if not (set-name in all-sets) {
      fail("set sconosciuto: " + set-name)
    }

    let metadata = resolve-metadata(set-name)

    if not has-key(descriptor, "categories") {
      fail("manca categories")
    }

    let categories = descriptor.at("categories")
    if not is-array(categories) {
      fail("categories deve essere un array")
    }

    // Validate exercise IDs globally, including categories not selected by this set.
    let exercise-ids = ()
    for category in categories {
      if is-dict(category) {
        if has-key(category, "exercises") {
          let category-exercises = category.at("exercises")
          if is-array(category-exercises) {
            for exercise in category-exercises {
              if is-dict(exercise) {
                if has-key(exercise, "id") {
                  let exercise-id = exercise.at("id")
                  if type(exercise-id) == str {
                    if exercise-id in exercise-ids {
                      fail("id esercizio duplicato: " + exercise-id)
                    }
                    exercise-ids = exercise-ids + (exercise-id,)
                  }
                }
              }
            }
          }
        }
      }
    }

    let resolved-categories = ()
    let category-ids = ()

    for category in categories {
      if not is-dict(category) {
        fail("ogni categoria deve essere un oggetto")
      }

      let category-id = required-string(category, "id", "category")
      if category-id in category-ids {
        fail("id categoria duplicato: " + category-id)
      }
      category-ids = category-ids + (category-id,)

      let category-sets = effective-sets(category, all-sets, "category " + category-id)

      if set-name in category-sets {
        let tag = resolve-attribute(category, "tag", none, set-name, category-sets, "category " + category-id)
        let title = resolve-attribute(category, "title", none, set-name, category-sets, "category " + category-id)
        let intro = if has-key(category, "intro") {
          resolve-path(base-dir, required-string(category, "intro", "category " + category-id))
        } else {
          none
        }

        if tag == none {
          fail("category " + category-id + ".tag è obbligatorio")
        }
        if type(tag) != str {
          fail("category " + category-id + ".tag deve essere una stringa")
        }
        if title == none {
          fail("category " + category-id + ".title è obbligatorio")
        }
        if type(title) != str {
          fail("category " + category-id + ".title deve essere una stringa")
        }

        let result = resolve-exercises(
          category,
          category-id,
          tag,
          category-sets,
          set-name,
        )

        if result.exercises.len() > 0 {
          resolved-categories = (
            resolved-categories
              + (
                (
                  id: category-id,
                  tag: tag,
                  title: title,
                  intro: intro,
                  exercises: result.exercises,
                  points: result.points,
                ),
              )
          )
        }
      }
    }

    if resolved-categories.len() == 0 {
      fail("il set \"" + set-name + "\" non contiene esercizi")
    }

    let total = resolved-categories.fold(0, (acc, category) => acc + category.points)
    let expected = resolve-attribute(
      descriptor,
      "max-points",
      none,
      set-name,
      all-sets,
      "max-points",
    )

    if expected != none {
      if type(expected) != int and type(expected) != float {
        fail("max-points deve essere un numero")
      }
      if expected != total {
        fail(
          "max-points per il set \"" + set-name + "\" è " + str(expected) + " ma gli esercizi sommano " + str(total),
        )
      }
    }

    (
      variant: set-name,
      metadata: metadata,
      categories: resolved-categories,
      total: total,
      max-points: expected,
    )
  }

  let exam = resolve-exam(set-name)
  let meta = exam.metadata

  set document(title: meta.title, author: meta.author)
  show: doc => theme(doc, footer-text: meta.title)

  let top = if meta.top == none {
    "LICEO RUSSELL · INFORMATICA · CLASSE " + meta.class
  } else {
    meta.top
  }

  let descriptors = (
    ("Durata", str(meta.duration) + " minuti"),
    ("Punteggio", str(exam.total) + " punti"),
  )
  for category in exam.categories {
    descriptors = descriptors + ((category.tag, str(category.points) + " punti"),)
  }

  cover(
    top: top,
    title: meta.title,
    subtitle: meta.subtitle,
    decoration: auto,
    descriptors: descriptors,
    student-data: none,
  )
  pagebreak()

  let preamble-path = if has-key(descriptor, "preamble-file") {
    resolve-path(base-dir, required-string(descriptor, "preamble-file", "preamble-file"))
  } else {
    "/typst-theme/src/preamble.typ"
  }
  include preamble-path

  istruzioni-consegna()
  griglia-voti2(exam.categories, titolo: "Riepilogo dei punteggi")
  pagebreak()

  for pair in exam.categories.enumerate() {
    let index = pair.at(0)
    let category = pair.at(1)

    if index > 0 {
      pagebreak()
    }

    heading(level: 1)[#category.title]

    if category.intro != none {
      include category.intro
    }

    for exercise in category.exercises {
      quesito2(exercise)[#include exercise.file]
    }
  }
}
