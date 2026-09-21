## node.nim - Split layout node
import std/math
import objects, common, view

type
  NodeType* = enum ntLeaf, ntHSplit, ntVSplit

  Node* = ref object of Object
    nodeType*: NodeType
    position*: Vec2
    size*: Vec2
    views*: seq[View]
    activeView*: View
    divider*: float
    locked*: bool
    childA*, childB*: Node

proc newNode*(nodeType: NodeType = ntLeaf): Node =
  let n = Node(typeName: "Node", nodeType: nodeType, position: initVec2(0, 0), size: initVec2(0, 0), views: @[], activeView: nil, divider: 0.5, locked: false)
  if nodeType == ntLeaf:
    let emptyV = newView("EmptyView")
    n.views.add(emptyV)
    n.activeView = emptyV
  return n

proc addView*(self: Node, view: View) =
  if self.nodeType == ntLeaf and not self.locked:
    if self.views.len == 1 and self.views[0].typeName == "EmptyView": self.views = @[]
    self.views.add(view)
    self.activeView = view

proc setActiveView*(self: Node, view: View) =
  if self.nodeType == ntLeaf: self.activeView = view

proc split*(self: Node, dir: string, view: View = nil, locked: bool = false): Node =
  let splitType = if dir in ["up", "down"]: ntVSplit else: ntHSplit
  let oldA = newNode(self.nodeType)
  oldA.views = self.views; oldA.activeView = self.activeView; oldA.divider = self.divider
  let newB = newNode(ntLeaf)
  if view != nil: newB.addView(view)
  newB.locked = locked
  self.nodeType = splitType; self.views = @[]; self.activeView = nil
  if dir in ["up", "left"]: self.childA = newB; self.childB = oldA
  else: self.childA = oldA; self.childB = newB
  return newB

proc updateLayout*(self: Node) =
  if self.nodeType == ntLeaf:
    if self.activeView != nil:
      self.activeView.position = self.position
      self.activeView.size = self.size
  else:
    if self.nodeType == ntHSplit:
      let splitX = floor(self.size.x * self.divider)
      if self.childA != nil:
        self.childA.position = self.position; self.childA.size = initVec2(splitX, self.size.y); self.childA.updateLayout()
      if self.childB != nil:
        self.childB.position = initVec2(self.position.x + splitX, self.position.y); self.childB.size = initVec2(self.size.x - splitX, self.size.y); self.childB.updateLayout()

method update*(self: Node): bool {.base.} =
  var changed = false
  if self.nodeType == ntLeaf:
    for v in self.views:
      if v.update(): changed = true
  else:
    if self.childA != nil and self.childA.update(): changed = true
    if self.childB != nil and self.childB.update(): changed = true
  return changed
