// File-name helpers shared by generated exams and delivery instructions.

/// Extension of the file used for an item, based on its badge label.
#let estensione-file(tag) = if tag == "Esercizio" { ".py" } else { ".txt" }

/// Lowercase badge label without spaces, e.g. `"Esercizio"` -> `"esercizio"`.
#let slug-tag(tag) = lower(tag).replace(" ", "")

/// Zero-pad a number to at least `width` digits.
#let zero-pad(numero, width: 2) = {
  let testo = str(numero)
  let mancanti = width - testo.len()
  if mancanti <= 0 {
    testo
  } else {
    "0" * mancanti + testo
  }
}

/// File name for an exercise or question dictionary.
///
/// `item` must contain `tag` and `numero`. `padding` is the minimum number of
/// digits used for the number: pass `padding: 2` for solution files such as
/// `esercizio01.py`, leave it at `0` for student submissions such as
/// `esercizio1.py`.
#let nome-file(item, padding: 0) = {
  let numero = if padding > 0 {
    zero-pad(item.numero, width: padding)
  } else {
    str(item.numero)
  }
  slug-tag(item.tag) + numero + estensione-file(item.tag)
}

/// Resolve wildcards in an `answer-file` pattern.
///
/// Supported placeholders:
/// - `{ordinal}`: position of the exercise inside its category for the current set
/// - `{id}`: exercise id from the descriptor (e.g. `E4`)
/// - `{category}`: category id (e.g. `E`)
/// - `{tag}`: lowercase badge label (e.g. `esercizio`)
/// - `{set}`: current exam variant (e.g. `b`)
#let risolvi-answer-file(modello, item, set-name) = {
  let valori = (
    ("{ordinal}", str(item.numero)),
    ("{id}", item.id),
    ("{category}", item.category),
    ("{tag}", slug-tag(item.tag)),
    ("{set}", set-name),
  )

  let risultato = modello
  for (placeholder, valore) in valori {
    risultato = risultato.replace(placeholder, valore)
  }
  risultato
}

/// File name of the answer for an item.
///
/// Uses the `answer-file` field when present, otherwise falls back to the
/// conventional name derived from the badge tag and number.
#let nome-risposta(item, padding: 0) = {
  let configurato = item.at("answer-file", default: none)
  if configurato == none {
    nome-file(item, padding: padding)
  } else {
    configurato
  }
}
