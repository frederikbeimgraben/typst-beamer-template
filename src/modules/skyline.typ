// The pixel skyline at the top edge of beimgraben.net.
//
// The site masks a 25 x 2 pixel strip (img/header.png) and repeats it along
// the top of the page. The strip is copied here as bits, so it can take any
// color and stays sharp at every size.

#let _pattern = (
  "1000111011111110110011110",
  "1101001100011111100010001",
)

// An SVG of the strip, repeated until it covers `width`.
#let _svg(color, repeats) = {
  let cols = _pattern.first().len()
  let rects = ()
  for (row, bits) in _pattern.enumerate() {
    for r in range(repeats) {
      for (col, bit) in bits.clusters().enumerate() {
        if bit == "1" {
          rects.push(
            "<rect x=\"" + str(r * cols + col) + "\" y=\"" + str(row)
              + "\" width=\"1.02\" height=\"1.02\"/>",
          )
        }
      }
    }
  }
  let hex = color.to-hex()
  (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 "
      + str(repeats * cols) + " " + str(_pattern.len())
      + "\" shape-rendering=\"crispEdges\"><g fill=\"" + hex + "\">"
      + rects.join() + "</g></svg>"
  )
}

// The skyline across `width`, with pixels of size `cell`.
#let skyline(width, color: black, cell: 0.2cm) = {
  let cols = _pattern.first().len()
  let repeats = int(calc.ceil(width / (cell * cols)))
  box(
    width: width,
    height: cell * _pattern.len(),
    clip: true,
    image(
      bytes(_svg(color, repeats)),
      format: "svg",
      width: cell * cols * repeats,
      height: cell * _pattern.len(),
    ),
  )
}
