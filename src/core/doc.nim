## doc.nim - Document buffer & multi-cursor
import std/[strutils, os, math, times]
import objects, common, syntax, tokenizer

type
  Selection* = object
    line1*, col1*: int
    line2*, col2*: int

  UndoActionType* = enum uaInsert, uaRemove, uaSelection

  UndoRecord* = object
    actionType*: UndoActionType
    time*: float
    line1*, col1*, line2*, col2*: int
    text*: string
    selections*: seq[Selection]

  HighlightedLine* = object
    initState*, state*: int
    text*: string
    tokens*: seq[Token]

  Doc* = ref object of Object
    filename*, absFilename*: string
    lines*: seq[string]
    selections*: seq[Selection]
    undoStack*, redoStack*: seq[UndoRecord]
    cleanChangeId*: int
    crlf*: bool
    syntax*: SyntaxDef
    highlightedLines*: seq[HighlightedLine]

proc sortPositions*(line1, col1, line2, col2: int): (int, int, int, int) =
  if line1 > line2 or (line1 == line2 and col1 > col2):
    return (line2, col2, line1, col1)
  return (line1, col1, line2, col2)

proc newDoc*(filename: string = ""): Doc

proc reset*(doc: Doc) =
  doc.lines = @["\n"]
  doc.selections = @[Selection(line1: 1, col1: 1, line2: 1, col2: 1)]
  doc.undoStack = @[]
  doc.redoStack = @[]
  doc.cleanChangeId = 0
  doc.crlf = false
  doc.highlightedLines = @[]
  doc.syntax = newSyntaxDef("Plain Text")

proc sanitizePosition*(doc: Doc, line, col: int): (int, int) =
  let l = clamp(line, 1, max(1, doc.lines.len))
  let c = clamp(col, 1, max(1, doc.lines[l - 1].len))
  return (l, c)

proc resetSyntax*(doc: Doc) =
  let header = if doc.lines.len > 0 and doc.lines[0].len > 0: doc.lines[0][0 ..< min(128, doc.lines[0].len)] else: ""
  doc.syntax = globalSyntaxRegistry.getSyntax(doc.filename, header)
  doc.highlightedLines = @[]

proc newDoc*(filename: string = ""): Doc =
  let doc = Doc(typeName: "Doc")
  doc.reset()
  if filename.len > 0:
    doc.filename = filename; doc.absFilename = filename
    if fileExists(filename):
      let content = readFile(filename)
      let split = content.splitLines()
      if split.len > 0:
        doc.lines = @[]
        for s in split: doc.lines.add(s & "\n")
  doc.resetSyntax()
  return doc

proc getName*(doc: Doc): string =
  if doc.filename.len > 0: doc.filename else: "unsaved"

proc getChangeId*(doc: Doc): int = doc.undoStack.len
proc isDirty*(doc: Doc): bool = doc.cleanChangeId != doc.getChangeId()
proc clean*(doc: Doc) = doc.cleanChangeId = doc.getChangeId()

proc setSelection*(doc: Doc, line1, col1: int, line2: int = 0, col2: int = 0) =
  let l2 = if line2 == 0: line1 else: line2
  let c2 = if col2 == 0: col1 else: col2
  let (sl1, sc1, sl2, sc2) = sortPositions(line1, col1, l2, c2)
  doc.selections = @[Selection(line1: sl1, col1: sc1, line2: sl2, col2: sc2)]

proc getHighlightedLine*(doc: Doc, lineIdx: int): HighlightedLine =
  let (l, _) = doc.sanitizePosition(lineIdx, 1)
  if l <= doc.highlightedLines.len and doc.highlightedLines[l - 1].text == doc.lines[l - 1]:
    return doc.highlightedLines[l - 1]
  let lineText = doc.lines[l - 1]
  let prevState = if l > 1 and l - 1 <= doc.highlightedLines.len: doc.highlightedLines[l - 2].state else: 0
  let (toks, endState) = doc.syntax.tokenize(lineText, prevState)
  let hl = HighlightedLine(initState: prevState, state: endState, text: lineText, tokens: toks)
  while doc.highlightedLines.len < l: doc.highlightedLines.add(HighlightedLine())
  doc.highlightedLines[l - 1] = hl
  return hl

proc getText*(doc: Doc, line1, col1, line2, col2: int): string =
  let (l1, c1) = doc.sanitizePosition(line1, col1)
  let (l2, c2) = doc.sanitizePosition(line2, col2)
  let (sl1, sc1, sl2, sc2) = sortPositions(l1, c1, l2, c2)
  if sl1 == sl2:
    let lineStr = doc.lines[sl1 - 1]
    if sc1 <= lineStr.len and sc2 - 1 >= sc1:
      return lineStr[sc1 - 1 ..< min(sc2 - 1, lineStr.len)]
    return ""
  var parts: seq[string] = @[]
  parts.add(doc.lines[sl1 - 1][sc1 - 1 .. ^1])
  for i in sl1 + 1 .. sl2 - 1: parts.add(doc.lines[i - 1])
  let lastLineStr = doc.lines[sl2 - 1]
  if sc2 - 1 >= 1: parts.add(lastLineStr[0 ..< min(sc2 - 1, lastLineStr.len)])
  return parts.join("")

proc rawInsert*(doc: Doc, line, col: int, text: string) =
  let (l, c) = doc.sanitizePosition(line, col)
  let lineContent = doc.lines[l - 1]
  let before = if c > 1: lineContent[0 ..< c - 1] else: ""
  let after = if c <= lineContent.len: lineContent[c - 1 .. ^1] else: ""
  let fullInserted = before & text & after
  var newLines: seq[string] = @[]
  var cur = ""
  for ch in fullInserted:
    cur.add(ch)
    if ch == '\n':
      newLines.add(cur)
      cur = ""
  if cur.len > 0 or newLines.len == 0: newLines.add(cur)
  splice(doc.lines, l - 1, 1, newLines)
  doc.highlightedLines = @[]

proc rawRemove*(doc: Doc, line1, col1, line2, col2: int) =
  let (l1, c1) = doc.sanitizePosition(line1, col1)
  let (l2, c2) = doc.sanitizePosition(line2, col2)
  let (sl1, sc1, sl2, sc2) = sortPositions(l1, c1, l2, c2)
  let before = if sc1 > 1: doc.lines[sl1 - 1][0 ..< sc1 - 1] else: ""
  let after = if sc2 <= doc.lines[sl2 - 1].len: doc.lines[sl2 - 1][sc2 - 1 .. ^1] else: ""
  let removeCount = sl2 - sl1 + 1
  splice(doc.lines, sl1 - 1, removeCount, [before & after])
  doc.highlightedLines = @[]

proc calcEndPosition*(line, col: int, text: string): (int, int) =
  var l = line; var c = col
  for ch in text:
    if ch == '\n': inc l; c = 1
    else: inc c
  return (l, c)

proc insert*(doc: Doc, line, col: int, text: string) =
  let (l, c) = doc.sanitizePosition(line, col)
  let (endL, endC) = calcEndPosition(l, c, text)
  doc.undoStack.add(UndoRecord(actionType: uaInsert, time: cpuTime(), line1: l, col1: c, line2: endL, col2: endC, text: text, selections: doc.selections))
  doc.rawInsert(l, c, text)

proc remove*(doc: Doc, line1, col1, line2, col2: int) =
  let (l1, c1, l2, c2) = sortPositions(line1, col1, line2, col2)
  let text = doc.getText(l1, c1, l2, c2)
  doc.undoStack.add(UndoRecord(actionType: uaRemove, time: cpuTime(), line1: l1, col1: c1, line2: l2, col2: c2, text: text, selections: doc.selections))
  doc.rawRemove(l1, c1, l2, c2)

proc textInput*(doc: Doc, text: string) =
  if doc.selections.len == 0: doc.setSelection(1, 1)
  for i in countdown(doc.selections.len - 1, 0):
    let sel = doc.selections[i]
    if sel.line1 != sel.line2 or sel.col1 != sel.col2:
      doc.remove(sel.line1, sel.col1, sel.line2, sel.col2)
    doc.insert(sel.line1, sel.col1, text)
    let (endL, endC) = calcEndPosition(sel.line1, sel.col1, text)
    doc.selections[i] = Selection(line1: endL, col1: endC, line2: endL, col2: endC)

proc deleteToCursor*(doc: Doc, dirCol: int = -1) =
  for i in countdown(doc.selections.len - 1, 0):
    let sel = doc.selections[i]
    if sel.line1 != sel.line2 or sel.col1 != sel.col2:
      doc.remove(sel.line1, sel.col1, sel.line2, sel.col2)
      doc.selections[i] = Selection(line1: sel.line1, col1: sel.col1, line2: sel.line1, col2: sel.col1)
    else:
      let targetCol = max(1, sel.col1 + dirCol)
      doc.remove(sel.line1, min(sel.col1, targetCol), sel.line1, max(sel.col1, targetCol))
      let newC = min(sel.col1, targetCol)
      doc.selections[i] = Selection(line1: sel.line1, col1: newC, line2: sel.line1, col2: newC)

proc getSelectedText*(doc: Doc): string =
  var parts: seq[string] = @[]
  for sel in doc.selections:
    if sel.line1 != sel.line2 or sel.col1 != sel.col2:
      parts.add(doc.getText(sel.line1, sel.col1, sel.line2, sel.col2))
  return parts.join("\n")

proc copySelectionToClipboard*(doc: Doc) =
  let txt = doc.getSelectedText()
  if txt.len > 0:
    setClipboardText(txt)

proc cutSelectionToClipboard*(doc: Doc) =
  doc.copySelectionToClipboard()
  doc.deleteToCursor(0)

proc pasteFromClipboard*(doc: Doc) =
  let txt = getClipboardText()
  if txt.len > 0:
    doc.textInput(txt)

proc undo*(doc: Doc) =
  if doc.undoStack.len > 0:
    let rec = doc.undoStack.pop()
    doc.redoStack.add(rec)
    if rec.actionType == uaInsert: doc.rawRemove(rec.line1, rec.col1, rec.line2, rec.col2)
    elif rec.actionType == uaRemove: doc.rawInsert(rec.line1, rec.col1, rec.text)
    doc.selections = rec.selections

proc redo*(doc: Doc) =
  if doc.redoStack.len > 0:
    let rec = doc.redoStack.pop()
    doc.undoStack.add(rec)
    if rec.actionType == uaInsert: doc.rawInsert(rec.line1, rec.col1, rec.text)
    elif rec.actionType == uaRemove: doc.rawRemove(rec.line1, rec.col1, rec.line2, rec.col2)

proc searchFind*(doc: Doc, line, col: int, text: string, noCase: bool = false): (int, int, int, int) =
  let (startL, startC) = doc.sanitizePosition(line, col)
  var searchNeedle = if noCase: text.toLowerAscii() else: text
  for l in startL .. doc.lines.len:
    let lineStr = doc.lines[l - 1]
    let haystack = if noCase: lineStr.toLowerAscii() else: lineStr
    let searchStart = if l == startL: startC - 1 else: 0
    if searchStart < haystack.len:
      let idx = haystack.find(searchNeedle, searchStart)
      if idx >= 0: return (l, idx + 1, l, idx + 1 + searchNeedle.len)
  return (-1, -1, -1, -1)
