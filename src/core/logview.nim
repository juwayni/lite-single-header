## logview.nim - Log item viewer
## Ports data/core/logview.lua to Nim.

import std/times
import view

type
  LogItem* = object
    text*: string
    time*: float
    at*: string
    info*: string

  LogView* = ref object of View
    items*: seq[LogItem]
    yOffset*: float

proc newLogView*(): LogView =
  let lv = LogView(
    typeName: "LogView",
    items: @[],
    scrollable: true,
    yOffset: 0.0
  )
  return lv

method getName*(self: LogView): string =
  return "Log"

proc addLogItem*(self: LogView, text: string, at: string = "", info: string = "") =
  self.items.add(LogItem(text: text, time: epochTime(), at: at, info: info))
  self.scroll.toY = 0.0
  self.yOffset = -20.0

method update*(self: LogView): bool =
  let c = moveTowards(self.yOffset, 0.0, 0.5)
  return c or procCall update(View(self))
