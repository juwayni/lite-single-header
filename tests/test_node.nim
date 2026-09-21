import std/unittest
import ../src/core/common
import ../src/core/node
import ../src/core/view

suite "Node Module Tests":
  test "Leaf node creation":
    let n = newNode(ntLeaf)
    check(n.nodeType == ntLeaf)
    check(n.views.len == 1)
    check(n.views[0].typeName == "EmptyView")

  test "Add view and split":
    let n = newNode(ntLeaf)
    let v1 = newView("CustomDocView")
    n.addView(v1)

    check(n.views.len == 1)
    check(n.activeView == v1)

    let v2 = newView("SideView")
    let bNode = n.split("right", v2)

    check(n.nodeType == ntHSplit)
    check(n.childA != nil)
    check(n.childB != nil)
    check(bNode.activeView == v2)

  test "Layout recalculation":
    let root = newNode(ntLeaf)
    root.size = initVec2(1000.0, 600.0)
    let vRight = newView("Right")
    discard root.split("right", vRight)

    root.updateLayout()
    check(root.childA.size.x == 500.0)
    check(root.childB.size.x == 500.0)
    check(root.childB.position.x == 500.0)
