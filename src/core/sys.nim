## sys.nim - System bindings, OS integration, clipboards, events, and file system utilities
## Ports lite.h, lite_sys.h, and system API from C to Nim.

import std/[os, strutils, times, math]
import common

type
  CursorShape* = enum
    csArrow, csIBeam, csSizeH, csSizeV, csHand

  WindowMode* = enum
    wmNormal, wmMaximized, wmFullscreen

  EventKind* = enum
    evQuit, evResized, evExposed, evFileDropped,
    evKeyPressed, evKeyReleased, evTextInput,
    evMousePressed, evMouseReleased, evMouseMoved, evMouseWheel

  Event* = object
    kind*: EventKind
    width*, height*: int
    x*, y*, dx*, dy*: float
    button*: string
    clicks*: int
    key*: string
    text*: string
    filename*: string

var currentCursor*: CursorShape = csArrow
var currentTitle*: string = "lite"
var currentWindowMode*: WindowMode = wmNormal
var windowFocused*: bool = true
var windowSize*: Vec2 = initVec2(800.0, 600.0)
var mousePos*: Vec2 = initVec2(0.0, 0.0)
var systemClipboard*: string = ""

proc setCursor*(shape: CursorShape) =
  currentCursor = shape

proc setWindowTitle*(title: string) =
  currentTitle = title

proc setWindowMode*(mode: WindowMode) =
  currentWindowMode = mode

proc windowHasFocus*(): bool =
  return windowFocused

proc showConfirmDialog*(title, message: string): bool =
  echo "[Dialog] ", title, ": ", message
  return true

proc chdirSystem*(path: string): bool =
  try:
    setCurrentDir(path)
    return true
  except OSError:
    return false

proc listDirSystem*(path: string): seq[string] =
  var res: seq[string] = @[]
  if dirExists(path):
    for kind, p in walkDir(path, relative = true):
      res.add(p)
  return res

proc absolutePathSystem*(path: string): string =
  try:
    return absolutePath(path)
  except OSError:
    return path

type
  FileInfo* = object
    modified*: float
    size*: int64
    kind*: string # "file", "dir", or ""

proc getFileInfoSystem*(path: string): FileInfo =
  if fileExists(path):
    let stat = getFileInfo(path)
    return FileInfo(modified: stat.lastWriteTime.toUnixFloat(), size: stat.size, kind: "file")
  elif dirExists(path):
    let stat = getFileInfo(path)
    return FileInfo(modified: stat.lastWriteTime.toUnixFloat(), size: stat.size, kind: "dir")
  else:
    return FileInfo(modified: 0.0, size: 0, kind: "")

proc getClipboardSystem*(): string =
  if systemClipboard.len > 0:
    return systemClipboard
  return common.getClipboardText()

proc setClipboardSystem*(text: string) =
  systemClipboard = text
  common.setClipboardText(text)

proc getTimeSystem*(): float =
  return cpuTime()

proc sleepSystem*(seconds: float) =
  os.sleep(int(seconds * 1000.0))

proc execSystem*(cmd: string) =
  discard execShellCmd(cmd & " &")

proc fuzzyMatch*(str, ptn: string): int =
  var score = 0
  var run = 0
  var sIdx = 0
  var pIdx = 0
  let sLower = str.toLowerAscii()
  let pLower = ptn.toLowerAscii()

  while sIdx < sLower.len and pIdx < pLower.len:
    while sIdx < sLower.len and sLower[sIdx] == ' ': inc sIdx
    while pIdx < pLower.len and pLower[pIdx] == ' ': inc pIdx
    if sIdx < sLower.len and pIdx < pLower.len:
      if sLower[sIdx] == pLower[pIdx]:
        score += run * 10 - (if str[sIdx] != ptn[pIdx]: 1 else: 0)
        inc run
        inc pIdx
      else:
        score -= 10
        run = 0
      inc sIdx

  if pIdx < pLower.len:
    return 0

  return score - (str.len - sIdx)
