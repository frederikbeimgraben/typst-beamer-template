// Info boxes in the style of the website: a tinted surface, a colored bar on
// the left and a pixel in front of the title.

#import "../config/colors.typ": palette-state

// A box with a title in `color`. `color` is a color or the name of a role of
// the palette ("info", "success", "warning", "important", "accent").
#let custom-box(title: none, color: "accent", body) = context {
  let p = palette-state.get()
  let color = if type(color) == str { p.at(color) } else { color }
  block(
    width: 100%,
    fill: color.transparentize(if p.appearance == "dark" { 85% } else { 90% }),
    stroke: (left: 3pt + color),
    inset: (left: 0.8em, right: 0.8em, y: 0.65em),
    breakable: false,
    {
      if title != none {
        block(below: 0.5em, text(weight: "bold", fill: color, {
          box(width: 0.45em, height: 0.45em, fill: color, baseline: -0.05em)
          h(0.5em)
          title
        }))
      }
      body
    },
  )
}

#let info-box(title: [Info], body) = custom-box(title: title, color: "info", body)
#let success-box(title: [Erledigt], body) = custom-box(title: title, color: "success", body)
#let warning-box(title: [Achtung], body) = custom-box(title: title, color: "warning", body)
#let important-box(title: [Wichtig], body) = custom-box(title: title, color: "important", body)
