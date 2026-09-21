## commandview.nim - Interactive command palette / input prompt view
## Ports data/core/commandview.lua to Nim.

import std/strutils
import doc, docview, view, common

type
  SuggestionItem* = object
    text*: string
    info*: string

  CommandSubmitProc* = proc(text: string, suggestion: SuggestionItem)
  CommandSuggestProc* = proc(text: string): seq[SuggestionItem]
  CommandCancelProc* = proc()

  CommandView* = ref object of DocView
    label*: string
    suggestions*: seq[SuggestionItem]
    suggestionIdx*: int
    suggestionsHeight*: float
    gutterWidth*: float
    submitProc*: CommandSubmitProc
    suggestProc*: CommandSuggestProc
    cancelProc*: CommandCancelProc

proc newCommandView*(): CommandView =
  let cv = CommandView(
    typeName: "CommandView",
    doc: newDoc(),
    fontName: "font",
    cursor: "ibeam",
    scrollable: false,
    label: "",
    suggestions: @[],
    suggestionIdx: 0,
    suggestionsHeight: 0.0,
    gutterWidth: 0.0
  )
  cv.size.y = 0.0
  return cv

proc getText*(self: CommandView): string =
  if self.doc != nil and self.doc.lines.len > 0:
    return self.doc.lines[0].strip(leading = false, trailing = true)
  return ""

proc setText*(self: CommandView, text: string) =
  if self.doc != nil:
    self.doc.reset()
    self.doc.insert(1, 1, text)

proc enter*(self: CommandView, label: string, submit: CommandSubmitProc = nil, suggest: CommandSuggestProc = nil, cancel: CommandCancelProc = nil) =
  self.label = label & ": "
  self.submitProc = submit
  self.suggestProc = suggest
  self.cancelProc = cancel
  self.setText("")
  if suggest != nil:
    self.suggestions = suggest("")
    if self.suggestions.len > 0:
      self.suggestionIdx = 1

proc exit*(self: CommandView) =
  if self.cancelProc != nil:
    self.cancelProc()
  self.label = ""
  self.suggestions = @[]
  self.suggestionIdx = 0
  self.submitProc = nil
  self.suggestProc = nil
  self.cancelProc = nil

proc moveSuggestionIdx*(self: CommandView, dir: int) =
  if self.suggestions.len > 0:
    let n = clamp(self.suggestionIdx + dir, 1, self.suggestions.len)
    self.suggestionIdx = n
    self.setText(self.suggestions[n - 1].text)

proc submit*(self: CommandView) =
  let currentText = self.getText()
  let sug = if self.suggestions.len > 0 and self.suggestionIdx > 0 and self.suggestionIdx <= self.suggestions.len:
              self.suggestions[self.suggestionIdx - 1]
            else:
              SuggestionItem(text: currentText, info: "")
  let submitFn = self.submitProc
  self.exit()
  if submitFn != nil:
    submitFn(currentText, sug)

proc drawSuggestionsBox*(self: CommandView) =
  discard

method draw*(self: CommandView) =
  procCall draw(DocView(self))
  self.drawSuggestionsBox()

method update*(self: CommandView): bool =
  if self.suggestProc != nil:
    let text = self.getText()
    self.suggestions = self.suggestProc(text)
  return procCall update(DocView(self))
