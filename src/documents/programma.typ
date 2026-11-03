// Programme document template.

#import "../theme/didattica.typ": tema-didattica
#import "../components/programma/copertina.typ": copertina-programma

/// Render a "programmazione didattica" document.
///
/// Use as a show rule:
///
/// ```typ
/// #show: programma-didattica.with(
///   classe: "1D",
///   docente: "Prof. Mattia Marini",
///   anno-scolastico: "2026/27",
///   ore-annue: 66,
/// )
/// ```
///
/// The body contains a `#quadro[...]` framework table followed by one
/// `#modulo(...)[...]` per teaching module.
#let programma-didattica(
  body,
  classe: none,
  docente: none,
  anno-scolastico: none,
  ore-annue: none,
  ore-consuntivo: "/",
  materia: "Informatica",
  indirizzo: "Liceo Scientifico – Opzione Scienze Applicate",
  istituto: "LICEO B. RUSSELL",
  sede: "Via IV Novembre 35 – 38023 Cles",
  titolo: "PROGRAMMAZIONE DIDATTICA",
) = {
  let obbligatorio(nome, valore) = {
    if valore == none {
      panic("programma-didattica: argomento obbligatorio mancante: " + nome)
    }
  }

  obbligatorio("classe", classe)
  obbligatorio("docente", docente)
  obbligatorio("anno-scolastico", anno-scolastico)
  obbligatorio("ore-annue", ore-annue)

  set document(
    title: "Programmazione didattica — " + materia + " — Classe " + classe,
  )
  show: doc => tema-didattica(doc)

  copertina-programma(
    classe: classe,
    docente: docente,
    anno-scolastico: anno-scolastico,
    ore-annue: ore-annue,
    ore-consuntivo: ore-consuntivo,
    materia: materia,
    indirizzo: indirizzo,
    istituto: istituto,
    sede: sede,
    titolo: titolo,
  )
  pagebreak()
  body
}
