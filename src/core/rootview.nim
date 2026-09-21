## rootview.nim - Root top-level view orchestration and node tree layout container
## Ports data/core/rootview.lua to Nim.

import view, node, doc, docview, common

type
  RootView* = ref object of View
    rootNode*: Node
    mouse*: Vec2

proc newRootView*(): RootView =
  let rv = RootView(
    typeName: "RootView",
    rootNode: newNode(ntLeaf),
    mouse: initVec2(0.0, 0.0)
  )
  return rv

proc openDoc*(self: RootView, doc: Doc): DocView =
  let activeNode = self.rootNode
  for v in activeNode.views:
    if v of DocView and DocView(v).doc == doc:
      activeNode.setActiveView(v)
      return DocView(v)

  let dv = newDocView(doc)
  activeNode.addView(dv)
  self.rootNode.updateLayout()
  return dv

method draw*(self: RootView) =
  if self.rootNode != nil:
    self.rootNode.updateLayout()

method update*(self: RootView): bool =
  self.rootNode.position = self.position
  self.rootNode.size = self.size
  self.rootNode.updateLayout()
  return self.rootNode.update()
