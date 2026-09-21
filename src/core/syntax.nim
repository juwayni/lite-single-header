## syntax.nim - Language syntax highlighting rules
import tables, common

type
  SyntaxPattern* = object
    pattern*: seq[string]
    tokenType*: string

  SyntaxDef* = ref object
    name*: string
    files*: seq[string]
    headers*: seq[string]
    patterns*: seq[SyntaxPattern]
    symbols*: Table[string, string]
    commentSymbol*: string

proc newSyntaxDef*(name: string = "Plain Text"): SyntaxDef =
  SyntaxDef(name: name, files: @[], headers: @[], patterns: @[], symbols: initTable[string, string](), commentSymbol: "")

type
  SyntaxRegistry* = object
    items*: seq[SyntaxDef]
    plainText*: SyntaxDef

proc initSyntaxRegistry*(): SyntaxRegistry =
  result.items = @[]
  result.plainText = newSyntaxDef("Plain Text")

proc addDef*(reg: var SyntaxRegistry, def: SyntaxDef) = reg.items.add(def)

proc findMatching*(reg: SyntaxRegistry, target: string, useHeaders: bool): SyntaxDef =
  if target.len == 0: return nil
  for i in countdown(reg.items.len - 1, 0):
    let def = reg.items[i]
    let patterns = if useHeaders: def.headers else: def.files
    let (s, _) = matchPatterns(target, patterns)
    if s >= 0: return def
  return nil

proc getSyntax*(reg: SyntaxRegistry, filename: string, header: string = ""): SyntaxDef =
  let byFile = reg.findMatching(filename, false)
  if byFile != nil: return byFile
  let byHeader = reg.findMatching(header, true)
  if byHeader != nil: return byHeader
  return reg.plainText

var globalSyntaxRegistry* = initSyntaxRegistry()
