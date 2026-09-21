## renderer.nim - Rendering backend primitives and drawing commands
## Ports lite renderer/rencache C API to Nim.

import common, style

type
  RenderCommandType* = enum
    rcSetClip, rcDrawRect, rcDrawText

  RenderCommand* = object
    commandType*: RenderCommandType
    rect*: Rect
    color*: Color
    text*: string
    font*: FontHandle

var drawCommands*: seq[RenderCommand] = @[]
var currentClip*: Rect = initRect(0, 0, 1280, 720)

proc beginFrame*() =
  drawCommands = @[]

proc endFrame*() =
  discard

proc setClipRect*(rect: Rect) =
  currentClip = rect
  drawCommands.add(RenderCommand(commandType: rcSetClip, rect: rect))

proc drawRect*(rect: Rect, color: Color) =
  drawCommands.add(RenderCommand(commandType: rcDrawRect, rect: rect, color: color))

proc getFontHeight*(font: FontHandle): float =
  if font != nil and font.size > 0:
    return font.size
  return 14.0

proc getCharWidth*(font: FontHandle, ch: char): float =
  if font != nil and font.size > 0:
    return font.size * 0.6
  return 8.0

proc getTextWidth*(font: FontHandle, text: string): float =
  let charW = getCharWidth(font, 'a')
  return float(text.len) * charW

proc drawText*(font: FontHandle, text: string, x, y: float, color: Color): float =
  let width = getTextWidth(font, text)
  drawCommands.add(RenderCommand(
    commandType: rcDrawText,
    rect: initRect(x, y, width, getFontHeight(font)),
    color: color,
    text: text,
    font: font
  ))
  return x + width
