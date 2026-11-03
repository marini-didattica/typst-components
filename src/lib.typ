// typst-components — shared theme, components and document templates for the
// Liceo Russell Typst materials.

// Theme: colours, fonts, spacing, labels, running state and show rules.
#import "theme/lib.typ": *

// Reusable blocks for exams and corrections.
#import "components/lib.typ": *

// Document-level renderers.
#import "documents/exam.typ": parent-path, resolve-path, render-exam
#import "documents/programma.typ": programma-didattica
