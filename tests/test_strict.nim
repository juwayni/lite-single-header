import std/unittest
import ../src/core/strict

suite "Strict Module Tests":
  test "Registry define and check":
    var reg = newStrictRegistry()
    check(not reg.isDefined("foo"))

    reg.define("foo", "string")
    check(reg.isDefined("foo"))

    reg.checkGet("foo")
    reg.checkSet("foo")

  test "Undefined variable access raises error":
    var reg = newStrictRegistry()
    expect(UndefinedVarError):
      reg.checkGet("bar")

    expect(UndefinedVarError):
      reg.checkSet("bar")

  test "Global strict functions":
    globalDefine("config")
    globalCheckGet("config")
    globalCheckSet("config")
    expect(UndefinedVarError):
      globalCheckGet("nonExistentGlobal")
