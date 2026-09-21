## commands.nim - Core command definitions
## Ports data/core/commands/ (command, core, doc, findreplace, root) to Nim.

import std/strutils
import ../command, ../keymap, ../doc, ../docview, ../commandview, ../node, ../rootview, ../common, ../config

proc registerCoreCommands*(reg: CommandRegistry, km: Keymap, rv: RootView, cv: CommandView) =
  reg.addCommand("core:quit", proc() =
    quit(0)
  )

  reg.addCommand("core:force-quit", proc() =
    quit(0)
  )

  reg.addCommand("core:new-doc", proc() =
    let d = newDoc()
    discard rv.openDoc(d)
  )

  reg.addCommand("core:open-file", proc() =
    cv.enter("Open File", proc(text: string, sug: SuggestionItem) =
      let path = if sug.text.len > 0: sug.text else: text
      if path.len > 0:
        discard rv.openDoc(newDoc(path))
    )
  )

  reg.addCommand("core:find-file", proc() =
    cv.enter("Find File", proc(text: string, sug: SuggestionItem) =
      let path = if sug.text.len > 0: sug.text else: text
      if path.len > 0:
        discard rv.openDoc(newDoc(path))
    )
  )

  reg.addCommand("core:find-command", proc() =
    cv.enter("Do Command",
      proc(text: string, sug: SuggestionItem) =
        discard reg.perform(sug.text),
      proc(text: string): seq[SuggestionItem] =
        let valid = reg.getAllValid()
        let matched = fuzzyMatchItems(valid, text)
        var res: seq[SuggestionItem] = @[]
        for m in matched:
          res.add(SuggestionItem(text: m, info: km.getBinding(m)))
        return res
    )
  )

  reg.addCommand("doc:save", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.clean()
  )

  reg.addCommand("doc:save-as", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        cv.enter("Save As", proc(filename: string, sug: SuggestionItem) =
          let target = if sug.text.len > 0: sug.text else: filename
          if target.len > 0:
            dv.doc.filename = target
            dv.doc.clean()
        )
  )

  reg.addCommand("doc:undo", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.undo()
  )

  reg.addCommand("doc:redo", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.redo()
  )

  reg.addCommand("doc:cut", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.deleteToCursor(0)
  )

  reg.addCommand("doc:copy", proc() =
    discard
  )

  reg.addCommand("doc:paste", proc() =
    discard
  )

  reg.addCommand("doc:newline", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.textInput("\n")
  )

  reg.addCommand("doc:backspace", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.deleteToCursor(-1)
  )

  reg.addCommand("doc:delete", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.deleteToCursor(1)
  )

  reg.addCommand("doc:indent", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        let indentStr = if defaultConfig.tabType == ttHard: "\t" else: "  "
        dv.doc.textInput(indentStr)
  )

  reg.addCommand("doc:unindent", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        dv.doc.deleteToCursor(-defaultConfig.indentSize)
  )

  reg.addCommand("doc:select-all", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil:
        let lineCount = dv.doc.lines.len
        let lastLineLen = if lineCount > 0: dv.doc.lines[^1].len else: 1
        dv.doc.setSelection(1, 1, lineCount, lastLineLen)
  )

  reg.addCommand("doc:select-none", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
      let dv = DocView(rv.rootNode.activeView)
      if dv.doc != nil and dv.doc.selections.len > 0:
        let sel = dv.doc.selections[0]
        dv.doc.setSelection(sel.line1, sel.col1)
  )

  reg.addCommand("doc:go-to-line", proc() =
    cv.enter("Go To Line", proc(text: string, sug: SuggestionItem) =
      if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
        let dv = DocView(rv.rootNode.activeView)
        try:
          let lineNum = parseInt(text.strip())
          if dv.doc != nil and lineNum > 0:
            dv.doc.setSelection(lineNum, 1)
            dv.scrollToMakeVisible(lineNum, 1)
        except ValueError:
          discard
    )
  )

  reg.addCommand("find-replace:find", proc() =
    cv.enter("Find Text", proc(text: string, sug: SuggestionItem) =
      if rv.rootNode != nil and rv.rootNode.activeView != nil and rv.rootNode.activeView of DocView:
        let dv = DocView(rv.rootNode.activeView)
        if dv.doc != nil and text.len > 0:
          let (l1, c1, l2, c2) = dv.doc.searchFind(1, 1, text)
          if l1 > 0:
            dv.doc.selections = @[Selection(line1: l1, col1: c1, line2: l2, col2: c2)]
    )
  )

  reg.addCommand("find-replace:replace", proc() =
    cv.enter("Replace Text With", proc(text: string, sug: SuggestionItem) =
      discard
    )
  )

  reg.addCommand("find-replace:repeat-find", proc() =
    discard
  )

  reg.addCommand("root:split-right", proc() =
    if rv.rootNode != nil:
      discard rv.rootNode.split("right")
      rv.rootNode.updateLayout()
  )

  reg.addCommand("root:split-down", proc() =
    if rv.rootNode != nil:
      discard rv.rootNode.split("down")
      rv.rootNode.updateLayout()
  )

  reg.addCommand("root:close", proc() =
    if rv.rootNode != nil and rv.rootNode.activeView != nil:
      discard
  )
