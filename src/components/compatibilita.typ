// Backward-compatible wrappers for existing documents.

#import "quesito.typ": quesito
#import "risposta.typ": risposta

#let domanda(n, titolo, punti, righe, corpo) = quesito(
  corpo,
  category: "D",
  tag: "Domanda",
  title: titolo,
  points: punti,
  righe: righe,
  numero: n,
)

#let esercizio(n, titolo, punti, diff, corpo) = quesito(
  corpo,
  category: "E",
  tag: "Esercizio",
  title: titolo,
  diff: diff,
  points: punti,
  numero: n,
)

#let lettura(n, titolo, punti, diff, righe, corpo) = quesito(
  corpo,
  category: "S",
  tag: "Snippet",
  title: titolo,
  diff: diff,
  points: punti,
  righe: righe,
  numero: n,
)

#let risposta-domanda(n, titolo, punti, totale, corpo) = risposta(
  corpo,
  category: "D",
  tag: "Domanda",
  title: titolo,
  points: totale,
  score: punti,
  numero: n,
)

#let risposta-esercizio(n, titolo, punti, totale, diff, corpo) = risposta(
  corpo,
  category: "E",
  tag: "Esercizio",
  title: titolo,
  diff: diff,
  points: totale,
  score: punti,
  numero: n,
)

#let risposta-snippet(n, titolo, punti, totale, diff, corpo) = risposta(
  corpo,
  category: "S",
  tag: "Snippet",
  title: titolo,
  diff: diff,
  points: totale,
  score: punti,
  numero: n,
)
