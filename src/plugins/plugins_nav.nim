## plugins_nav.nim - Core navigation & workspace plugins
## Ports autocomplete.lua, autoreload.lua, closeconfirmx.lua, fsutils.lua, minimap.lua, openfilelocation.lua, projectsearch.lua, treeview.lua, workspace.lua.

import std/[os, strutils]
import ../core/[view, command, keymap, node, rootview, commandview, doc, docview]

type
  TreeViewNode* = object
    filename*: string
    isDir*: bool
    expanded*: bool
    children*: seq[TreeViewNode]

  TreeView* = ref object of View
    rootNodes*: seq[TreeViewNode]
    selectedItem*: string
    visible*: bool

proc newTreeView*(): TreeView =
  let tv = TreeView(
    typeName: "TreeView",
    rootNodes: @[],
    selectedItem: "",
    visible: true,
    scrollable: true
  )
  tv.size.x = 200.0
  return tv

proc buildDirectoryTree*(path: string): TreeViewNode =
  var node = TreeViewNode(filename: path, isDir: dirExists(path), expanded: true, children: @[])
  if node.isDir:
    for kind, p in walkDir(path, relative = true):
      let full = path / p
      if kind == pcDir:
        node.children.add(TreeViewNode(filename: full, isDir: true, expanded: false, children: @[]))
      else:
        node.children.add(TreeViewNode(filename: full, isDir: false, expanded: false, children: @[]))
  return node

proc initNavigationPlugins*(reg: CommandRegistry, km: Keymap, rv: RootView, tv: TreeView, cv: CommandView = nil) =
  reg.addCommand("treeview:toggle", proc() =
    tv.visible = not tv.visible
    tv.size.x = if tv.visible: 200.0 else: 0.0
    if rv != nil and rv.rootNode != nil:
      rv.rootNode.updateLayout()
  )

  reg.addCommand("project-search:find", proc() =
    if cv != nil:
      cv.enter("Project Search", proc(needle: string, sug: SuggestionItem) =
        if needle.len > 0 and rv != nil:
          let resultsDoc = newDoc("Project Search Results")
          for path in walkDirRec(".", yieldFilter = {pcFile}):
            if fileExists(path):
              try:
                let content = readFile(path)
                let lines = content.splitLines()
                for i, l in lines:
                  if needle in l:
                    resultsDoc.lines.add(path & ":" & $(i + 1) & ": " & l & "\n")
              except IOError:
                discard
          discard rv.openDoc(resultsDoc)
      )
  )

  reg.addCommand("workspace:save", proc() =
    var session: seq[string] = @[]
    if rv != nil and rv.rootNode != nil:
      for v in rv.rootNode.views:
        if v of DocView and DocView(v).doc != nil and DocView(v).doc.filename.len > 0:
          session.add(DocView(v).doc.filename)
    if session.len > 0:
      try:
        writeFile(".lite_workspace.session", session.join("\n"))
      except IOError:
        discard
  )
