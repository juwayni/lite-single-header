## lite.nim - Executable launcher for Lite Editor (Nim Port)
import std/[os, strutils]
import core/[objects, common, config, style, keymap, command, syntax, tokenizer, view, doc, docview, logview, statusview, commandview, node, rootview, init, renderer, sys]
import core/commands/commands
import languages/[languages_c, languages_web_script, languages_other]
import themes/[themes_dark, themes_light]
import plugins/[plugins_nav, plugins_edit, plugins_ui]
import user/user

proc main() =
  let width = 800.0
  let height = 600.0

  let coreState = newCoreState()
  globalCore = coreState

  # Setup layout & initial welcome document
  let welcomeDoc = coreState.openDoc("welcome.txt")
  welcomeDoc.lines = @[
    "Welcome to Lite (Nim Port)!\n",
    "\n",
    "A lightweight text editor written in Nim.\n",
    "All Lua files have been completely ported to idiomatic Nim.\n"
  ]

  let docView = newDocView(welcomeDoc)
  let mainNode = newNode()
  mainNode.addView(docView)
  coreState.rootView.rootNode = mainNode
  coreState.activeView = docView

  # Initialize plugins, languages, themes & commands
  registerCoreCommands(coreState.commandRegistry, coreState.keymap, coreState.rootView, coreState.commandView)
  initNavigationPlugins(coreState.commandRegistry, coreState.keymap, coreState.rootView, nil, coreState.commandView)
  initEditingPlugins(coreState.commandRegistry, coreState.keymap, coreState.rootView)
  initUIPlugins(coreState.commandRegistry, coreState.keymap, coreState.rootView)

  var cfg = initConfig()
  var st = initStyle()
  initUserConfig(cfg, st, coreState.keymap, coreState.commandRegistry)

  # Run step frame
  discard coreState.run1(width, height)

  echo "Draw commands count: ", renderer.drawCommands.len
  for i, cmd in renderer.drawCommands:
    echo i, ": ", cmd.commandType, " rect=", cmd.rect, " text=", cmd.text

  # Rasterize frame to image buffer & save PPM
  let imgBuf = renderer.renderFrameToBuffer(int(width), int(height))
  renderer.savePPM(imgBuf, "screenshot.ppm")

if isMainModule:
  main()
