## statusview.nim - Bottom status bar view
## Ports data/core/statusview.lua to Nim.

import std/times
import view, common, style

type
  StatusView* = ref object of View
    message*: string
    messageTimeout*: float
    tooltip*: string
    tooltipMode*: bool

const
  StatusSeparator* = "      "
  StatusSeparator2* = "   |   "

proc newStatusView*(): StatusView =
  let sv = StatusView(
    typeName: "StatusView",
    message: "",
    messageTimeout: 0.0,
    tooltip: "",
    tooltipMode: false
  )
  sv.size.y = 28.0
  return sv

proc showMessage*(self: StatusView, icon: string, text: string, timeout: float = 6.0) =
  self.message = icon & " | " & text
  self.messageTimeout = epochTime() + timeout

proc showTooltip*(self: StatusView, text: string) =
  self.tooltip = text
  self.tooltipMode = true

proc removeTooltip*(self: StatusView) =
  self.tooltipMode = false

method update*(self: StatusView): bool =
  self.size.y = defaultStyle.font.size + defaultStyle.padding.y * 2.0
  if epochTime() < self.messageTimeout:
    self.scroll.toY = self.size.y
  else:
    self.scroll.toY = 0.0
  return procCall update(View(self))
