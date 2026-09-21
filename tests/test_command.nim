import std/unittest
import ../src/core/command

suite "Command Module Tests":
  test "Prettify name":
    check(prettifyName("core:find-command") == "Core: Find Command")
    check(prettifyName("doc:go-to-line") == "Doc: Go To Line")

  test "Register and perform command":
    var reg = initCommandRegistry()
    var ran = false

    reg.addCommand("test:action", proc() =
      ran = true
    )

    check(reg.getAllValid() == @["test:action"])
    check(reg.perform("test:action"))
    check(ran)

  test "Predicate filtering":
    var reg = initCommandRegistry()
    var active = false

    reg.addCommand("test:conditional", proc() = discard, proc(): bool = active)

    check(reg.getAllValid().len == 0)
    check(not reg.perform("test:conditional"))

    active = true
    check(reg.getAllValid().len == 1)
    check(reg.perform("test:conditional"))
