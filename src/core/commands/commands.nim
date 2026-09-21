## commands.nim - Core command definitions
## Ports data/core/commands/ (command, core, doc, findreplace, root) to Nim.

import ../command, ../keymap, ../doc, ../docview, ../commandview, ../node, ../rootview, ../common

proc registerCoreCommands*(reg: CommandRegistry, km: Keymap, rv: RootView, cv: CommandView) =
  reg.addCommand("core:quit", proc() =
    discard
  )

  reg.addCommand("core:new-doc", proc() =
    let d = newDoc()
    discard rv.openDoc(d)
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
