## objects.nim - Base Object hierarchy
type Object* = ref object of RootObj
  typeName*: string

proc newObject*(typeName: string = "Object"): Object =
  new(result)
  result.typeName = typeName

method name*(self: Object): string {.base.} =
  if self.typeName.len > 0: self.typeName else: "Object"

method `$`*(self: Object): string {.base.} = self.name()

proc isA*[T: Object](self: Object, t: typedesc[T]): bool =
  if self == nil: return false
  return self of t

method isTypeName*(self: Object, name: string): bool {.base.} = self.name() == name
