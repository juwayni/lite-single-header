## themes_dark.nim - Dark theme palette definitions
## Ports abyss.lua, cold_lime.lua, dracula.lua, duorand.lua, duotone.lua, fwk.lua, gruvbox_dark.lua, liqube.lua, moe.lua, monodark.lua, monokai.lua, nord.lua, onedark.lua, only_dark.lua, vscode-dark.lua.

import tables
import ../core/common, ../core/style

proc getMonokaiTheme*(): Style =
  var st = initStyle()
  st.background = color("#272822")
  st.background2 = color("#1e1f1c")
  st.text = color("#f8f8f2")
  st.caret = color("#f8f8f0")
  st.accent = color("#f92672")
  st.selection = color("#49483e")

  st.syntax["normal"] = color("#f8f8f2")
  st.syntax["symbol"] = color("#f8f8f2")
  st.syntax["comment"] = color("#75715e")
  st.syntax["keyword"] = color("#f92672")
  st.syntax["keyword2"] = color("#66d9ef")
  st.syntax["number"] = color("#ae81ff")
  st.syntax["literal"] = color("#ae81ff")
  st.syntax["string"] = color("#e6db74")
  st.syntax["operator"] = color("#f92672")
  st.syntax["function"] = color("#a6e22e")
  return st

proc getDraculaTheme*(): Style =
  var st = initStyle()
  st.background = color("#282a36")
  st.background2 = color("#21222c")
  st.text = color("#f8f8f2")
  st.caret = color("#f8f8f2")
  st.accent = color("#ff79c6")
  st.selection = color("#44475a")

  st.syntax["normal"] = color("#f8f8f2")
  st.syntax["comment"] = color("#6272a4")
  st.syntax["keyword"] = color("#ff79c6")
  st.syntax["keyword2"] = color("#8be9fd")
  st.syntax["string"] = color("#f1fa8c")
  st.syntax["function"] = color("#50fa7b")
  return st

proc getNordTheme*(): Style =
  var st = initStyle()
  st.background = color("#2e3440")
  st.background2 = color("#242933")
  st.text = color("#d8dee9")
  st.accent = color("#88c0d0")
  st.selection = color("#434c5e")

  st.syntax["comment"] = color("#616e88")
  st.syntax["keyword"] = color("#81a1c1")
  st.syntax["string"] = color("#a3be8c")
  return st

proc getOneDarkTheme*(): Style =
  var st = initStyle()
  st.background = color("#282c34")
  st.background2 = color("#21252b")
  st.text = color("#abb2bf")
  st.accent = color("#61afef")
  st.selection = color("#3e4451")

  st.syntax["comment"] = color("#5c6370")
  st.syntax["keyword"] = color("#c678dd")
  st.syntax["string"] = color("#98c379")
  return st

proc getVsCodeDarkTheme*(): Style =
  var st = initStyle()
  st.background = color("#1e1e1e")
  st.background2 = color("#252526")
  st.text = color("#d4d4d4")
  st.accent = color("#569cd6")
  st.selection = color("#264f78")

  st.syntax["comment"] = color("#6a9955")
  st.syntax["keyword"] = color("#569cd6")
  st.syntax["string"] = color("#ce9178")
  return st

proc getGruvboxDarkTheme*(): Style =
  var st = initStyle()
  st.background = color("#282828")
  st.background2 = color("#1d2021")
  st.text = color("#ebdbb2")
  st.accent = color("#fe8019")
  st.selection = color("#504945")

  st.syntax["comment"] = color("#928374")
  st.syntax["keyword"] = color("#fb4934")
  st.syntax["string"] = color("#b8bb26")
  return st
