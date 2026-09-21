## style.nim - Visual UI styles, dimensions, colors and font references
## Ports data/core/style.lua to Nim with structured type definitions.

import tables
import common

type
  FontHandle* = ref object
    path*: string
    size*: float

  Style* = object
    padding*: Vec2
    dividerSize*: float
    scrollbarSize*: float
    caretWidth*: float
    tabWidth*: float

    font*: FontHandle
    bigFont*: FontHandle
    iconFont*: FontHandle
    codeFont*: FontHandle

    background*: Color
    background2*: Color
    background3*: Color
    text*: Color
    caret*: Color
    accent*: Color
    dim*: Color
    divider*: Color
    selection*: Color
    lineNumber*: Color
    lineNumber2*: Color
    lineHighlight*: Color
    scrollbar*: Color
    scrollbar2*: Color

    syntax*: Table[string, Color]

proc loadFontStub*(path: string, size: float): FontHandle =
  FontHandle(path: path, size: size)

proc initStyle*(scale: float = 1.0, dataDir: string = "."): Style =
  var s = Style(
    padding: initVec2(round(14.0 * scale), round(7.0 * scale)),
    dividerSize: round(1.0 * scale),
    scrollbarSize: round(4.0 * scale),
    caretWidth: round(2.0 * scale),
    tabWidth: round(170.0 * scale),

    font: loadFontStub(dataDir & "/data/fonts/font.ttf", 14.0 * scale),
    bigFont: loadFontStub(dataDir & "/data/fonts/font.ttf", 34.0 * scale),
    iconFont: loadFontStub(dataDir & "/data/fonts/icons.ttf", 14.0 * scale),
    codeFont: loadFontStub(dataDir & "/data/fonts/monospace.ttf", 13.5 * scale),

    background: color("#2e2e32"),
    background2: color("#252529"),
    background3: color("#252529"),
    text: color("#97979c"),
    caret: color("#93DDFA"),
    accent: color("#e1e1e6"),
    dim: color("#525257"),
    divider: color("#202024"),
    selection: color("#48484f"),
    lineNumber: color("#525259"),
    lineNumber2: color("#83838f"),
    lineHighlight: color("#343438"),
    scrollbar: color("#414146"),
    scrollbar2: color("#4b4b52"),

    syntax: initTable[string, Color]()
  )

  s.syntax["normal"] = color("#e1e1e6")
  s.syntax["symbol"] = color("#e1e1e6")
  s.syntax["comment"] = color("#676b6f")
  s.syntax["keyword"] = color("#E58AC9")
  s.syntax["keyword2"] = color("#F77483")
  s.syntax["number"] = color("#FFA94D")
  s.syntax["literal"] = color("#FFA94D")
  s.syntax["string"] = color("#f7c95c")
  s.syntax["operator"] = color("#93DDFA")
  s.syntax["function"] = color("#93DDFA")

  return s

var defaultStyle* = initStyle(1.0, ".")
