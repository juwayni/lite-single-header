## strict.nim - Enhanced variable definition and check tracking module
## Ports data/core/strict.lua to Nim with improved safety and error reporting.

import tables

type
  UndefinedVarError* = object of ValueError

type
  StrictRegistry* = object
    defined*: Table[string, string] # key -> type string or metadata

proc newStrictRegistry*(): StrictRegistry =
  result.defined = initTable[string, string]()

proc isDefined*(reg: StrictRegistry, name: string): bool =
  return reg.defined.hasKey(name)

proc define*(reg: var StrictRegistry, name: string, valueType: string = "any") =
  reg.defined[name] = valueType

proc defineMany*(reg: var StrictRegistry, definitions: openArray[(string, string)]) =
  for (name, valType) in definitions:
    reg.define(name, valType)

proc checkGet*(reg: StrictRegistry, name: string) =
  if not reg.isDefined(name):
    raise newException(UndefinedVarError, "cannot get undefined variable: " & name)

proc checkSet*(reg: StrictRegistry, name: string) =
  if not reg.isDefined(name):
    raise newException(UndefinedVarError, "cannot set undefined variable: " & name)

# Global singleton registry instance for backward compatibility with Lua global strict metamethods
var globalStrict* = newStrictRegistry()

proc globalDefine*(name: string, valueType: string = "any") =
  globalStrict.define(name, valueType)

proc globalCheckGet*(name: string) =
  globalStrict.checkGet(name)

proc globalCheckSet*(name: string) =
  globalStrict.checkSet(name)
