import std/[unittest, math]
import ../src/core/common
import ../src/core/view

type
  CustomScrollView = ref object of View
    contentHeight: float

method getScrollableSize(self: CustomScrollView): float =
  return self.contentHeight

suite "View Module Tests":
  test "Base View initial properties":
    let v = newView()
    check(v.getName() == "---")
    check(v.scrollable == false)
    check(v.cursor == "arrow")

  test "Scroll position clamp and smooth update":
    let sv = CustomScrollView(contentHeight: 500.0)
    sv.position = initVec2(0, 0)
    sv.size = initVec2(100, 200)
    sv.scrollable = true

    sv.scroll.toY = 1000.0
    discard sv.update()

    check(sv.scroll.toY == 300.0)
    check(sv.scroll.y > 0.0)

  test "Scrollbar rect geometry and hit test":
    let sv = CustomScrollView(contentHeight: 400.0)
    sv.position = initVec2(0, 0)
    sv.size = initVec2(100, 200)

    let rect = sv.getScrollbarRect(4.0)
    check(rect.width == 4.0)
    check(rect.height == 100.0)

    check(sv.scrollbarOverlapsPoint(98.0, 10.0, 4.0))
    check(not sv.scrollbarOverlapsPoint(10.0, 10.0, 4.0))
