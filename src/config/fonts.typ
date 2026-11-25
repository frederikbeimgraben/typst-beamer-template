// Font and size steps of the slides.
//
// The website sets every text in JetBrains Mono, so the slides do the same.
// The fonts lie in src/assets/fonts; pass `--font-path src/assets/fonts` or
// install them once (see README).

#let font = ("JetBrains Mono", "DejaVu Sans Mono")

// A monospaced face runs wide, so the steps are a little smaller than in a
// proportional slide set.
#let sizes = (
  tiny: 9pt,
  small: 12pt,
  normal: 16pt,
  large: 20pt,
  frame-title: 24pt,
  section: 34pt,
  title: 38pt,
)
