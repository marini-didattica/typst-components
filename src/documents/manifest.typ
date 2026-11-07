// Exam manifest and roster helpers shared by corrections and statistics.

#import "exam.typ": parent-path, path-string, resolve-path

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

/// Turn a folder slug such as `battocletti-alessandro` into a display name.
#let name-from-slug(value) = {
  value
    .split("-")
    .map(part => {
      if part.len() == 0 {
        part
      } else {
        upper(part.slice(0, 1)) + part.slice(1)
      }
    })
    .join(" ")
}

/// Load a JSON object, failing with a useful label when the file is not an
/// object.
#let load-json-object(path, label) = {
  let value = json(path)
  if type(value) != dictionary {
    panic(label + ": expected a JSON object at " + path)
  }
  value
}

/// Load the student roster.
#let load-roster(path) = load-json-object(path, "roster")

/// Derive the class folder name from a corrections folder:
/// `<track>/<class>/<exam>/correzioni` -> `<class>`.
#let class-from-corrections-dir(corrections-dir) = {
  let exam-dir = parent-path(corrections-dir)
  let class-dir = parent-path(exam-dir)
  file-name(class-dir)
}

/// Resolve the manifest path for a corrections folder.
#let manifest-path-for(corrections-dir, manifest-file: none) = {
  let exam-dir = parent-path(corrections-dir)
  if manifest-file == none {
    resolve-path(exam-dir, "manifest.json")
  } else {
    if type(manifest-file) != str or manifest-file.len() == 0 {
      panic("manifest-file must be a non-empty string")
    }
    resolve-path(exam-dir, manifest-file)
  }
}

/// Load and validate an exam manifest.
#let load-manifest(manifest-path) = {
  let descriptor = load-json-object(manifest-path, "manifest")
  let fail(message) = panic("manifest: " + message)
  let has-key(key) = descriptor.keys().contains(key)

  let allowed-keys = (
    "$schema",
    "version",
    "test-json",
    "answer-folder",
    "date",
    "title",
    "subtitle",
    "import-answers",
  )
  for key in descriptor.keys() {
    if not (key in allowed-keys) {
      fail("unknown key: " + key)
    }
  }

  if not has-key("version") or descriptor.at("version") != 1 {
    fail("unsupported or missing version")
  }

  let required-string(key) = {
    if not has-key(key) or type(descriptor.at(key)) != str or descriptor.at(key).len() == 0 {
      fail("\"" + key + "\" must be a non-empty string")
    }
    descriptor.at(key)
  }
  let optional-string(key, default) = {
    if not has-key(key) {
      return default
    }
    let value = descriptor.at(key)
    if type(value) != str {
      fail("\"" + key + "\" must be a string")
    }
    value
  }
  let optional-bool(key, default) = {
    if not has-key(key) {
      return default
    }
    let value = descriptor.at(key)
    if type(value) != bool {
      fail("\"" + key + "\" must be a boolean")
    }
    value
  }

  let base-dir = parent-path(path-string(manifest-path))
  (
    path: path-string(manifest-path),
    base-dir: base-dir,
    test-json: resolve-path(base-dir, required-string("test-json")),
    answer-folder: resolve-path(
      base-dir,
      optional-string("answer-folder", "risposte"),
    ),
    date: required-string("date"),
    title: optional-string("title", none),
    subtitle: optional-string("subtitle", none),
    import-answers: optional-bool("import-answers", true),
  )
}

/// Read the roster entry for one class/student pair.
#let roster-entry(roster, class, slug) = roster.at(class + "/" + slug, default: none)

/// Derive a display name from a roster entry, falling back to the slug.
#let student-name-from-entry(entry, slug) = {
  if entry == none {
    return name-from-slug(slug)
  }

  let first = entry.at("owner-first-names", default: ())
  let last = entry.at("owner-last-names", default: ())
  let words = first + last
  if words.len() == 0 {
    name-from-slug(slug)
  } else {
    words.join(" ")
  }
}

/// Build the path of one student's correction descriptor.
#let correction-path-for(corrections-dir, slug) = {
  resolve-path(corrections-dir, slug + ".json")
}
