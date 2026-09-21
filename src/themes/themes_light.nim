## themes_light.nim - Light and seasonal theme palette definitions
## Ports fall.lua, github.lua, solarized_light.lua, solarobj.lua, summer.lua, winter.lua, zenburn.lua.

import tables
import ../core/common, ../core/style

proc getSolarizedLightTheme*(): Style =
  var st = initStyle()
  st.background = color("#fdf6e3")
  st.background2 = color("#eee8d5")
  st.text = color("#657b83")
  st.caret = color("#586e75")
  st.accent = color("#268bd2")
  st.selection = color("#eee8d5")

  st.syntax["comment"] = color("#93a1a1")
  st.syntax["keyword"] = color("#859900")
  st.syntax["string"] = color("#2aa198")
  st.syntax["number"] = color("#d33682")
  return st

proc getGitHubTheme*(): Style =
  var st = initStyle()
  st.background = color("#ffffff")
  st.background2 = color("#f6f8fa")
  st.text = color("#24292e")
  st.accent = color("#0366d6")
  st.selection = color("#c8c8fa")

  st.syntax["comment"] = color("#6a737d")
  st.syntax["keyword"] = color("#d73a49")
  st.syntax["string"] = color("#032f62")
  return st

proc getWinterTheme*(): Style =
  var st = initStyle()
  st.background = color("#f0f4f8")
  st.background2 = color("#e1e8ed")
  st.text = color("#1c2d37")
  st.accent = color("#2b6cb0")
  st.selection = color("#cbd5e0")

  st.syntax["comment"] = color("#718096")
  st.syntax["keyword"] = color("#dd6b20")
  st.syntax["string"] = color("#38a169")
  return st

proc getSummerTheme*(): Style =
  var st = initStyle()
  st.background = color("#fffbe6")
  st.background2 = color("#fff1b8")
  st.text = color("#613400")
  st.accent = color("#d48806")
  st.selection = color("#ffe58f")

  st.syntax["comment"] = color("#8c8c8c")
  st.syntax["keyword"] = color("#cf1322")
  st.syntax["string"] = color("#389e0d")
  return st
