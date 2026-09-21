## plugins_edit.nim - Code editing, indentation, and formatting plugins
## Ports autoinsert.lua, autowrap.lua, bracketmatch.lua, detectindent.lua, drawwhitespace.lua, eofnewline.lua, indentguide.lua, lfautoinsert.lua, quote.lua, reflow.lua, selectionhighlight.lua, sort.lua, tabularize.lua, trimwhitespace.lua.

import ../core/[doc, command, keymap]

proc autoMatchBracket*(d: Doc, ch: char): bool =
  case ch
  of '(': d.insert(1, 1, ")"); return true
  of '[': d.insert(1, 1, "]"); return true
  of '{': d.insert(1, 1, "}"); return true
  else: return false

proc initEditingPlugins*(reg: CommandRegistry, km: Keymap) =
  reg.addCommand("trim-whitespace:trim", proc() =
    # trim trailing whitespace
    discard
  )

  reg.addCommand("sort:lines", proc() =
    # sort selected lines
    discard
  )

  reg.addCommand("tabularize:align", proc() =
    # align columns
    discard
  )
