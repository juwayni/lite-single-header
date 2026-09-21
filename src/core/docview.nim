## docview.nim - Document view editor renderer, selections, line highlights, and cursor navigation
## Ports data/core/docview.lua to Nim.

import std/[math, tables]
import ./common, ./config, ./style, ./view, ./doc, ./tokenizer, ./renderer

type
  DocView* = ref object of View
    doc*: Doc
    fontName*: string
    lastLine*: int
    lastCol*: int

proc newDocView*(doc: Doc): DocView =
  let dv = DocView(
    typeName: "DocView",
    doc: doc,
    fontName: "codeFont",
    cursor: "ibeam",
    scrollable: true,
    lastLine: 1,
    lastCol: 1
  )
  return dv

method getName*(self: DocView): string =
  let post = if self.doc != nil and self.doc.isDirty(): "*" else: ""
  let name = if self.doc != nil: self.doc.getName() else: "unsaved"
  return name & post

method getLineHeight*(self: DocView, fontHeight: float = 14.0): float {.base.} =
  return floor(fontHeight * defaultConfig.lineHeight)

method getScrollableSize*(self: DocView): float =
  let lineCount = if self.doc != nil: self.doc.lines.len else: 1
  return self.getLineHeight() * float(lineCount - 1) + self.size.y

proc getGutterWidth*(self: DocView, fontCharWidth: float = 8.0): float =
  let lineCountStr = if self.doc != nil: $(self.doc.lines.len) else: "1"
  return float(lineCountStr.len) * fontCharWidth + defaultStyle.padding.x * 2.0

proc getLineScreenPosition*(self: DocView, lineIdx: int): Vec2 =
  let offset = self.getContentOffset()
  let lh = self.getLineHeight()
  let gw = self.getGutterWidth()
  let x = offset.x + gw
  let y = offset.y + float(lineIdx - 1) * lh + defaultStyle.padding.y
  return initVec2(x, y)

proc getVisibleLineRange*(self: DocView): (int, int) =
  let bounds = self.getContentBounds()
  let lh = max(1.0, self.getLineHeight())
  let minLine = max(1, int(floor(bounds.y / lh)))
  let maxLine = if self.doc != nil: min(self.doc.lines.len, int(floor((bounds.y + bounds.height) / lh)) + 1) else: 1
  return (minLine, maxLine)

proc resolveScreenPosition*(self: DocView, x, y: float): (int, int) =
  let pos1 = self.getLineScreenPosition(1)
  let line = int(floor((y - pos1.y) / self.getLineHeight())) + 1
  let clampedLine = clamp(line, 1, if self.doc != nil: self.doc.lines.len else: 1)
  let col = int(max(1.0, floor((x - pos1.x) / 8.0) + 1.0))
  return (clampedLine, col)

proc scrollToMakeVisible*(self: DocView, line, col: int) =
  let lh = self.getLineHeight()
  let minY = lh * float(line - 1)
  let maxY = lh * float(line + 2) - self.size.y
  self.scroll.toY = min(self.scroll.toY, minY)
  self.scroll.toY = max(self.scroll.toY, maxY)

proc drawLineGutter*(self: DocView, lineIdx: int, x, y: float) =
  let font = defaultStyle.font
  let color = defaultStyle.lineNumber
  let lineNumStr = $lineIdx
  discard renderer.drawText(font, lineNumStr, x + defaultStyle.padding.x, y, color)

proc drawLineText*(self: DocView, lineIdx: int, x, y: float) =
  if self.doc != nil:
    let font = defaultStyle.codeFont
    let hl = self.doc.getHighlightedLine(lineIdx)
    var curX = x
    for tok in hl.tokens:
      let tokColor = defaultStyle.syntax.getOrDefault(tok.tokenType, defaultStyle.text)
      curX = renderer.drawText(font, tok.text, curX, y, tokColor)

proc drawLineBody*(self: DocView, lineIdx: int, x, y: float) =
  if self.doc != nil:
    let lh = self.getLineHeight()
    for sel in self.doc.selections:
      if sel.line1 <= lineIdx and sel.line2 >= lineIdx:
        if sel.line1 == sel.line2 and sel.col1 == sel.col2:
          if sel.line1 == lineIdx:
            let caretX = x + float(sel.col1 - 1) * 8.0
            renderer.drawRect(initRect(caretX, y, defaultStyle.caretWidth, lh), defaultStyle.caret)
        else:
          let selX1 = if sel.line1 == lineIdx: x + float(sel.col1 - 1) * 8.0 else: x
          let lineLen = if lineIdx <= self.doc.lines.len: self.doc.lines[lineIdx - 1].len else: 1
          let selX2 = if sel.line2 == lineIdx: x + float(sel.col2 - 1) * 8.0 else: x + float(lineLen) * 8.0
          renderer.drawRect(initRect(selX1, y, max(1.0, selX2 - selX1), lh), defaultStyle.selection)

  self.drawLineText(lineIdx, x, y)

method draw*(self: DocView) =
  self.drawBackground(defaultStyle.background)
  let (minL, maxL) = self.getVisibleLineRange()
  let lh = self.getLineHeight()
  let pos = self.getLineScreenPosition(minL)
  var curY = pos.y
  for l in minL .. maxL:
    self.drawLineGutter(l, self.position.x, curY)
    self.drawLineBody(l, pos.x, curY)
    curY += lh
  self.drawScrollbar()

method update*(self: DocView): bool =
  if self.doc != nil and self.doc.selections.len > 0:
    let sel = self.doc.selections[0]
    if (sel.line1 != self.lastLine or sel.col1 != self.lastCol) and self.size.x > 0:
      self.scrollToMakeVisible(sel.line1, sel.col1)
      self.lastLine = sel.line1
      self.lastCol = sel.col1
  return procCall update(View(self))
