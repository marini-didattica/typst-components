// typst-components — shared theme, components and document templates for the
// Liceo Russell Typst materials.

// Theme: colours, fonts, spacing, labels, running state and show rules.
#import "theme/lib.typ": *

// Reusable blocks for exams and corrections.
#import "components/lib.typ": *

// Document-level renderers.
#import "documents/exam.typ": (
  parent-path,
  path-string,
  resolve-path,
  load-exam,
  render-exam,
)
#import "documents/correction.typ": load-correction, render-correction
#import "documents/stats.typ": load-stats, render-stats
#import "documents/programma.typ": programma-didattica
