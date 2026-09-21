import std/[unittest, tables]
import ../src/core/style

suite "Style Module Tests":
  test "Default Style dimensions and colors":
    let st = initStyle(1.0, "data")
    check(st.padding.x == 14.0)
    check(st.padding.y == 7.0)
    check(st.dividerSize == 1.0)
    check(st.scrollbarSize == 4.0)
    check(st.caretWidth == 2.0)
    check(st.tabWidth == 170.0)

    check(st.syntax.hasKey("keyword"))
    check(st.syntax.hasKey("comment"))
    check(st.syntax["keyword"].r > 0.0)

  test "Font handles created":
    let st = initStyle(2.0, "data")
    check(st.font.size == 28.0)
    check(st.codeFont.size == 27.0)
