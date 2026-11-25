// The pixel skyline at the top edge of beimgraben.net.
//
// The site masks a 25 x 2 pixel strip (img/header.png) and repeats it along
// the top of the page. The strip is copied here as bits, so it can take any
// color and stays sharp at every size.

#let _pattern = (
  "1000111011111110110011110",
  "1101001100011111100010001",
)

// An SVG of the strip, repeated until it covers `width`. Each row becomes
// runs of filled cells, and all runs form one path. Separate squares would
// leave hairline gaps between neighbors in most PDF viewers.
#let _svg(color, repeats) = {
  let runs = ()
  for (row, bits) in _pattern.enumerate() {
    let cells = bits.clusters() * repeats
    let start = none
    for (col, bit) in (cells + ("0",)).enumerate() {
      if bit == "1" and start == none { start = col }
      if bit != "1" and start != none {
        runs.push(
          "M" + str(start) + " " + str(row) + "H" + str(col)
            + "V" + str(row + 1) + "H" + str(start) + "Z",
        )
        start = none
      }
    }
  }
  let cols = _pattern.first().len()
  (
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 "
      + str(repeats * cols) + " " + str(_pattern.len())
      + "\"><path fill=\"" + color.to-hex() + "\" d=\""
      + runs.join() + "\"/></svg>"
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
