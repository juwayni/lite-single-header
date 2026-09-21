## tokenizer.nim - Stateful syntax tokenizer
## Ports data/core/tokenizer.lua to Nim with improved performance, token structures, and iterator support.

import tables, strutils, syntax, common

type
  Token* = object
    tokenType*: string
    text*: string

proc pushToken*(tokens: var seq[Token], tokenType: string, text: string) =
  if text.len == 0: return
  if tokens.len > 0:
    let lastIndex = tokens.len - 1
    if tokens[lastIndex].tokenType == tokenType or tokens[lastIndex].text.strip().len == 0:
      tokens[lastIndex].tokenType = tokenType
      tokens[lastIndex].text &= text
      return
  tokens.add(Token(tokenType: tokenType, text: text))

proc isEscaped*(text: string, idx: int, esc: char): bool =
  if idx <= 0 or esc == '\0': return false
  var count = 0
  var i = idx - 1
  while i >= 0:
    if text[i] != esc: break
    inc count
    dec i
  return count mod 2 == 1

proc findNonEscaped*(text, ptn: string, offset: int, esc: char = '\0'): (int, int) =
  var curOffset = offset
  while curOffset < text.len:
    let sub = text[curOffset..^1]
    let (s, e) = matchPattern(sub, ptn)
    if s < 0: break
    let absS = curOffset + s
    let absE = curOffset + e
    if esc != '\0' and isEscaped(text, absS, esc):
      curOffset = absE + 1
    else:
      return (absS, absE)
  return (-1, -1)

proc tokenize*(syn: SyntaxDef, text: string, state: int = 0): (seq[Token], int) =
  var tokens: seq[Token] = @[]
  var currentState = state
  var i = 0

  if syn == nil or syn.patterns.len == 0:
    return (@[Token(tokenType: "normal", text: text)], 0)

  while i < text.len:
    if currentState > 0 and currentState <= syn.patterns.len:
      let p = syn.patterns[currentState - 1]
      let endPtn = if p.pattern.len >= 2: p.pattern[1] else: ""
      let escChar = if p.pattern.len >= 3 and p.pattern[2].len > 0: p.pattern[2][0] else: '\0'

      let (s, e) = findNonEscaped(text, endPtn, i, escChar)
      if s >= 0 and s < text.len:
        tokens.pushToken(p.tokenType, text[i..e])
        currentState = 0
        i = e + 1
      else:
        tokens.pushToken(p.tokenType, text[i..^1])
        break

    if i >= text.len: break

    var matched = false
    for n, p in syn.patterns:
      let startPtn = if p.pattern.len >= 1: p.pattern[0] else: ""
      let sub = text[i..^1]
      let (s, e) = matchPattern(sub, startPtn)
      if s == 0: # Start anchored match
        let absE = min(i + e, text.len - 1)
        let tokText = text[i..absE]
        let resolvedType = syn.symbols.getOrDefault(tokText, p.tokenType)
        tokens.pushToken(resolvedType, tokText)

        if p.pattern.len >= 2:
          currentState = n + 1

        i = absE + 1
        matched = true
        break

    if not matched and i < text.len:
      tokens.pushToken("normal", text[i..i])
      inc i

  return (tokens, currentState)

iterator eachToken*(tokens: seq[Token]): (int, Token) =
  for idx, tok in tokens:
    yield (idx, tok)
