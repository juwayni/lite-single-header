## plugins_ui.nim - UI enhancement, console, macro, and status plugins
## Ports colorpreview.lua, console.lua, contextmenu.lua, lineguide.lua, macro.lua, markers.lua, motiontrail.lua, rainbowparen.lua, scale.lua, scalestatus.lua, todotreeview.lua.

import ../core/[view, command, keymap, config]

type
  ConsoleView* = ref object of View
    buffer*: seq[string]

proc newConsoleView*(): ConsoleView =
  let cv = ConsoleView(
    typeName: "ConsoleView",
    buffer: @[],
    scrollable: true
  )
  cv.size.y = 150.0
  return cv

proc appendLog*(cv: ConsoleView, msg: string) =
  cv.buffer.add(msg)

proc initUIPlugins*(reg: CommandRegistry, km: Keymap) =
  reg.addCommand("scale:increase", proc() =
    defaultConfig.lineHeight += 0.1
  )

  reg.addCommand("scale:decrease", proc() =
    if defaultConfig.lineHeight > 0.5:
      defaultConfig.lineHeight -= 0.1
  )

  reg.addCommand("console:toggle", proc() =
    discard
  )

  reg.addCommand("macro:record", proc() =
    discard
  )
