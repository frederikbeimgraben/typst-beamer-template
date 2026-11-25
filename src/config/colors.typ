// Color palettes of beimgraben.net.
//
// The website runs the Congo theme with three color variants, "blue" (the
// default), "bordeaux" and "violet", each in a light and a dark appearance.
// The values below are the CSS custom properties of the site, so the slides
// and the website use the same colors.

#let _scale(..values) = {
  let steps = (50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950)
  let values = values.pos()
  let result = (:)
  for (i, step) in steps.enumerate() {
    result.insert(str(step), rgb(..values.at(i)))
  }
  result
}

// The colors of the logo: the three pixels around "beimgraben.net".
#let brand = (
  navy: rgb("#1e1839"),
  cyan: rgb("#22d3ee"),
  lime: rgb("#a3e635"),
  magenta: rgb("#d946ef"),
  // The same hues one step darker, for marks on a light background.
  cyan-dark: rgb("#0891b2"),
  lime-dark: rgb("#65a30d"),
  magenta-dark: rgb("#c026d3"),
  amber: rgb("#f59e0b"),
  amber-dark: rgb("#d97706"),
)

// Tailwind zinc, the neutral scale of the violet variant.
#let _zinc = _scale(
  (250, 250, 250), (244, 244, 245), (228, 228, 231), (212, 212, 216),
  (161, 161, 170), (113, 113, 122), (82, 82, 91), (63, 63, 70),
  (39, 39, 42), (24, 24, 27), (3, 7, 18),
)

#let themes = (
  blue: (
    primary: _scale(
      (242, 241, 255), (228, 225, 255), (202, 197, 246), (168, 162, 233),
      (133, 131, 212), (101, 98, 190), (73, 67, 156), (53, 47, 120),
      (40, 34, 90), (33, 27, 68), (30, 24, 57),
    ),
    neutral-light: _scale(
      (248, 247, 253), (237, 235, 248), (219, 215, 240), (189, 183, 222),
      (143, 135, 186), (101, 94, 150), (73, 67, 122), (55, 49, 99),
      (40, 34, 90), (33, 27, 68), (30, 24, 57),
    ),
    neutral-dark: _scale(
      (246, 245, 252), (232, 229, 247), (214, 210, 238), (196, 191, 228),
      (162, 155, 205), (130, 123, 178), (95, 88, 145), (58, 50, 110),
      (30, 24, 57), (22, 17, 44), (15, 12, 30),
    ),
    skyline-light: rgb(30, 24, 57),
  ),
  bordeaux: (
    primary: _scale(
      (255, 241, 246), (255, 225, 236), (249, 192, 210), (242, 155, 182),
      (224, 104, 142), (201, 68, 115), (169, 46, 91), (138, 33, 70),
      (118, 25, 60), (107, 20, 56), (100, 16, 52),
    ),
    neutral-light: _scale(
      (253, 247, 249), (250, 235, 240), (242, 214, 224), (229, 178, 197),
      (205, 126, 156), (175, 79, 116), (146, 48, 86), (130, 35, 71),
      (118, 25, 60), (107, 20, 56), (100, 16, 52),
    ),
    neutral-dark: _scale(
      (253, 246, 249), (250, 233, 239), (245, 213, 225), (237, 191, 208),
      (219, 154, 179), (198, 113, 145), (170, 76, 112), (138, 45, 81),
      (100, 16, 52), (78, 11, 40), (56, 8, 29),
    ),
    skyline-light: rgb(100, 16, 52),
  ),
  violet: (
    primary: _scale(
      (245, 243, 255), (237, 233, 254), (221, 214, 254), (196, 181, 253),
      (167, 139, 250), (139, 92, 246), (124, 58, 237), (109, 40, 217),
      (91, 33, 182), (76, 29, 149), (46, 16, 101),
    ),
    neutral-light: _zinc,
    // The site turns the dark background of this variant black.
    neutral-dark: {
      let scale = _zinc
      scale.insert("800", rgb(0, 0, 0))
      scale
    },
    skyline-light: rgb(0, 0, 0),
  ),
)

// The colors of one slide set. Every module reads its colors from here.
//
// The roles follow the website: the page is `neutral` (white) in the light
// appearance and `neutral-800` in the dark appearance, the text is
// `neutral-900` or white, links and marks use the primary scale.
#let palette(theme: "blue", appearance: "dark") = {
  assert(
    theme in themes,
    message: "theme is one of " + themes.keys().map(repr).join(", "),
  )
  assert(
    appearance in ("light", "dark"),
    message: "appearance is \"light\" or \"dark\"",
  )
  let t = themes.at(theme)
  let p = t.primary
  if appearance == "dark" {
    let n = t.neutral-dark
    (
      theme: theme,
      appearance: appearance,
      primary: p,
      neutral: n,
      bg: n.at("800"),
      surface: n.at("900"),
      surface-alt: n.at("700"),
      text: white,
      text-muted: n.at("300"),
      text-subtle: n.at("400"),
      heading: white,
      accent: p.at("400"),
      link: p.at("300"),
      rule: n.at("600"),
      skyline: white,
      logo: white,
      marks: (brand.cyan, brand.lime, brand.magenta),
      info: brand.cyan,
      success: brand.lime,
      warning: brand.amber,
      important: brand.magenta,
      focus-bg: p.at("600"),
      focus-text: white,
    )
  } else {
    let n = t.neutral-light
    (
      theme: theme,
      appearance: appearance,
      primary: p,
      neutral: n,
      bg: white,
      surface: n.at("50"),
      surface-alt: n.at("100"),
      text: n.at("900"),
      text-muted: n.at("700"),
      text-subtle: n.at("500"),
      heading: n.at("950"),
      accent: p.at("600"),
      link: p.at("700"),
      rule: n.at("200"),
      skyline: t.skyline-light,
      logo: n.at("950"),
      marks: (brand.cyan-dark, brand.lime-dark, brand.magenta-dark),
      info: brand.cyan-dark,
      success: brand.lime-dark,
      warning: brand.amber-dark,
      important: brand.magenta-dark,
      focus-bg: p.at("950"),
      focus-text: white,
    )
  }
}

// The palette of the running presentation, for the functions that the
// slides call inside the document body.
#let palette-state = state("bgslides-palette", palette())
