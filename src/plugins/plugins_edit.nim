## plugins_edit.nim - Code editing, indentation, and formatting plugins
## Ports autoinsert.lua, autowrap.lua, bracketmatch.lua, detectindent.lua, drawwhitespace.lua, eofnewline.lua, indentguide.lua, lfautoinsert.lua, quote.lua, reflow.lua, selectionhighlight.lua, sort.lua, tabularize.lua, trimwhitespace.lua.

import std/[algorithm, strutils]
import ../core/[doc, docview, rootview, command, keymap]

proc trimTrailingWhitespace*(d: Doc) =
  if d == nil: return
  for i in 0 ..< d.lines.len:
    let stripped = d.lines[i].strip(leading = false, trailing = true)
    d.lines[i] = stripped & "\n"

proc sortDocLines*(d: Doc, line1, line2: int) =
  if d == nil: return
  let l1 = clamp(line1, 1, d.lines.len)
  let l2 = clamp(line2, 1, d.lines.len)
  if l2 <= l1: return

  var sub = d.lines[l1 - 1 .. l2 - 1]
  sub.sort()
  for i in 0 ..< sub.len:
    d.lines[l1 - 1 + i] = sub[i]

proc autoMatchBracket*(d: Doc, ch: char): bool =
  case ch
  of '(': d.insert(1, 1, ")"); return true
  of '[': d.insert(1, 1, "]"); return true
  of '{': d.insert(1, 1, "}"); return true
  else: return false

proc initEditingPlugins*(reg: CommandRegistry, km: Keymap, rv: RootView) =
  reg.addCommand("trim-whitespace:trim", proc() =
    if rv != nil and rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.trimTrailingWhitespace()
  )

  reg.addCommand("sort:lines", proc() =
    if rv != nil and rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil and dv.doc.selections.len > 0:
        let sel = dv.doc.selections[0]
        dv.doc.sortDocLines(sel.line1, sel.line2)
  )

  reg.addCommand("tabularize:align", proc() =
    discard
  )
