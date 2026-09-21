import std/unittest
import ../src/core/doc
import ../src/core/docview

suite "DocView Module Tests":
  test "DocView instantiation and properties":
    let d = newDoc("test.nim")
    d.insert(1, 1, "line 1\nline 2\nline 3\n")
    let dv = newDocView(d)

    check(dv.getName() == "test.nim*")
    check(dv.cursor == "ibeam")

  test "Visible line range":
    let d = newDoc()
    for i in 1 .. 100:
      d.insert(i, 1, "line\n")
    let dv = newDocView(d)
    dv.size.x = 800
    dv.size.y = 200

    let (minL, maxL) = dv.getVisibleLineRange()
    check(minL >= 1)
    check(maxL > minL)

  test "Resolve screen position":
    let d = newDoc()
    d.insert(1, 1, "first line\nsecond line\n")
    let dv = newDocView(d)
    dv.size.x = 800
    dv.size.y = 600

    let (l, c) = dv.resolveScreenPosition(100.0, 10.0)
    check(l >= 1)
    check(c >= 1)
