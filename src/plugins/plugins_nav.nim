## plugins_nav.nim - Core navigation & workspace plugins
## Ports autocomplete.lua, autoreload.lua, closeconfirmx.lua, fsutils.lua, minimap.lua, openfilelocation.lua, projectsearch.lua, treeview.lua, workspace.lua.

import std/os
import ../core/[view, command, keymap, node, rootview]

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

proc initNavigationPlugins*(reg: CommandRegistry, km: Keymap, rv: RootView, tv: TreeView) =
  reg.addCommand("treeview:toggle", proc() =
    tv.visible = not tv.visible
    tv.size.x = if tv.visible: 200.0 else: 0.0
    if rv != nil and rv.rootNode != nil:
      rv.rootNode.updateLayout()
  )

  reg.addCommand("project-search:find", proc() =
    discard
  )

  reg.addCommand("workspace:save", proc() =
    discard
  )
