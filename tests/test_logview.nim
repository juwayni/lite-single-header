import std/unittest
import ../src/core/logview

suite "LogView Module Tests":
  test "LogView creation and adding items":
    let lv = newLogView()
    check(lv.getName() == "Log")
    check(lv.items.len == 0)

    lv.addLogItem("Loaded plugin foo", "core/init.lua:10")
    check(lv.items.len == 1)
    check(lv.items[0].text == "Loaded plugin foo")
    check(lv.items[0].at == "core/init.lua:10")

  test "LogView animation update":
    let lv = newLogView()
    lv.addLogItem("Error message", "core/main.lua:50", "Stack trace line 1")
    check(lv.yOffset < 0.0)

    discard lv.update()
    check(lv.yOffset >= -20.0)
