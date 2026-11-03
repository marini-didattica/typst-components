// Difficulty stars.

#import "../theme/palette.typ": palette

#let stella(pieno: true, dim: 0.78em, col: palette.amber) = {
  let r = dim / 2
  let pts = ()
  for i in range(10) {
    let a = 90deg - i * 36deg
    let rad = if calc.rem(i, 2) == 0 { r } else { r * 0.42 }
    pts.push((r + rad * calc.cos(a), r - rad * calc.sin(a)))
  }
  box(baseline: 40%)[
    #polygon(fill: if pieno { col } else { none }, stroke: 1pt + col, ..pts)
  ]
}

#let stelle(n) = box(baseline: 40%)[
  #for i in range(5) {
    if i > 0 { h(2pt) }
    stella(pieno: i < n)
  }
]
