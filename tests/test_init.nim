import std/unittest
import ../src/core/init
import ../src/core/view
import ../src/core/doc
import ../src/core/rootview

suite "Init Module Tests":
  test "Core state initialization":
    let cs = newCoreState()
    check(cs.windowTitle == "lite")
    check(cs.rootView != nil)
    check(cs.commandView != nil)
    check(cs.statusView != nil)

  test "Core openDoc and active view management":
    let cs = newCoreState()
    let d = cs.openDoc("main.nim")
    check(cs.docs.len == 1)
    check(d.filename == "main.nim")

    let dv = cs.rootView.openDoc(d)
    cs.setActiveView(dv)
    check(cs.activeView == dv)

  test "Core main step execution":
    let cs = newCoreState()
    cs.run1()
    check(cs.rootView.size.x == 1280.0)
