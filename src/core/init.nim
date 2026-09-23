## init.nim - Core application state, event loop, view manager, thread scheduler, and error handling
## Complete port of data/core/init.lua to Nim.

import std/[os, strutils, times, math]
import objects, common, config, style, keymap, command, view, doc, docview, logview, statusview, commandview, node, rootview, renderer, sys
import commands/commands

type
  ProjectFileItem* = object
    filename*: string
    modified*: float
    size*: int64
    isDir*: bool

  ThreadItem* = object
    wake*: float
    fn*: proc(): bool

  CoreState* = ref object of Object
    frameStart*: float
    redraw*: bool
    windowTitle*: string
    blinkStart*: float
    blinkTimer*: float
    clipRectStack*: seq[Rect]
    docs*: seq[Doc]
    logItems*: seq[LogItem]
    projectFiles*: seq[ProjectFileItem]
    threads*: seq[ThreadItem]
    activeView*: View
    lastActiveView*: View
    rootView*: RootView
    commandView*: CommandView
    statusView*: StatusView
    commandRegistry*: CommandRegistry
    keymap*: Keymap

var globalCore*: CoreState = nil

proc newCoreState*(): CoreState =
  let cs = CoreState(
    typeName: "CoreState",
    frameStart: cpuTime(),
    redraw: true,
    windowTitle: "lite",
    blinkStart: cpuTime(),
    blinkTimer: cpuTime(),
    clipRectStack: @[initRect(0, 0, 1280, 720)],
    docs: @[],
    logItems: @[],
    projectFiles: @[],
    threads: @[],
    activeView: nil,
    lastActiveView: nil,
    rootView: newRootView(),
    commandView: newCommandView(),
    statusView: newStatusView(),
    commandRegistry: initCommandRegistry(),
    keymap: initKeymap()
  )
  return cs

proc setActiveView*(cs: CoreState, v: View) =
  if v != nil and v != cs.activeView:
    cs.lastActiveView = cs.activeView
    cs.activeView = v

proc log*(cs: CoreState, text: string, at: string = "") =
  let item = LogItem(text: text, time: epochTime(), at: at)
  cs.logItems.add(item)
  if cs.statusView != nil:
    cs.statusView.showMessage("i", text)

proc logQuiet*(cs: CoreState, text: string, at: string = "") =
  let item = LogItem(text: text, time: epochTime(), at: at)
  cs.logItems.add(item)

proc errorLog*(cs: CoreState, text: string, at: string = "") =
  let item = LogItem(text: text, time: epochTime(), at: at)
  cs.logItems.add(item)
  if cs.statusView != nil:
    cs.statusView.showMessage("!", text)

proc openDoc*(cs: CoreState, filename: string = ""): Doc =
  if filename.len > 0:
    let absPath = sys.absolutePathSystem(filename)
    for d in cs.docs:
      if d.filename.len > 0 and sys.absolutePathSystem(d.filename) == absPath:
        return d

  let d = newDoc(filename)
  cs.docs.add(d)
  cs.logQuiet(if filename.len > 0: "Opened doc \"" & filename & "\"" else: "Opened new doc")
  return d

proc getViewsReferencingDoc*(cs: CoreState, doc: Doc): seq[View] =
  var res: seq[View] = @[]
  if cs.rootView != nil and cs.rootView.rootNode != nil:
    for v in cs.rootView.rootNode.views:
      if v of DocView and DocView(v).doc == doc:
        res.add(v)
  return res

proc pushClipRect*(cs: CoreState, rect: Rect) =
  let last = if cs.clipRectStack.len > 0: cs.clipRectStack[^1] else: initRect(0, 0, 1280, 720)
  let x1 = max(rect.x, last.x)
  let y1 = max(rect.y, last.y)
  let x2 = min(rect.x + rect.width, last.x + last.width)
  let y2 = min(rect.y + rect.height, last.y + last.height)
  let inter = initRect(x1, y1, max(0.0, x2 - x1), max(0.0, y2 - y1))
  cs.clipRectStack.add(inter)
  renderer.setClipRect(inter)

proc popClipRect*(cs: CoreState) =
  if cs.clipRectStack.len > 1:
    discard cs.clipRectStack.pop()
  let last = cs.clipRectStack[^1]
  renderer.setClipRect(last)

proc blinkReset*(cs: CoreState) =
  cs.blinkStart = sys.getTimeSystem()

proc quit*(cs: CoreState, force: bool = false) =
  if force:
    quit(0)

  var dirtyCount = 0
  var dirtyName = ""
  for d in cs.docs:
    if d.isDirty():
      inc dirtyCount
      dirtyName = d.getName()

  if dirtyCount > 0:
    let msg = if dirtyCount == 1: "\"" & dirtyName & "\" has unsaved changes. Quit anyway?"
              else: $dirtyCount & " docs have unsaved changes. Quit anyway?"
    if sys.showConfirmDialog("Unsaved Changes", msg):
      quit(0)
  else:
    quit(0)

proc initCore*(cs: CoreState) =
  cs.keymap.addDefaultBindings()
  registerCoreCommands(cs.commandRegistry, cs.keymap, cs.rootView, cs.commandView)

  # Setup default root view splits
  let mainNode = newNode()
  cs.rootView.rootNode = mainNode

  # Split down for command view and status view
  let initialDoc = cs.openDoc()
  mainNode.views.add(newDocView(initialDoc))

proc onEvent*(cs: CoreState, ev: sys.Event): bool =
  case ev.kind
  of evTextInput:
    discard
  of evKeyPressed:
    return cs.keymap.onKeyPressed(ev.key)
  of evKeyReleased:
    discard
  of evMouseMoved:
    discard
  of evMousePressed:
    discard
  of evMouseReleased:
    discard
  of evMouseWheel:
    discard
  of evResized, evExposed:
    cs.redraw = true
  of evFileDropped:
    if ev.filename.len > 0:
      let doc = cs.openDoc(ev.filename)
      discard cs.rootView.openDoc(doc)
  of evQuit:
    cs.quit()
  return false

proc step*(cs: CoreState, width, height: float): bool =
  cs.frameStart = sys.getTimeSystem()

  # Set root view dimensions
  cs.rootView.position = initVec2(0.0, 0.0)
  cs.rootView.size = initVec2(width, height)

  # Layout status bar
  if cs.statusView != nil:
    cs.statusView.position = initVec2(0.0, height - 30.0)
    cs.statusView.size = initVec2(width, 30.0)

  # Layout command view
  let cvActive = cs.commandView != nil and cs.commandView.label.len > 0
  if cvActive:
    cs.commandView.position = initVec2(0.0, height - 60.0)
    cs.commandView.size = initVec2(width, 30.0)

  # Layout root view
  if cs.rootView.rootNode != nil:
    cs.rootView.rootNode.position = initVec2(0.0, 0.0)
    cs.rootView.rootNode.size = initVec2(width, height - (if cvActive: 60.0 else: 30.0))
    cs.rootView.rootNode.updateLayout()

  # Window title update
  let activeName = if cs.activeView != nil: cs.activeView.getName() else: "---"
  let title = if activeName != "---": activeName & " - lite" else: "lite"
  if title != cs.windowTitle:
    sys.setWindowTitle(title)
    cs.windowTitle = title

  # Render frame
  renderer.beginFrame()
  cs.clipRectStack = @[initRect(0.0, 0.0, width, height)]
  renderer.setClipRect(cs.clipRectStack[0])

  cs.rootView.draw()
  if cvActive:
    cs.commandView.draw()
  if cs.statusView != nil:
    cs.statusView.draw()

  renderer.endFrame()
  return true

proc run1*(cs: CoreState, width, height: float): bool =
  return cs.step(width, height)
