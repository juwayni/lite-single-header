import std/unittest
import ../src/core/statusview

suite "StatusView Module Tests":
  test "StatusView initialization":
    let sv = newStatusView()
    check(sv.message == "")
    check(sv.tooltipMode == false)

  test "Show message and tooltip":
    let sv = newStatusView()
    sv.showMessage("i", "Document saved", 5.0)
    check(sv.message == "i | Document saved")

    sv.showTooltip("Click to navigate")
    check(sv.tooltip == "Click to navigate")
    check(sv.tooltipMode == true)

    sv.removeTooltip()
    check(sv.tooltipMode == false)
