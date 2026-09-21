import std/unittest
import ../src/core/common
import ../src/core/doc
import ../src/core/docview
import ../src/core/rootview

suite "RootView Module Tests":
  test "RootView instantiation and open document":
    let rv = newRootView()
    rv.size = initVec2(1280.0, 720.0)

    let d = newDoc("main.nim")
    d.insert(1, 1, "echo \"hello\"")

    let dv = rv.openDoc(d)
    check(dv != nil)
    check(dv.doc == d)
    check(rv.rootNode.activeView == dv)

  test "Reopening existing document reuses DocView":
    let rv = newRootView()
    let d = newDoc("shared.nim")

    let dv1 = rv.openDoc(d)
    let dv2 = rv.openDoc(d)

    check(dv1 == dv2)
    check(rv.rootNode.views.len == 1)
