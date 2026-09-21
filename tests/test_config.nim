import std/unittest
import ../src/core/config

suite "Config Module Tests":
  test "Default Config values":
    let cfg = initConfig(1.0)
    check(cfg.fps == 60.0)
    check(cfg.maxLogItems == 80)
    check(cfg.messageTimeout == 6.0)
    check(cfg.indentSize == 2)
    check(cfg.tabType == ttSoft)
    check(cfg.tabsAllowed == true)

  test "Scaled Config values":
    let cfg2 = initConfig(2.0)
    check(cfg2.mouseWheelScroll == 100.0)
