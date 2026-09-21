## languages_other.nim - Remaining language definitions
## Ports language_bat.lua, language_batch.lua, language_glsl.lua, language_hlsl.lua, language_md.lua, language_moon.lua, language_odin.lua, language_teal.lua, language_wren.lua.

import tables
import ../core/syntax

proc getMarkdownLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Markdown")
  def.files = @[r"\.md$", r"\.markdown$"]
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "normal"))
  return def

proc getGlslLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("GLSL")
  def.files = @[r"\.glsl$", r"\.vert$", r"\.frag$", r"\.geom$", r"\.comp$"]
  def.commentSymbol = "//"
  def.patterns.add(SyntaxPattern(pattern: @[r"//"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))
  def.symbols["attribute"] = "keyword"
  def.symbols["varying"] = "keyword"
  def.symbols["uniform"] = "keyword"
  def.symbols["vec2"] = "keyword2"
  def.symbols["vec3"] = "keyword2"
  def.symbols["vec4"] = "keyword2"
  def.symbols["mat4"] = "keyword2"
  def.symbols["void"] = "keyword2"
  return def

proc getHlslLanguageDef*(): SyntaxDef =
  let def = getGlslLanguageDef()
  def.name = "HLSL"
  def.files = @[r"\.hlsl$", r"\.fx$"]
  def.symbols["cbuffer"] = "keyword"
  def.symbols["float4"] = "keyword2"
  def.symbols["float3"] = "keyword2"
  def.symbols["float2"] = "keyword2"
  return def

proc getOdinLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Odin")
  def.files = @[r"\.odin$"]
  def.commentSymbol = "//"
  def.patterns.add(SyntaxPattern(pattern: @[r"//"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))
  def.symbols["proc"] = "keyword"
  def.symbols["struct"] = "keyword"
  def.symbols["enum"] = "keyword"
  def.symbols["package"] = "keyword"
  def.symbols["import"] = "keyword"
  def.symbols["int"] = "keyword2"
  def.symbols["string"] = "keyword2"
  def.symbols["bool"] = "keyword2"
  return def

proc getTealLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Teal")
  def.files = @[r"\.tl$"]
  def.commentSymbol = "--"
  def.patterns.add(SyntaxPattern(pattern: @[r"--"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))
  def.symbols["global"] = "keyword"
  def.symbols["local"] = "keyword"
  def.symbols["record"] = "keyword"
  def.symbols["enum"] = "keyword"
  def.symbols["function"] = "keyword"
  return def

proc getWrenLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Wren")
  def.files = @[r"\.wren$"]
  def.commentSymbol = "//"
  def.patterns.add(SyntaxPattern(pattern: @[r"//"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))
  def.symbols["class"] = "keyword"
  def.symbols["construct"] = "keyword"
  def.symbols["static"] = "keyword"
  def.symbols["import"] = "keyword"
  def.symbols["var"] = "keyword"
  return def

proc getMoonLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("MoonScript")
  def.files = @[r"\.moon$"]
  def.commentSymbol = "--"
  def.patterns.add(SyntaxPattern(pattern: @[r"--"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[0-9]+"], tokenType: "number"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))
  def.symbols["class"] = "keyword"
  def.symbols["extends"] = "keyword"
  def.symbols["export"] = "keyword"
  def.symbols["local"] = "keyword"
  return def

proc getBatchLanguageDef*(): SyntaxDef =
  let def = newSyntaxDef("Batch")
  def.files = @[r"\.bat$", r"\.cmd$"]
  def.commentSymbol = "REM"
  def.patterns.add(SyntaxPattern(pattern: @[r"REM"], tokenType: "comment"))
  def.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))
  def.symbols["echo"] = "keyword"
  def.symbols["set"] = "keyword"
  def.symbols["if"] = "keyword"
  def.symbols["goto"] = "keyword"
  def.symbols["call"] = "keyword"
  return def
