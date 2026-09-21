## strict.nim - Variable definition and strict check module
import tables

type UndefinedVarError* = object of ValueError

type StrictRegistry* = object
  defined*: Table[string, string]

proc newStrictRegistry*(): StrictRegistry =
  result.defined = initTable[string, string]()

proc isDefined*(reg: StrictRegistry, name: string): bool =
  return reg.defined.hasKey(name)

proc define*(reg: var StrictRegistry, name: string, valueType: string = "any") =
  reg.defined[name] = valueType

proc checkGet*(reg: StrictRegistry, name: string) =
  if not reg.isDefined(name):
    raise newException(UndefinedVarError, "cannot get undefined variable: " & name)

proc checkSet*(reg: StrictRegistry, name: string) =
  if not reg.isDefined(name):
    raise newException(UndefinedVarError, "cannot set undefined variable: " & name)

var globalStrict* = newStrictRegistry()
proc globalDefine*(name: string, valueType: string = "any") = globalStrict.define(name, valueType)
proc globalCheckGet*(name: string) = globalStrict.checkGet(name)
proc globalCheckSet*(name: string) = globalStrict.checkSet(name)
