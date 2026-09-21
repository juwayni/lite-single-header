import std/[unittest, tables]
import ../src/core/syntax
import ../src/core/tokenizer

suite "Tokenizer Module Tests":
  test "Tokenize plain text":
    let plainSyn = newSyntaxDef("Plain")
    let (tokens, state) = plainSyn.tokenize("hello world")
    check(tokens.len == 1)
    check(tokens[0].tokenType == "normal")
    check(tokens[0].text == "hello world")
    check(state == 0)

  test "Tokenize with keywords and symbols":
    let syn = newSyntaxDef("MiniLang")
    syn.patterns.add(SyntaxPattern(pattern: @[r"[_a-zA-Z0-9]+"], tokenType: "symbol"))
    syn.symbols["fn"] = "keyword"

    let (tokens, _) = syn.tokenize("fn foo")
    check(tokens.len == 2)
    check(tokens[0].tokenType == "keyword")
    check(tokens[0].text == "fn")
    check(tokens[1].tokenType == "symbol")
    check(tokens[1].text == " foo")

  test "Stateful pair matching (strings/comments)":
    let syn = newSyntaxDef("CommentLang")
    syn.patterns.add(SyntaxPattern(pattern: @["\"", "\"", "\\"], tokenType: "string"))

    let (tokens1, state1) = syn.tokenize("\"unclosed string", 0)
    check(state1 == 1)
    check(tokens1[0].tokenType == "string")

    let (tokens2, state2) = syn.tokenize("continue\"", state1)
    check(state2 == 0)
    check(tokens2[0].tokenType == "string")
