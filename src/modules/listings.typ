// Code: a block on the surface color with the line numbers in the margin,
// like the code blocks of the website.

#import "../config/colors.typ": palette-state

#let listings(number-lines: true, body) = {
  show raw: set text(font: ("JetBrains Mono", "DejaVu Sans Mono"))
  show raw.where(block: false): it => context {
    let p = palette-state.get()
    box(
      fill: p.surface-alt,
      inset: (x: 0.25em),
      outset: (y: 0.25em),
      radius: 2pt,
      text(fill: p.text, it),
    )
  }
  show raw.where(block: true): set par(leading: 0.6em, justify: false)
  show raw.where(block: true): it => context {
    let p = palette-state.get()
    let content = if number-lines {
      // One row per line, so a wrapped line keeps its number on top.
      grid(
        columns: (auto, 1fr),
        column-gutter: 0.8em,
        row-gutter: 0.6em,
        align: (right + top, left + top),
        ..it.lines.map(line => (
          text(fill: p.text-subtle, str(line.number)),
          line,
        )).flatten(),
      )
    } else { it }
    block(
      width: 100%,
      fill: p.surface,
      stroke: (left: 3pt + p.accent),
      inset: (x: 0.9em, y: 0.75em),
      radius: (right: 3pt),
      breakable: false,
      content,
    )
  }
  body
}
