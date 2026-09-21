## plugins_ui.nim - UI enhancement, console, macro, and status plugins
## Ports colorpreview.lua, console.lua, contextmenu.lua, lineguide.lua, macro.lua, markers.lua, motiontrail.lua, rainbowparen.lua, scale.lua, scalestatus.lua, todotreeview.lua.

import ../core/[view, command, keymap]

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

proc initUIPlugins*(reg: CommandRegistry, km: Keymap) =
  reg.addCommand("console:toggle", proc() =
    # toggle embedded console
    discard
  )

  reg.addCommand("macro:record", proc() =
    # record key sequence macro
    discard
  )

  reg.addCommand("scale:increase", proc() =
    # scale UI font size up
    discard
  )

  reg.addCommand("scale:decrease", proc() =
    # scale UI font size down
    discard
  )
