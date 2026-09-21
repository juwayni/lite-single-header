## view.nim - Base View component with layout, scrolling, and input handlers
## Ports data/core/view.lua to Nim with structured OOP methods.

import std/math
import objects, common

type
  ScrollState* = object
    x*, y*: float
    toX*, toY*: float

  View* = ref object of Object
    position*: Vec2
    size*: Vec2
    scroll*: ScrollState
    cursor*: string
    scrollable*: bool
    draggingScrollbar*: bool
    hoveredScrollbar*: bool

proc newView*(typeName: string = "View"): View =
  let v = View(
    typeName: typeName,
    position: initVec2(0.0, 0.0),
    size: initVec2(0.0, 0.0),
    scroll: ScrollState(x: 0.0, y: 0.0, toX: 0.0, toY: 0.0),
    cursor: "arrow",
    scrollable: false,
    draggingScrollbar: false,
    hoveredScrollbar: false
  )
  return v

proc moveTowards*(val: var float, dest: float, rate: float = 0.5): bool =
  if abs(val - dest) < 0.5:
    let changed = val != dest
    val = dest
    return changed
  else:
    val = lerp(val, dest, rate)
    return true

method getName*(self: View): string {.base.} =
  return "---"

method getScrollableSize*(self: View): float {.base.} =
  return Inf

method getScrollbarRect*(self: View, scrollbarSize: float = 4.0): Rect {.base.} =
  let sz = self.getScrollableSize()
  if sz <= self.size.y or sz == Inf or self.size.y <= 0:
    return initRect(0, 0, 0, 0)
  let h = max(20.0, self.size.y * self.size.y / sz)
  let rx = self.position.x + self.size.x - scrollbarSize
  let ry = self.position.y + self.scroll.y * (self.size.y - h) / max(1.0, sz - self.size.y)
  return initRect(rx, ry, scrollbarSize, h)

method scrollbarOverlapsPoint*(self: View, x, y: float, scrollbarSize: float = 4.0): bool {.base.} =
  let r = self.getScrollbarRect(scrollbarSize)
  return x >= r.x - r.width * 3 and x < r.x + r.width and y >= r.y and y < r.y + r.height

method onMousePressed*(self: View, button: string, x, y: float, clicks: int): bool {.base.} =
  if self.scrollbarOverlapsPoint(x, y):
    self.draggingScrollbar = true
    return true
  return false

method onMouseReleased*(self: View, button: string, x, y: float) {.base.} =
  self.draggingScrollbar = false

method onMouseMoved*(self: View, x, y, dx, dy: float) {.base.} =
  if self.draggingScrollbar:
    let sz = self.getScrollableSize()
    if self.size.y > 0:
      let delta = (sz / self.size.y) * dy
      self.scroll.toY += delta
  self.hoveredScrollbar = self.scrollbarOverlapsPoint(x, y)

method onTextInput*(self: View, text: string) {.base.} =
  discard

method onMouseWheel*(self: View, y: float, isAlt: bool = false, mouseWheelScroll: float = 50.0) {.base.} =
  if self.scrollable:
    if isAlt:
      self.scroll.toX += y * -mouseWheelScroll
    else:
      self.scroll.toY += y * -mouseWheelScroll

method getContentBounds*(self: View): Rect {.base.} =
  let x = self.scroll.x
  let y = self.scroll.y
  return initRect(x, y, self.size.x, self.size.y)

method getContentOffset*(self: View): Vec2 {.base.} =
  let x = round(self.position.x - self.scroll.x)
  let y = round(self.position.y - self.scroll.y)
  return initVec2(x, y)

method clampScrollPosition*(self: View) {.base.} =
  let sz = self.getScrollableSize()
  if sz != Inf:
    let maxScroll = max(0.0, sz - self.size.y)
    self.scroll.toY = clamp(self.scroll.toY, 0.0, maxScroll)

method update*(self: View): bool {.base.} =
  self.clampScrollPosition()
  let c1 = moveTowards(self.scroll.x, self.scroll.toX, 0.3)
  let c2 = moveTowards(self.scroll.y, self.scroll.toY, 0.3)
  return c1 or c2

method draw*(self: View) {.base.} =
  discard
