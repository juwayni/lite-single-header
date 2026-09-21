## common.nim - Core common utility functions
## Ports data/core/common.lua to Nim with improved performance, strong typing, and robust UTF-8/color handling.

import std/[math, strutils, sequtils, algorithm, times, os, unicode]

type
  Vec2* = object
    x*, y*: float

  Rect* = object
    x*, y*, width*, height*: float

  Color* = object
    r*, g*, b*, a*: float # range 0.0 .. 255.0

  PositionedAndSized* = concept x
    x.position is Vec2
    x.size is Vec2

  FuzzyItem* = object
    text*: string
    score*: int

proc initVec2*(x, y: float): Vec2 =
  Vec2(x: x, y: y)

proc initRect*(x, y, w, h: float): Rect =
  Rect(x: x, y: y, width: w, height: h)

proc initColor*(r, g, b: float, a: float = 255.0): Color =
  Color(r: r, g: g, b: b, a: a)

proc copyPositionAndSize*[T](dst: var T, src: T) =
  dst.position = src.position
  dst.size = src.size

proc isUtf8Cont*(ch: char): bool =
  let b = ord(ch)
  return b >= 0x80 and b < 0xC0

proc utf8Len*(text: string): int =
  return text.runeLen()

proc clamp*[T: SomeNumber](n, lo, hi: T): T =
  if n < lo: return lo
  if n > hi: return hi
  return n

proc round*[T: SomeFloat](n: T): T =
  if n >= 0.0:
    return floor(n + 0.5)
  else:
    return ceil(n - 0.5)

proc roundInt*[T: SomeFloat](n: T): int =
  int(round(n))

proc lerp*(a, b, t: float): float =
  a + (b - a) * t

proc lerpColor*(a, b: Color, t: float): Color =
  initColor(
    lerp(a.r, b.r, t),
    lerp(a.g, b.g, t),
    lerp(a.b, b.b, t),
    lerp(a.a, b.a, t)
  )

proc color*(str: string): Color =
  let clean = str.strip()
  if clean.startsWith("#") and clean.len >= 7:
    let r = parseHexInt(clean[1..2]).float
    let g = parseHexInt(clean[3..4]).float
    let b = parseHexInt(clean[5..6]).float
    var a = 255.0
    if clean.len >= 9:
      a = parseHexInt(clean[7..8]).float
    return initColor(r, g, b, a)
  elif clean.startsWith("rgb"):
    let openParen = clean.find('(')
    let closeParen = clean.find(')')
    if openParen > 0 and closeParen > openParen:
      let parts = clean[openParen+1 ..< closeParen].split(',')
      if parts.len >= 3:
        let r = parseFloat(parts[0].strip())
        let g = parseFloat(parts[1].strip())
        let b = parseFloat(parts[2].strip())
        var a = 1.0
        if parts.len >= 4:
          a = parseFloat(parts[3].strip())
        return initColor(r, g, b, a * 255.0)
  raise newException(ValueError, "bad color string: '" & str & "'")

proc splice*[T](s: var seq[T], atIndex, removeCount: int, insertItems: openArray[T] = []) =
  let actualAt = clamp(atIndex, 0, s.len)
  let actualRemove = clamp(removeCount, 0, s.len - actualAt)
  if actualRemove > 0:
    s.delete(actualAt ..< (actualAt + actualRemove))
  if insertItems.len > 0:
    s.insert(insertItems, actualAt)

proc fuzzyMatchScore*(str, ptn: string): (bool, int) =
  var score = 0
  var run = 0
  var sIdx = 0
  var pIdx = 0

  while sIdx < str.len and pIdx < ptn.len:
    while sIdx < str.len and str[sIdx] == ' ': inc sIdx
    while pIdx < ptn.len and ptn[pIdx] == ' ': inc pIdx
    if sIdx >= str.len or pIdx >= ptn.len: break

    if toLowerAscii(str[sIdx]) == toLowerAscii(ptn[pIdx]):
      score += run * 10 - (if str[sIdx] != ptn[pIdx]: 1 else: 0)
      inc run
      inc pIdx
    else:
      score -= 10
      run = 0
    inc sIdx

  if pIdx < ptn.len:
    return (false, 0)

  return (true, score - (str.len - sIdx))

proc fuzzyMatchItems*(items: openArray[string], needle: string): seq[string] =
  var matched: seq[FuzzyItem] = @[]
  for item in items:
    let (ok, sc) = fuzzyMatchScore(item, needle)
    if ok:
      matched.add(FuzzyItem(text: item, score: sc))

  matched.sort(proc(a, b: FuzzyItem): int = cmp(b.score, a.score))
  return matched.mapIt(it.text)

proc pathSuggest*(text: string, dirPathSeparator: string = "/"): seq[string] =
  result = @[]
  var path = "."
  var name = text
  let lastSlash = max(text.rfind('/'), text.rfind('\\'))
  if lastSlash != -1:
    path = text[0 .. lastSlash]
    name = text[lastSlash + 1 .. ^1]

  let targetDir = if path == "" or path == ".": "." else: path
  if not dirExists(targetDir):
    return result

  for kind, p in walkDir(targetDir, relative = true):
    let full = if path == "." or path == "": p else: path & p
    let isDir = kind in {pcDir, pcLinkToDir}
    let formatted = if isDir: full & dirPathSeparator else: full
    if formatted.toLowerAscii().startsWith(text.toLowerAscii()):
      result.add(formatted)

proc isIdentChar(ch: char): bool =
  return ch in {'a'..'z', 'A'..'Z', '0'..'9', '_'}

# Robust pattern matching without external C dependencies
proc matchPattern*(text: string, pattern: string): (int, int) =
  if text.len == 0 or pattern.len == 0: return (-1, -1)

  var ptn = pattern
  var isStart = false
  var isEnd = false

  if ptn.startsWith("^"):
    isStart = true
    ptn = ptn[1..^1]
  if ptn.endsWith("$"):
    isEnd = true
    ptn = ptn[0..^2]

  ptn = ptn.replace(r"\.", ".").replace("%.", ".")

  # Check word/identifier pattern [%a_][%w_]* or [_a-zA-Z0-9]+
  if ptn in ["[%a_][%w_]*", "[_a-zA-Z0-9]+", r"\w+"]:
    if isIdentChar(text[0]):
      var count = 0
      while count < text.len and isIdentChar(text[count]):
        inc count
      return (0, count - 1)
    else:
      return (-1, -1)

  if ptn.contains(".*"):
    let parts = ptn.split(".*")
    if parts.len == 2:
      let prefix = parts[0]
      let suffix = parts[1]
      let startOk = not isStart or text.startsWith(prefix)
      let endOk = not isEnd or text.endsWith(suffix)
      let pIdx = if prefix.len > 0: text.find(prefix) else: 0
      let sIdx = if suffix.len > 0: text.rfind(suffix) else: text.len
      if startOk and endOk and pIdx >= 0 and sIdx >= pIdx:
        return (pIdx, sIdx + suffix.len - 1)

  if isStart and isEnd:
    if text == ptn:
      return (0, text.len - 1)
  elif isStart:
    if text.startsWith(ptn):
      return (0, ptn.len - 1)
  elif isEnd:
    if text.endsWith(ptn):
      return (text.len - ptn.len, text.len - 1)
  else:
    let idx = text.find(ptn)
    if idx >= 0:
      return (idx, idx + ptn.len - 1)

  return (-1, -1)

proc matchPatterns*(text: string, patterns: openArray[string]): (int, int) =
  for ptn in patterns:
    let (s, e) = matchPattern(text, ptn)
    if s >= 0:
      return (s, e)
  return (-1, -1)

proc bench*[T](name: string, fn: proc(): T): T =
  let startTime = cpuTime()
  result = fn()
  let elapsedMs = (cpuTime() - startTime) * 1000.0
  let perFrame = (elapsedMs / (1000.0 / 60.0)) * 100.0
  echo "$1 : $2ms $3%" % [name.alignLeft(16), elapsedMs.formatFloat(ffDecimal, 3).alignLeft(8), perFrame.formatFloat(ffDecimal, 2)]

proc serialize*(str: string): string =
  return escape(str)

proc serialize*(val: float): string =
  return $val

proc serialize*(val: int): string =
  return $val

proc serialize*(val: bool): string =
  return $val
