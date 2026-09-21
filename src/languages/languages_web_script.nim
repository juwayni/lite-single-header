## languages_web_script.nim - Web and Scripting syntax definitions
## Ports language_js.lua, language_ts.lua, language_css.lua, language_xml.lua, language_python.lua, language_lua.lua, language_nim.lua.

import tables
import ../core/syntax

proc getNimLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Nim")
  def.files = @[r"\.nim$", r"\.nims$", r"\.nimble$"]
  def.commentSymbol = "#"

  def.patterns.add(SyntaxPattern(pattern: @[r"#"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @["'", "'", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"0x[0-9a-fA-F]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))

  def.symbols["proc"] = "keyword"
  def.symbols["func"] = "keyword"
  def.symbols["type"] = "keyword"
  def.symbols["let"] = "keyword"
  def.symbols["var"] = "keyword"
  def.symbols["const"] = "keyword"
  def.symbols["import"] = "keyword"
  def.symbols["export"] = "keyword"
  def.symbols["return"] = "keyword"
  def.symbols["if"] = "keyword"
  def.symbols["elif"] = "keyword"
  def.symbols["else"] = "keyword"
  def.symbols["while"] = "keyword"
  def.symbols["for"] = "keyword"
  def.symbols["discard"] = "keyword"
  def.symbols["nil"] = "literal"
  def.symbols["true"] = "literal"
  def.symbols["false"] = "literal"

  return def

proc getLuaLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Lua")
  def.files = @[r"\.lua$"]
  def.commentSymbol = "--"

  def.patterns.add(SyntaxPattern(pattern: @[r"--"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @["'", "'", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))

  def.symbols["function"] = "keyword"
  def.symbols["local"] = "keyword"
  def.symbols["return"] = "keyword"
  def.symbols["if"] = "keyword"
  def.symbols["then"] = "keyword"
  def.symbols["else"] = "keyword"
  def.symbols["elseif"] = "keyword"
  def.symbols["end"] = "keyword"
  def.symbols["while"] = "keyword"
  def.symbols["for"] = "keyword"
  def.symbols["do"] = "keyword"
  def.symbols["nil"] = "literal"
  def.symbols["true"] = "literal"
  def.symbols["false"] = "literal"

  return def

proc getPythonLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Python")
  def.files = @[r"\.py$", r"\.pyw$"]
  def.headers = @[r"^#!.*python"]
  def.commentSymbol = "#"

  def.patterns.add(SyntaxPattern(pattern: @[r"#"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @["'", "'", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))

  def.symbols["def"] = "keyword"
  def.symbols["class"] = "keyword"
  def.symbols["return"] = "keyword"
  def.symbols["if"] = "keyword"
  def.symbols["elif"] = "keyword"
  def.symbols["else"] = "keyword"
  def.symbols["while"] = "keyword"
  def.symbols["for"] = "keyword"
  def.symbols["import"] = "keyword"
  def.symbols["from"] = "keyword"
  def.symbols["None"] = "literal"
  def.symbols["True"] = "literal"
  def.symbols["False"] = "literal"

  return def

proc getJsLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("JavaScript")
  def.files = @[r"\.js$", r"\.jsx$", r"\.mjs$"]
  def.commentSymbol = "//"

  def.patterns.add(SyntaxPattern(pattern: @[r"//"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @["'", "'", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))

  def.symbols["function"] = "keyword"
  def.symbols["const"] = "keyword"
  def.symbols["let"] = "keyword"
  def.symbols["var"] = "keyword"
  def.symbols["return"] = "keyword"
  def.symbols["if"] = "keyword"
  def.symbols["else"] = "keyword"
  def.symbols["for"] = "keyword"
  def.symbols["while"] = "keyword"
  def.symbols["null"] = "literal"
  def.symbols["undefined"] = "literal"
  def.symbols["true"] = "literal"
  def.symbols["false"] = "literal"

  return def

proc getTsLanguageDef*(): SyntaxDef =
  let def = getJsLanguageDef()
  def.name = "TypeScript"
  def.files = @[r"\.ts$", r"\.tsx$"]
  def.symbols["interface"] = "keyword"
  def.symbols["type"] = "keyword"
  def.symbols["implements"] = "keyword"
  def.symbols["namespace"] = "keyword"
  def.symbols["enum"] = "keyword"
  return def

proc getCssLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("CSS")
  def.files = @[r"\.css$"]
  def.commentSymbol = "/*"

  def.patterns.add(SyntaxPattern(pattern: @[r"/\*", r"\*/"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @["'", "'", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"#[0-9a-fA-F]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))

  return def

proc getXmlLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("XML")
  def.files = @[r"\.xml$", r"\.html$", r"\.htm$", r"\.svg$"]
  def.commentSymbol = "<!--"

  def.patterns.add(SyntaxPattern(pattern: @[r"<!--", r"-->"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @["'", "'", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))

  return def
