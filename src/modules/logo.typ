// The logo of beimgraben.net: the name in JetBrains Mono and three pixels.

#let _source = read("../assets/logo/logo.svg")

// The logo with the name in `color`. The three pixels keep their colors.
// The SVG has a margin of 40 units on each side; `trim` cuts it off, so the
// pixels touch the edge of the box.
#let logo(color: black, height: 1cm, trim: true) = {
  let svg = _source.replace("#1e1839", color.to-hex())
  if not trim {
    return image(bytes(svg), format: "svg", height: height)
  }
  // 1600 x 320 with a 40 unit margin, so the content is 1520 x 240.
  let svg = svg.replace("viewBox=\"0 0 1600 320\"", "viewBox=\"40 40 1520 240\"")
    .replace("width=\"1600\" height=\"320\"", "width=\"1520\" height=\"240\"")
  image(bytes(svg), format: "svg", height: height)
}

// The three pixels of the logo around `body`, as on the preview card of the
// website: cyan top left, lime bottom left, magenta top right.
#let pixel-frame(body, size: 0.5em, gap: 0.35em, colors: auto) = context {
  import "../config/colors.typ": brand
  let (c1, c2, c3) = if colors == auto {
    (brand.cyan, brand.lime, brand.magenta)
  } else { colors }
  let square(fill) = box(width: size, height: size, fill: fill)
  grid(
    columns: (size, auto, size),
    rows: (size, auto, size),
    column-gutter: gap,
    row-gutter: 0pt,
    square(c1), [], square(c3),
    [], body, [],
    square(c2), [], [],
  )
}
