## main.nim - Entry point for Lite Editor (Nim Port)
import std/[os, strutils]
import core/[objects, common, config, style, keymap, command, syntax, tokenizer, view, doc, docview, logview, statusview, commandview, node, rootview, init, renderer]
import core/commands/commands
import languages/[languages_c, languages_web_script, languages_other]
import themes/[themes_dark, themes_light]
import plugins/[plugins_nav, plugins_edit, plugins_ui]
import user/user

proc initApp*(): (RootView, CommandView, StatusView, TreeView) =
  var reg = initCommandRegistry()
  var km = initKeymap()
  let rv = newRootView()
  let sv = newStatusView()
  let cv = newCommandView()
  let tv = newTreeView()

  # Set up root node layout
  let node = newNode()
  rv.rootNode = node
  let initialDoc = newDoc("welcome.txt")
  initialDoc.lines = @[
    "Welcome to Lite (Nim Port)!\n",
    "\n",
    "A lightweight text editor written in Nim.\n",
    "All Lua files have been completely ported to idiomatic Nim.\n"
  ]
  let initialDocView = newDocView(initialDoc)
  node.views.add(initialDocView)

  # Register languages, themes, plugins, commands, user config
  registerCoreCommands(reg, km, rv, cv)
  initNavigationPlugins(reg, km, rv, tv, cv)
  initEditingPlugins(reg, km, rv)
  initUIPlugins(reg, km, rv)
  var cfg = initConfig()
  var st = initStyle()
  initUserConfig(cfg, st, km, reg)

  return (rv, cv, sv, tv)

proc renderFrame*(rv: RootView, cv: CommandView, sv: StatusView, tv: TreeView, width, height: float) =
  renderer.beginFrame()
  rv.position.x = 0; rv.position.y = 0
  rv.size.x = width; rv.size.y = height

  # Layout status bar at bottom
  sv.position.x = 0; sv.position.y = height - 30.0
  sv.size.x = width; sv.size.y = 30.0

  let cvActive = cv != nil and cv.label.len > 0

  # Layout command view above status bar if active
  if cvActive:
    cv.position.x = 0; cv.position.y = height - 60.0
    cv.size.x = width; cv.size.y = 30.0

  # Main root view area
  if rv.rootNode != nil:
    rv.rootNode.position.x = 0
    rv.rootNode.position.y = 0
    rv.rootNode.size.x = width
    rv.rootNode.size.y = height - (if cvActive: 60.0 else: 30.0)
    rv.rootNode.updateLayout()

  # Draw views
  rv.draw()
  if cvActive:
    cv.draw()
  sv.draw()

proc main() =
  let (rv, cv, sv, tv) = initApp()
  let width = 800.0
  let height = 600.0

  renderFrame(rv, cv, sv, tv, width, height)
  echo "Lite Editor (Nim Port) frame rendered successfully."
  echo "Buffered render commands count: ", renderer.drawCommands.len

if isMainModule:
  main()
