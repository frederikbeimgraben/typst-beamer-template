// A syntax theme from the palette, so the code fits the light and the dark
// slides. Typst reads TextMate themes; this one is written on the fly.

#import "../config/colors.typ": brand

#let _setting(scope, color, style: none) = {
  let font-style = if style == none { "" } else {
    "<key>fontStyle</key><string>" + style + "</string>"
  }
  (
    "<dict><key>scope</key><string>" + scope + "</string>"
      + "<key>settings</key><dict><key>foreground</key><string>"
      + color.to-hex() + "</string>" + font-style + "</dict></dict>"
  )
}

#let syntax-theme(p) = {
  let dark = p.appearance == "dark"
  let keyword = if dark { brand.magenta } else { brand.magenta-dark }
  let string = if dark { brand.lime } else { brand.lime-dark }
  let number = if dark { brand.cyan } else { brand.cyan-dark }
  let function = if dark { p.primary.at("300") } else { p.primary.at("600") }
  let comment = p.text-subtle
  let settings = (
    "<dict><key>settings</key><dict><key>foreground</key><string>"
      + p.text.to-hex() + "</string><key>background</key><string>"
      + p.surface.to-hex() + "</string></dict></dict>",
    _setting("comment, punctuation.definition.comment", comment, style: "italic"),
    _setting("string, string.quoted, markup.raw", string),
    _setting("constant.numeric, constant.language, constant.character", number),
    _setting("keyword, storage, storage.type, keyword.operator.word", keyword),
    _setting("entity.name.function, support.function, meta.function-call", function),
    _setting("entity.name.type, entity.name.class, support.type, support.class", number),
    _setting("variable.parameter, variable.other.member", p.text-muted),
    _setting("markup.heading, entity.name.section", keyword, style: "bold"),
  )
  bytes(
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?><plist version=\"1.0\"><dict>"
      + "<key>name</key><string>beimgraben</string><key>settings</key><array>"
      + settings.join() + "</array></dict></plist>",
  )
}
