## keymap.nim - Keybindings, modifier state, and input stroke mapping
## Ports data/core/keymap.lua to Nim with improved stroke lookup and command dispatching.

import tables

type
  CommandDispatcher* = proc(cmdName: string): bool

type
  Keymap* = object
    modkeys*: Table[string, bool] # "ctrl", "alt", "altgr", "shift"
    map*: Table[string, seq[string]] # stroke -> sequence of command names
    reverseMap*: Table[string, string] # command name -> stroke

const ModKeysList* = ["ctrl", "alt", "altgr", "shift"]

const ModKeyNameMap* = [
  ("left ctrl", "ctrl"),
  ("right ctrl", "ctrl"),
  ("left shift", "shift"),
  ("right shift", "shift"),
  ("left alt", "alt"),
  ("right alt", "altgr")
]

proc initKeymap*(): Keymap =
  result = Keymap(
    modkeys: initTable[string, bool](),
    map: initTable[string, seq[string]](),
    reverseMap: initTable[string, string]()
  )
  for k in ModKeysList:
    result.modkeys[k] = false

proc keyToStroke*(km: Keymap, key: string): string =
  var stroke = ""
  for mk in ModKeysList:
    if km.modkeys.getOrDefault(mk, false):
      stroke &= mk & "+"
  return stroke & key

proc addBinding*(km: var Keymap, stroke: string, commands: openArray[string], overwrite: bool = false) =
  let cmds = @commands
  if overwrite:
    km.map[stroke] = cmds
  else:
    var existing = km.map.getOrDefault(stroke, @[])
    for i in countdown(cmds.len - 1, 0):
      existing.insert(cmds[i], 0)
    km.map[stroke] = existing

  for cmd in cmds:
    km.reverseMap[cmd] = stroke

proc addBinding*(km: var Keymap, stroke: string, command: string, overwrite: bool = false) =
  km.addBinding(stroke, [command], overwrite)

proc getBinding*(km: Keymap, command: string): string =
  return km.reverseMap.getOrDefault(command, "")

proc onKeyPressed*(km: var Keymap, key: string, dispatcher: CommandDispatcher = nil): bool =
  for (mkRaw, mkNormalized) in ModKeyNameMap:
    if key == mkRaw:
      km.modkeys[mkNormalized] = true
      if mkNormalized == "altgr":
        km.modkeys["ctrl"] = false
      return false

  let stroke = km.keyToStroke(key)
  if km.map.hasKey(stroke):
    let commands = km.map[stroke]
    for cmd in commands:
      if dispatcher != nil:
        let performed = dispatcher(cmd)
        if performed:
          return true
      else:
        return true
    return true
  return false

proc onKeyReleased*(km: var Keymap, key: string) =
  for (mkRaw, mkNormalized) in ModKeyNameMap:
    if key == mkRaw:
      km.modkeys[mkNormalized] = false

proc addDefaultBindings*(km: var Keymap) =
  km.addBinding("ctrl+shift+p", "core:find-command")
  km.addBinding("ctrl+p", "core:find-file")
  km.addBinding("ctrl+o", "core:open-file")
  km.addBinding("ctrl+n", "core:new-doc")
  km.addBinding("alt+return", "core:toggle-fullscreen")

  km.addBinding("alt+shift+j", "root:split-left")
  km.addBinding("alt+shift+l", "root:split-right")
  km.addBinding("alt+shift+i", "root:split-up")
  km.addBinding("alt+shift+k", "root:split-down")

  km.addBinding("ctrl+w", "root:close")
  km.addBinding("ctrl+tab", "root:switch-to-next-tab")
  km.addBinding("ctrl+shift+tab", "root:switch-to-previous-tab")

  km.addBinding("ctrl+f", "find-replace:find")
  km.addBinding("ctrl+r", "find-replace:replace")
  km.addBinding("f3", "find-replace:repeat-find")
  km.addBinding("shift+f3", "find-replace:previous-find")
  km.addBinding("ctrl+g", "doc:go-to-line")
  km.addBinding("ctrl+s", "doc:save")
  km.addBinding("ctrl+shift+s", "doc:save-as")

  km.addBinding("ctrl+z", "doc:undo")
  km.addBinding("ctrl+y", "doc:redo")
  km.addBinding("ctrl+x", "doc:cut")
  km.addBinding("ctrl+c", "doc:copy")
  km.addBinding("ctrl+v", "doc:paste")

  km.addBinding("escape", ["command:escape", "doc:select-none"])
  km.addBinding("tab", ["command:complete", "doc:indent"])
  km.addBinding("shift+tab", "doc:unindent")
  km.addBinding("backspace", "doc:backspace")
  km.addBinding("delete", "doc:delete")
  km.addBinding("return", ["command:submit", "doc:newline"])
