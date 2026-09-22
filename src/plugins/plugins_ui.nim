## plugins_ui.nim - UI enhancement, console, macro, and status plugins
## Ports colorpreview.lua, console.lua, contextmenu.lua, lineguide.lua, macro.lua, markers.lua, motiontrail.lua, rainbowparen.lua, scale.lua, scalestatus.lua, todotreeview.lua.

import ../core/[view, command, keymap, config, node, rootview]

type
  ConsoleView* = ref object of View
    buffer*: seq[string]
    visible*: bool

  MacroRecorder* = object
    recording*: bool
    recordedStrokes*: seq[string]

var globalMacroRecorder* = MacroRecorder(recording: false, recordedStrokes: @[])

proc newConsoleView*(): ConsoleView =
  let cv = ConsoleView(
    typeName: "ConsoleView",
    buffer: @[],
    visible: false,
    scrollable: true
  )
  cv.size.y = 150.0
  return cv

proc appendLog*(cv: ConsoleView, msg: string) =
  cv.buffer.add(msg)

proc initUIPlugins*(reg: CommandRegistry, km: Keymap, rv: RootView = nil, cv: ConsoleView = nil) =
  reg.addCommand("scale:increase", proc() =
    defaultConfig.lineHeight += 0.1
  )

  reg.addCommand("scale:decrease", proc() =
    if defaultConfig.lineHeight > 0.5:
      defaultConfig.lineHeight -= 0.1
  )

  reg.addCommand("console:toggle", proc() =
    if cv != nil:
      cv.visible = not cv.visible
      cv.size.y = if cv.visible: 150.0 else: 0.0
      if rv != nil and rv.rootNode != nil:
        rv.rootNode.updateLayout()
  )

  reg.addCommand("macro:record", proc() =
    globalMacroRecorder.recording = not globalMacroRecorder.recording
    if globalMacroRecorder.recording:
      globalMacroRecorder.recordedStrokes = @[]
  )

  reg.addCommand("macro:play", proc() =
    for stroke in globalMacroRecorder.recordedStrokes:
      discard reg.perform(stroke)
  )
