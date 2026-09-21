import std/unittest
import ../src/core/doc

suite "Doc Module Tests":
  test "New Doc creation and initial state":
    let d = newDoc()
    check(d.getName() == "unsaved")
    check(d.lines.len == 1)
    check(d.lines[0] == "\n")
    check(not d.isDirty())

  test "Insert, remove and get text":
    let d = newDoc()
    d.insert(1, 1, "hello world\nsecond line\n")
    check(d.lines.len == 3)
    check(d.isDirty())

    let txt = d.getText(1, 1, 1, 6)
    check(txt == "hello")

  test "Undo and Redo":
    let d = newDoc()
    d.insert(1, 1, "test text")
    check(d.getText(1, 1, 1, 10) == "test text")

    d.undo()
    check(d.lines[0] == "\n")

    d.redo()
    check(d.getText(1, 1, 1, 10) == "test text")

  test "Multi-line Undo and Redo":
    let d = newDoc()
    d.insert(1, 1, "line 1\nline 2\nline 3\n")
    check(d.lines.len == 4)

    d.undo()
    check(d.lines.len == 1)
    check(d.lines[0] == "\n")

    d.redo()
    check(d.lines.len == 4)
    check(d.lines[0] == "line 1\n")

  test "Search find in Doc":
    let d = newDoc()
    d.insert(1, 1, "function foo()\n  return 42\nend")
    let (l1, c1, l2, c2) = d.searchFind(1, 1, "return")
    check(l1 == 2)
    check(c1 == 3)
    check(l2 == 2)
    check(c2 == 9)
