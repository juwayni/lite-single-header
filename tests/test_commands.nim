import std/[unittest, tables]
import ../src/core/command
import ../src/core/keymap
import ../src/core/rootview
import ../src/core/commandview
import ../src/core/docview
import ../src/core/node
import ../src/core/commands/commands

suite "Commands Module Tests":
  test "Core commands registration and dispatching":
    var reg = initCommandRegistry()
    var km = initKeymap()
    km.addDefaultBindings()
    let rv = newRootView()
    let cv = newCommandView()

    registerCoreCommands(reg, km, rv, cv)

    check(reg.map.hasKey("core:new-doc"))
    check(reg.map.hasKey("doc:save"))
    check(reg.map.hasKey("find-replace:find"))
    check(reg.map.hasKey("root:split-right"))

    check(reg.perform("core:new-doc"))
    check(rv.rootNode.activeView of DocView)

  test "Root split command":
    var reg = initCommandRegistry()
    var km = initKeymap()
    let rv = newRootView()
    let cv = newCommandView()

    registerCoreCommands(reg, km, rv, cv)
    check(reg.perform("root:split-right"))
    check(rv.rootNode.nodeType == ntHSplit)
