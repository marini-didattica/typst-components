// Backward-compatible entry point for the JSON exam renderer.
//
// Existing documents import `/typst-components/src/exam.typ`; keep that path
// working while the implementation lives in `documents/exam.typ`.

#import "documents/exam.typ": parent-path, resolve-path, render-exam
