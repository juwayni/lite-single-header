## command.nim - Command registry and dispatching
## Ports data/core/command.lua to Nim.

import tables, strutils, sequtils

type
  CommandPredicate* = proc(): bool {.closure.}
  CommandPerform* = proc(): void {.closure.}

  CommandItem* = object
    predicate*: CommandPredicate
    perform*: CommandPerform

  CommandRegistry* = ref object
    map*: Table[string, CommandItem]

proc newCommandRegistry*(): CommandRegistry =
  CommandRegistry(map: initTable[string, CommandItem]())

proc initCommandRegistry*(): CommandRegistry = newCommandRegistry()

proc alwaysTrue*(): bool = true

proc capitalizeWord*(s: string): string =
  if s.len == 0: return ""
  return toUpperAscii(s[0]) & s[1..^1]

proc prettifyName*(name: string): string =
  let replaced = name.replace(":", ": ").replace("-", " ")
  let words = replaced.splitWhitespace()
  let capitalized = words.mapIt(capitalizeWord(it))
  return capitalized.join(" ")

proc addCommand*(reg: CommandRegistry, name: string, perform: CommandPerform, predicate: CommandPredicate = alwaysTrue) =
  if reg.map.hasKey(name):
    raise newException(ValueError, "command already exists: " & name)
  reg.map[name] = CommandItem(predicate: predicate, perform: perform)

proc addCommands*(reg: CommandRegistry, commands: openArray[(string, CommandPerform)], predicate: CommandPredicate = alwaysTrue) =
  for (name, fn) in commands:
    reg.addCommand(name, fn, predicate)

proc getAllValid*(reg: CommandRegistry): seq[string] =
  result = @[]
  for name, cmd in reg.map:
    if cmd.predicate == nil or cmd.predicate():
      result.add(name)

proc perform*(reg: CommandRegistry, name: string): bool =
  if reg.map.hasKey(name):
    let cmd = reg.map[name]
    if cmd.predicate == nil or cmd.predicate():
      if cmd.perform != nil:
        cmd.perform()
      return true
  return false

var globalCommandRegistry* = newCommandRegistry()
