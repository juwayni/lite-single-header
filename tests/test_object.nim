import std/unittest
import ../src/core/objects

type
  CustomView = ref object of Object
    title: string

  SubView = ref object of CustomView
    id: int

suite "Object Module Tests":
  test "Base Object creation and string representation":
    let obj = newObject("BaseObj")
    check(obj.name() == "BaseObj")
    check($obj == "BaseObj")

  test "Object inheritance and type checking":
    let v = CustomView(typeName: "CustomView", title: "Document")
    let sv = SubView(typeName: "SubView", title: "SubDocument", id: 42)

    check(v.isA(Object))
    check(v.isA(CustomView))
    check(not v.isA(SubView))

    check(sv.isA(Object))
    check(sv.isA(CustomView))
    check(sv.isA(SubView))

    check(v.isTypeName("CustomView"))
    check(sv.isTypeName("SubView"))
