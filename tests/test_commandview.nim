import std/unittest
import ../src/core/commandview

suite "CommandView Module Tests":
  test "CommandView enter and text manipulation":
    let cv = newCommandView()
    check(cv.label == "")

    cv.enter("Find Command", proc(text: string, sug: SuggestionItem) = discard)
    check(cv.label == "Find Command: ")

    cv.setText("core:open")
    check(cv.getText() == "core:open")

  test "Suggestions and navigation":
    let cv = newCommandView()
    let suggestFn = proc(text: string): seq[SuggestionItem] =
      return @[
        SuggestionItem(text: "core:find-file", info: "Ctrl+P"),
        SuggestionItem(text: "core:find-command", info: "Ctrl+Shift+P")
      ]

    cv.enter("Find", nil, suggestFn)
    check(cv.suggestions.len == 2)
    check(cv.suggestionIdx == 1)

    cv.moveSuggestionIdx(1)
    check(cv.suggestionIdx == 2)
    check(cv.getText() == "core:find-command")

  test "Command submit callback":
    let cv = newCommandView()
    var submittedText = ""

    cv.enter("Prompt", proc(text: string, sug: SuggestionItem) =
      submittedText = text
    )

    cv.setText("hello world")
    cv.submit()

    check(submittedText == "hello world")
    check(cv.label == "")
