## objects.nim - Base Object hierarchy with dynamic and static type checking.
## Ports data/core/object.lua to Nim with improved type safety and object composition.

type
  Object* = ref object of RootObj
    typeName*: string

proc newObject*(typeName: string = "Object"): Object =
  new(result)
  result.typeName = typeName

method name*(self: Object): string {.base.} =
  if self.typeName.len > 0:
    return self.typeName
  else:
    return "Object"

method `$`*(self: Object): string {.base.} =
  return self.name()

# Check if self is of type T or subtype (runtime type check)
proc isA*[T: Object](self: Object, t: typedesc[T]): bool =
  if self == nil: return false
  return self of t

# Dynamic string name type check
method isTypeName*(self: Object, name: string): bool {.base.} =
  return self.name() == name
