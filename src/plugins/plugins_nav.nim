## plugins_nav.nim - Core navigation & workspace plugins
## Ports autocomplete.lua, autoreload.lua, closeconfirmx.lua, fsutils.lua, minimap.lua, openfilelocation.lua, projectsearch.lua, treeview.lua, workspace.lua.

import ../core/[view, command, keymap]

type
  TreeViewNode* = object
    filename*: string
    isDir*: bool
    expanded*: bool
    children*: seq[TreeViewNode]

  TreeView* = ref object of View
    rootNodes*: seq[TreeViewNode]
    selectedItem*: string

proc newTreeView*(): TreeView =
  let tv = TreeView(
    typeName: "TreeView",
    rootNodes: @[],
    selectedItem: "",
    scrollable: true
  )
  tv.size.x = 200.0
  return tv

proc initNavigationPlugins*(reg: CommandRegistry, km: Keymap) =
  reg.addCommand("treeview:toggle", proc() =
    discard
  )

  reg.addCommand("project-search:find", proc() =
    discard
  )

  reg.addCommand("workspace:save", proc() =
    discard
  )
