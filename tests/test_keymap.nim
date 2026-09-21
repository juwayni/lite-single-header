import std/[unittest, tables]
import ../src/core/keymap

suite "Keymap Module Tests":
  test "Default bindings and lookup":
    var km = initKeymap()
    km.addDefaultBindings()

    check(km.getBinding("core:find-command") == "ctrl+shift+p")
    check(km.getBinding("doc:save") == "ctrl+s")

  test "Modifier state press and release":
    var km = initKeymap()
    check(not km.onKeyPressed("left ctrl"))
    check(km.modkeys["ctrl"] == true)

    let stroke = km.keyToStroke("s")
    check(stroke == "ctrl+s")

    km.onKeyReleased("left ctrl")
    check(km.modkeys["ctrl"] == false)

  test "Custom binding and dispatch":
    var km = initKeymap()
    var lastExecuted = ""

    let dispatcher = proc(cmd: string): bool =
      lastExecuted = cmd
      return true

    km.addBinding("ctrl+k", "custom:action")
    discard km.onKeyPressed("left ctrl")
    let handled = km.onKeyPressed("k", dispatcher)

    check(handled)
    check(lastExecuted == "custom:action")
