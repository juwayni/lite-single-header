import std/unittest
import ../src/core/renderer
import ../src/core/style
import ../src/core/common

suite "Renderer Primitives Tests":
  test "Draw commands buffer":
    beginFrame()
    setClipRect(initRect(0, 0, 1000, 800))
    drawRect(initRect(10, 10, 100, 50), color("#ff0000"))
    check(drawCommands.len == 2)
    check(drawCommands[1].commandType == rcDrawRect)
    check(drawCommands[1].rect.width == 100.0)

  test "Draw text command and width calculation":
    beginFrame()
    let font = loadFontStub("font.ttf", 14.0)
    let endX = drawText(font, "Hello Nim", 10.0, 10.0, color("#ffffff"))
    check(endX > 10.0)
    check(drawCommands.len == 1)
    check(drawCommands[0].text == "Hello Nim")
