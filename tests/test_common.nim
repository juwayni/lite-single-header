import std/[unittest, math]
import ../src/core/common

suite "Common Module Tests":
  test "Clamp and Round":
    check(clamp(15, 0, 10) == 10)
    check(clamp(-5, 0, 10) == 0)
    check(clamp(5, 0, 10) == 5)
    check(round(2.3) == 2.0)
    check(round(2.7) == 3.0)
    check(round(-2.3) == -2.0)
    check(round(-2.7) == -3.0)

  test "Color parsing":
    let c1 = color("#2e2e32")
    check(c1.r == 0x2e.float)
    check(c1.g == 0x2e.float)
    check(c1.b == 0x32.float)

    let c2 = color("rgba(255, 128, 0, 0.5)")
    check(c2.r == 255.0)
    check(c2.g == 128.0)
    check(c2.b == 0.0)
    check(c2.a == 127.5)

  test "Splice":
    var arr = @["a", "b", "c", "d"]
    splice(arr, 1, 2, ["x", "y"])
    check(arr == @["a", "x", "y", "d"])

  test "Fuzzy matching":
    let items = @["apple", "application", "apricot", "banana"]
    let res = fuzzyMatchItems(items, "app")
    check(res.len >= 2)
    check(res[0] == "apple" or res[0] == "application")

  test "Lerp and LerpColor":
    check(lerp(10.0, 20.0, 0.5) == 15.0)
    let cA = initColor(0, 0, 0, 0)
    let cB = initColor(100, 200, 255, 255)
    let cMid = lerpColor(cA, cB, 0.5)
    check(cMid.r == 50.0)
    check(cMid.g == 100.0)

  test "UTF-8 length":
    check(utf8Len("hello") == 5)
    check(utf8Len("hello 世界") == 8)
