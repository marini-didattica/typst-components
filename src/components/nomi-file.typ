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
