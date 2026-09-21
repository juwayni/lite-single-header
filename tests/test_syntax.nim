import std/unittest
import ../src/core/syntax

suite "Syntax Module Tests":
  test "Syntax registration and matching by file pattern":
    var reg = initSyntaxRegistry()

    let nimDef = newSyntaxDef("Nim")
    nimDef.files = @[r"\.nim$", r"\.nims$"]
    reg.addDef(nimDef)

    let luaDef = newSyntaxDef("Lua")
    luaDef.files = @[r"\.lua$"]
    reg.addDef(luaDef)

    let matchedNim = reg.getSyntax("main.nim")
    check(matchedNim.name == "Nim")

    let matchedLua = reg.getSyntax("config.lua")
    check(matchedLua.name == "Lua")

    let matchedUnknown = reg.getSyntax("readme.txt")
    check(matchedUnknown.name == "Plain Text")

  test "Matching by header pattern":
    var reg = initSyntaxRegistry()

    let bashDef = newSyntaxDef("Bash")
    bashDef.headers = @[r"^#!.*sh"]
    reg.addDef(bashDef)

    let matched = reg.getSyntax("script", "#!/bin/bash")
    check(matched.name == "Bash")
