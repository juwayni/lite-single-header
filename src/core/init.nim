## init.nim - Core application state, event loop, view manager, and thread scheduler
## Ports data/core/init.lua to Nim.

import std/times
import objects, common, keymap, command, view, doc, logview, statusview, commandview, rootview
import commands/commands

type
  CoreState* = ref object of Object
    frameStart*: float
    redraw*: bool
    windowTitle*: string
    blinkStart*: float
    blinkTimer*: float
    docs*: seq[Doc]
    logItems*: seq[LogItem]
    activeView*: View
    lastActiveView*: View
    rootView*: RootView
    commandView*: CommandView
    statusView*: StatusView
    commandRegistry*: CommandRegistry
    keymap*: Keymap

proc newCoreState*(): CoreState =
  let cs = CoreState(
    typeName: "CoreState",
    frameStart: epochTime(),
    redraw: true,
    windowTitle: "lite",
    blinkStart: epochTime(),
    blinkTimer: epochTime(),
    docs: @[],
    logItems: @[],
    activeView: nil,
    lastActiveView: nil,
    rootView: newRootView(),
    commandView: newCommandView(),
    statusView: newStatusView(),
    commandRegistry: newCommandRegistry(),
    keymap: initKeymap()
  )
  cs.keymap.addDefaultBindings()
  registerCoreCommands(cs.commandRegistry, cs.keymap, cs.rootView, cs.commandView)
  return cs

proc setActiveView*(cs: CoreState, v: View) =
  if v != nil and v != cs.activeView:
    cs.lastActiveView = cs.activeView
    cs.activeView = v

proc log*(cs: CoreState, text: string, at: string = "") =
  let item = LogItem(text: text, time: epochTime(), at: at)
  cs.logItems.add(item)

proc openDoc*(cs: CoreState, filename: string = ""): Doc =
  if filename.len > 0:
    for d in cs.docs:
      if d.filename == filename:
        return d

  let d = newDoc(filename)
  cs.docs.add(d)
  cs.log(if filename.len > 0: "Opened doc " & filename else: "Opened new doc")
  return d

proc step*(cs: CoreState) =
  cs.rootView.size = initVec2(1280.0, 720.0)
  discard cs.rootView.update()
  cs.redraw = false

proc run1*(cs: CoreState) =
  cs.step()

var globalCore* = newCoreState()
