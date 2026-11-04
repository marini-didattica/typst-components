// Backward-compatible entry point for the JSON correction renderer.
//
// Existing documents import `/typst-components/src/correction.typ`; keep that
// path working while the implementation lives in `documents/correction.typ`.

#import "documents/correction.typ": load-correction, render-correction
