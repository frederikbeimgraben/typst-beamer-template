// bgslides - a presentation template in the style of beimgraben.net.
//
// The slides take the colors, the font, the logo and the pixel skyline of the
// website. The structure follows the slides of hsrtreport-typst: a level 1
// heading opens a section with its own section slide, a level 2 heading opens
// a new slide and becomes its title.
//
// License: Creative Commons CC BY-SA 4.0, see LICENSE and LICENSE-MIT-0.

#import "config/colors.typ": brand, palette, palette-state, themes
#import "config/fonts.typ": font, sizes
#import "modules/skyline.typ": skyline
#import "modules/logo.typ": logo, pixel-frame
#import "modules/boxes.typ": custom-box, important-box, info-box, success-box, warning-box
#import "modules/listings.typ": listings
#import "modules/highlight.typ": syntax-theme

// ---------------------------------------------------------------------------
// Steps

// The current step of a slide with `steps`, for `only` and `uncover`.
#let _step = state("bgslides-step", 1)

#let _matches(steps, current) = {
  if type(steps) == int { return current == steps }
  if type(steps) == array { return current in steps }
  if type(steps) == str {
    let (from, to) = steps.split("-").map(part => part.trim())
    let from = if from == "" { 1 } else { int(from) }
    let to = if to == "" { calc.inf } else { int(to) }
    return current >= from and current <= to
  }
  panic("steps is a number, an array of numbers or a range like \"2-\"")
}

// Shows `body` on the given steps of a slide and leaves no space on the other
// steps. `steps` is a number, an array of numbers, or a string such as "2-"
// (from step 2 on) or "1-3".
#let only(steps, body) = context {
  if _matches(steps, _step.get()) { body }
}

// Shows `body` on the given steps of a slide. On the other steps the space
// stays reserved, so the layout does not jump.
#let uncover(steps, body) = context {
  if _matches(steps, _step.get()) { return body }
  set list(marker: _ => hide[•])
  set enum(numbering: (..numbers) => hide(numbering("1.", ..numbers)))
  hide(body)
}

// A slide. `title` becomes a level 2 heading. With `steps: n` the slide is
// repeated n times, and `only` and `uncover` show their content step by step.
#let slide(title: none, steps: 1, body) = {
  for step in range(1, steps + 1) {
    pagebreak(weak: true)
    _step.update(step)
    if title != none {
      if step == 1 {
        heading(level: 2, title)
      } else {
        // The repeated title stays out of the outline and the bookmarks.
        heading(level: 2, outlined: false, bookmarked: false, title)
      }
    }
    body
  }
  _step.update(1)
}

// ---------------------------------------------------------------------------
// Helpers

// The section that is open on the page.
#let _active-section() = {
  let page-number = here().page()
  let sections = query(heading.where(level: 1))
    .filter(section => section.location().page() <= page-number)
  if sections.len() == 0 { none } else { sections.last() }
}

// True when a level 1 heading starts on the page: the section slide.
#let _is-section-slide() = {
  let page-number = here().page()
  query(heading.where(level: 1)).any(it => it.location().page() == page-number)
}

// A pixel of the logo, sized to the text.
#let pixel(fill, size: 0.45em) = box(
  width: size,
  height: size,
  fill: fill,
  baseline: -0.05em,
)

// Two digits, as the website counts.
#let _two(n) = if n < 10 { "0" + str(n) } else { str(n) }

#let _date(value) = if type(value) == datetime {
  value.display("[day].[month].[year]")
} else {
  value
}

// A short accent line below a title, like the line below the logo of the
// website when the pointer is on it.
#let _underline(p, length: 2.2em) = block(
  above: 0.35em,
  below: 0pt,
  line(length: length, stroke: 2pt + p.accent),
)

// ---------------------------------------------------------------------------
// Page parts

#let _header(p, margin) = context {
  if _is-section-slide() { return }
  let section = _active-section()
  if section == none { return }
  set text(size: sizes.tiny, fill: p.text-subtle)
  align(right + bottom, {
    if section.numbering != none {
      let number = counter(heading).at(section.location()).at(0, default: 0)
      text(fill: p.accent, _two(number))
      h(0.6em)
    }
    section.body
  })
}

#let _footer(p, short-title, author, show-logo) = context {
  let page-number = counter(page).get().at(0, default: 0)
  let total = counter(page).final().at(0, default: 0)
  set text(size: sizes.tiny, fill: p.text-subtle)
  grid(
    columns: (1fr, auto, 1fr),
    align: (left + horizon, center + horizon, right + horizon),
    if show-logo { link("https://beimgraben.net", logo(color: p.logo, height: 0.32cm)) },
    {
      short-title
      if author != none [ #h(0.5em)·#h(0.5em) #author]
    },
    {
      text(fill: p.text, _two(page-number))
      " / "
      _two(total)
    },
  )
}

#let _background(p, paper-width, cell) = place(
  top + left,
  skyline(paper-width, color: p.skyline, cell: cell),
)

// ---------------------------------------------------------------------------
// Special slides

// A slide in a strong color for one statement or a question, framed by the
// pixels of the logo. `fill` sets another color.
#let focus-slide(fill: auto, body) = {
  pagebreak(weak: true)
  context {
    let p = palette-state.get()
    let fill = if fill == auto { p.focus-bg } else { fill }
    page(
      header: none,
      footer: none,
      background: none,
      fill: fill,
      align(center + horizon, text(
        size: sizes.section,
        weight: "extrabold",
        fill: p.focus-text,
        hyphenate: false,
        pixel-frame(gap: 0.4em, size: 0.4em, align(left, body)),
      )),
    )
  }
}

// The list of sections on a slide of its own: section numbers in the accent
// color, titles in bold, the slide number at the right. `depth: 2` adds the
// slides.
#let outline-slide(title: [Inhalt], depth: 1) = {
  pagebreak(weak: true)
  heading(level: 2, outlined: false, bookmarked: false, title)
  context {
    let p = palette-state.get()
    show outline.entry: it => link(it.element.location(), it.indented(
      if it.level == 1 and it.element.numbering != none {
        let number = counter(heading).at(it.element.location()).at(0)
        text(fill: p.accent, weight: "bold", _two(number))
      },
      it.inner(),
      gap: 1em,
    ))
    show outline.entry.where(level: 1): set block(above: 0.9em)
    show outline.entry.where(level: 1): set text(weight: "bold", fill: p.heading)
    show outline.entry.where(level: 2): set block(above: 0.5em)
    show outline.entry.where(level: 2): set text(fill: p.text-muted, size: sizes.small)
    set outline.entry(fill: text(fill: p.rule, repeat(gap: 0.3em)[.]))
    set outline(indent: 2.4em)
    outline(title: none, depth: depth)
  }
}

// Content in columns, 1fr each unless `widths` says otherwise.
#let cols(widths: auto, gutter: 1.2cm, ..cells) = {
  let cells = cells.pos()
  grid(
    columns: if widths == auto { (1fr,) * cells.len() } else { widths },
    column-gutter: gutter,
    ..cells,
  )
}

// Text in the accent color, for a word that matters.
#let alert(body) = context text(fill: palette-state.get().accent, weight: "bold", body)

// A terminal line: a prompt and a command, as on a shell.
#let shell(prompt: "$", body) = context {
  let p = palette-state.get()
  text(fill: p.accent, weight: "bold", prompt)
  h(0.6em)
  body
}

#let _title-slide(p, title, subtitle, rows, margin, paper-width) = page(
  header: none,
  footer: none,
  background: place(top + left, skyline(paper-width, color: p.skyline, cell: 0.35cm)),
  {
    v(1fr)
    pixel-frame(
      size: 0.55cm,
      gap: 0.45cm,
      colors: p.marks,
      {
        block(below: 0pt, text(
          size: sizes.title,
          weight: "extrabold",
          fill: p.heading,
          hyphenate: false,
          title,
        ))
        if subtitle != none {
          block(above: 0.8em, below: 0pt, text(
            size: sizes.large,
            fill: p.accent,
            subtitle,
          ))
        }
      },
    )
    v(1fr)
    set text(size: sizes.small)
    let cells = ()
    for (label, value) in rows {
      if value in (none, "", ()) { continue }
      cells.push(text(fill: p.text-subtle, label))
      cells.push(text(fill: p.text, value))
    }
    grid(
      columns: (auto, 1fr),
      column-gutter: 1.2em,
      row-gutter: 0.55em,
      ..cells,
    )
    v(0.2cm)
    place(
      bottom + right,
      dy: margin.bottom - 0.6cm,
      logo(color: p.logo, height: 0.5cm),
    )
  },
)

// ---------------------------------------------------------------------------
// Template

#let bgslides(
  // Title slide
  title: [Titel des Vortrags],
  subtitle: none,
  short-title: auto,
  author: none,
  email: none,
  date: none,
  event: none,
  institution: none,
  labels: (
    author: "von",
    date: "am",
    event: "bei",
    institution: "für",
  ),
  extra-data: (),
  show-title-slide: true,
  // Look
  theme: "blue",
  appearance: "dark",
  show-logo: true,
  // Layout
  aspect-ratio: "16-9",
  font-size: sizes.normal,
  lang: "de",
  body,
) = {
  let p = palette(theme: theme, appearance: appearance)
  let short-title = if short-title == auto { title } else { short-title }
  let date = _date(date)
  let paper-width = 28cm
  let paper-height = if aspect-ratio == "4-3" { 21cm } else { 15.75cm }
  let margin = (x: 1.5cm, top: 2.1cm, bottom: 1.6cm)
  let footer-author = if type(author) == array { author.join(", ") } else { author }

  set document(
    title: title,
    author: if type(author) == array { author } else if author == none { () } else { author },
    date: if type(date) == datetime { date } else { auto },
  )

  palette-state.update(p)

  set page(
    width: paper-width,
    height: paper-height,
    margin: margin,
    fill: p.bg,
    header-ascent: 30%,
    footer-descent: 30%,
    header: _header(p, margin),
    footer: _footer(p, short-title, footer-author, show-logo),
    background: _background(p, paper-width, 0.16cm),
  )

  set text(
    font: font,
    size: font-size,
    lang: lang,
    fill: p.text,
    hyphenate: false,
  )
  set par(justify: false, leading: 0.6em, spacing: 1em)
  set strong(delta: 300)
  set emph()
  show emph: set text(fill: p.text-muted)

  // Lists: the pixels of the logo as markers, one color per level.
  set list(
    indent: 0.2em,
    body-indent: 0.7em,
    spacing: 0.8em,
    marker: p.marks.map(color => pixel(color, size: 0.4em)),
  )
  set enum(indent: 0.2em, body-indent: 0.6em, spacing: 0.8em)
  show enum: set enum(numbering: n => text(fill: p.accent, weight: "bold", str(n) + "."))
  set terms(separator: h(1em), spacing: 0.8em)
  show terms.item: it => block(above: 0.8em, {
    text(fill: p.accent, weight: "bold", it.term)
    h(1em)
    it.description
  })

  show link: it => {
    if type(it.dest) == str {
      set text(fill: p.link)
      underline(stroke: 1pt + p.link.transparentize(50%), offset: 0.2em, it)
    } else { it }
  }
  show ref: set text(fill: p.link)

  set raw(theme: syntax-theme(p))
  show: listings
  show raw.where(block: true): set text(size: font-size * 0.75)

  set table(
    stroke: (x, y) => (
      bottom: if y == 0 { 1.5pt + p.accent } else { 0.5pt + p.rule },
    ),
    fill: (x, y) => if y == 0 { p.surface-alt },
    inset: (x: 0.6em, y: 0.5em),
  )
  show table.cell.where(y: 0): set text(weight: "bold", fill: p.heading)
  show table: set text(size: font-size * 0.85)

  show figure.caption: set text(size: sizes.small, fill: p.text-subtle)
  show math.equation: set text(font: ("New Computer Modern Math",))

  show quote.where(block: true): it => block(
    stroke: (left: 3pt + p.marks.at(2)),
    inset: (left: 0.9em, y: 0.3em),
    {
      text(fill: p.text-muted, style: "italic", it.body)
      if it.attribution != none {
        block(above: 0.6em, text(size: sizes.small, fill: p.text-subtle, [— #it.attribution]))
      }
    },
  )

  set heading(numbering: none)
  show heading: set text(weight: "extrabold", fill: p.heading)

  // A section: a slide of its own with the number, the name and the pixels.
  show heading.where(level: 1): set heading(numbering: "1", supplement: [Abschnitt])
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    align(horizon, block(width: 100%, {
      set align(left + top)
      if it.numbering != none {
        let number = counter(heading).get().first()
        block(below: 0.4em, text(size: sizes.large, {
          pixel(p.marks.at(0), size: 0.5em)
          h(0.5em)
          text(fill: p.accent, weight: "extrabold", _two(number))
          text(fill: p.text-subtle, weight: "regular", " / " + _two(counter(heading).final().first()))
        }))
      }
      block(
        below: 0pt,
        text(size: sizes.section, hyphenate: false, it.body),
      )
      _underline(p, length: 3.5em)
    }))
    pagebreak()
  }

  // A slide title: a new slide, the title and a short accent line.
  show heading.where(level: 2): it => {
    pagebreak(weak: true)
    block(below: 1em, {
      block(
        below: 0pt,
        text(size: sizes.frame-title, hyphenate: false, it.body),
      )
      _underline(p)
    })
  }
  show heading.where(level: 3): set text(size: sizes.large, fill: p.accent)
  show heading.where(level: 3): set block(above: 1.1em, below: 0.6em)

  if show-title-slide {
    let author-block = {
      let lines = ()
      if author != none {
        lines.push(if type(author) == array { author.join(", ") } else { author })
      }
      if email != none { lines.push(link("mailto:" + email, email)) }
      lines.join(linebreak())
    }
    _title-slide(
      p,
      title,
      subtitle,
      (
        (labels.author, author-block),
        (labels.date, date),
        (labels.event, event),
        (labels.institution, institution),
      )
        + extra-data,
      margin,
      paper-width,
    )
  }

  body
}
