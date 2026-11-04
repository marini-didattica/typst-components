// Question and exercise blocks.

#import "../theme/labels.typ": sezione-corrente
#import "../theme/spacing.typ": spazio
#import "nomi-file.typ": nome-file
#import "righe-risposta.typ": righe-risposta
#import "riepilogo.typ": registro-quesiti
#import "testata.typ": testata

/// Single component for theory questions, exercises and code snippets.
///
/// - `category`: short code used in the summary (e.g. `"D"`, `"E"`, `"S"`)
/// - `tag`: label shown in the badge (e.g. `"Domanda"`)
/// - `title`: item title
/// - `diff`: number of difficulty stars, or `none`
/// - `points`: maximum score
/// - `righe`: number of answer lines, or `none`
/// - `numero`: explicit number; when `auto` a counter per category is used
#let quesito(
  corpo,
  category: "D",
  tag: "Domanda",
  title: none,
  diff: none,
  points: 0,
  righe: none,
  numero: auto,
) = {
  let contatore = counter("quesito-" + category)
  if numero == auto { contatore.step() }

  context {
    let n = if numero == auto { contatore.get().first() } else { numero }
    let sezione = sezione-corrente.get()
    registro-quesiti.update(voci => (
      voci
        + (
          (
            category: category,
            tag: tag,
            title: title,
            max: points,
            numero: n,
            heading: sezione,
          ),
        )
    ))
  }

  let etichetta-numero = if numero == auto {
    context contatore.display()
  } else {
    numero
  }

  let contenuto = [
    #testata(tag, etichetta-numero, title, diff: diff, massimo: points)
    #v(spazio.page.md)
    #corpo
    #if righe != none [
      #righe-risposta(righe)
    ]
  ]

  if righe == none {
    block(above: spazio.xl, width: 100%)[#contenuto]
  } else {
    block(above: spazio.xl, breakable: false, width: 100%)[#contenuto]
  }
}

/// Data-driven question block.
///
/// `item` is a dictionary produced by an exam parser. Expected keys:
/// - `numero`: displayed number within the category
/// - `tag`: badge label
/// - `title`: item title
/// - `points`: maximum score
/// - `difficulty`: number of difficulty stars, or `none`
///
/// The problem body is passed separately, usually as `[#include item.file]`.
/// The header also shows the name of the solution file, derived from the item
/// tag and number (e.g. `esercizio01.py`).
#let quesito2(item, body) = {
  let numero = item.at("numero")
  let tag = item.at("tag")
  let title = item.at("title", default: none)
  let points = item.at("points", default: 0)
  let difficulty = item.at("difficulty", default: none)
  let file = nome-file(item, padding: 2)

  block(above: spazio.xl, width: 100%)[
    #testata(tag, numero, title, diff: difficulty, massimo: points, file: file)
    #v(spazio.page.md)
    #body
  ]
}
