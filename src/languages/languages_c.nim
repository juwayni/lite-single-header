## languages_c.nim - C, C++, and C# language syntax definitions
## Ports data/languages/language_c.lua, language_cpp.lua, and language_csharp.lua to Nim.

import tables
import ../core/syntax

proc getCLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("C")
  def.files = @[r"\.c$", r"\.h$", r"\.inl$", r"\.cpp$", r"\.hpp$"]
  def.commentSymbol = "//"

  def.patterns.add(SyntaxPattern(pattern: @[r"//"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @[r"/\*", r"\*/"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @["'", "'", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"0x[0-9a-fA-F]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))

  def.symbols["if"] = "keyword"
  def.symbols["else"] = "keyword"
  def.symbols["while"] = "keyword"
  def.symbols["for"] = "keyword"
  def.symbols["return"] = "keyword"
  def.symbols["struct"] = "keyword"
  def.symbols["typedef"] = "keyword"
  def.symbols["enum"] = "keyword"
  def.symbols["void"] = "keyword2"
  def.symbols["int"] = "keyword2"
  def.symbols["char"] = "keyword2"
  def.symbols["float"] = "keyword2"
  def.symbols["double"] = "keyword2"
  def.symbols["NULL"] = "literal"
  def.symbols["true"] = "literal"
  def.symbols["false"] = "literal"

  return def

proc getCppLanguageDef*(): SyntaxDef =
  let def = getCLanguageDef()
  def.name = "C++"
  def.symbols["class"] = "keyword"
  def.symbols["public"] = "keyword"
  def.symbols["private"] = "keyword"
  def.symbols["protected"] = "keyword"
  def.symbols["template"] = "keyword"
  def.symbols["typename"] = "keyword"
  def.symbols["namespace"] = "keyword"
  def.symbols["using"] = "keyword"
  def.symbols["nullptr"] = "literal"
  return def

proc getCSharpLanguageDef*(): SyntaxDef =
  let def = getCppLanguageDef()
  def.name = "C#"
  def.files = @[r"\.cs$"]
  def.symbols["using"] = "keyword"
  def.symbols["namespace"] = "keyword"
  def.symbols["interface"] = "keyword"
  def.symbols["override"] = "keyword"
  def.symbols["async"] = "keyword"
  def.symbols["await"] = "keyword"
  def.symbols["null"] = "literal"
  return def
