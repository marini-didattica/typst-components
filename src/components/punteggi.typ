// Score formatting and grade conversion.

/// Format a score using the Italian decimal comma.
#let fmt-punti(x) = str(x).replace(".", ",")

/// Format a grade in tenths with one decimal digit.
#let fmt-voto(x) = fmt-punti(calc.round(x, digits: 1))

/// Map a raw score onto the grade range.
///
/// The interval `0..base` is linearly mapped onto `voto-min..voto-max`.
/// Scores above `base` are capped at `voto-max` (the extra points only
/// determine whether the grade deserves honours).
#let calcola-voto(
  totale,
  base: 100,
  voto-min: 3,
  voto-max: 10,
) = {
  let normalizzato = if base <= 0 {
    0
  } else {
    calc.min(calc.max(totale, 0), base) / base
  }
  voto-min + normalizzato * (voto-max - voto-min)
}
