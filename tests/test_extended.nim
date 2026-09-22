import std/[unittest, tables]
import ../src/core/[config, style, keymap, command, doc, docview, rootview, commandview, common]
import ../src/languages/[languages_c, languages_web_script, languages_other]
import ../src/themes/[themes_dark, themes_light]
import ../src/plugins/[plugins_nav, plugins_edit, plugins_ui]
import ../src/user/user

suite "Languages, Themes, Plugins, User Config Tests":
  test "Clipboard and Cut/Copy/Paste operations":
    let d = newDoc()
    d.insert(1, 1, "hello world")
    d.setSelection(1, 1, 1, 6)
    check(d.getSelectedText() == "hello")

    d.copySelectionToClipboard()
    check(getClipboardText() == "hello")

    d.cutSelectionToClipboard()
    check(d.getText(1, 1, 1, 10) == " world")

    d.pasteFromClipboard()
    check(d.getText(1, 1, 1, 12) == "hello world")

  test "Language definitions":
    let cDef = getCLanguageDef()
    check(cDef.name == "C")

    let nimDef = getNimLanguageDef()
    check(nimDef.name == "Nim")

    let mdDef = getMarkdownLanguageDef()
    check(mdDef.name == "Markdown")

  test "Themes definitions":
    let monokai = getMonokaiTheme()
    check(monokai.background.r > 0)

    let solarized = getSolarizedLightTheme()
    check(solarized.background.r > 0)

  test "Plugins initialization and commands":
    var reg = initCommandRegistry()
    var km = initKeymap()
    let rv = newRootView()
    let tv = newTreeView()
    let conV = newConsoleView()

    initNavigationPlugins(reg, km, rv, tv)
    check(reg.map.hasKey("treeview:toggle"))
    check(reg.map.hasKey("project-search:find"))
    check(reg.map.hasKey("workspace:save"))

    initEditingPlugins(reg, km, rv)
    check(reg.map.hasKey("trim-whitespace:trim"))
    check(reg.map.hasKey("tabularize:align"))

    initUIPlugins(reg, km, rv, conV)
    check(reg.map.hasKey("console:toggle"))
    check(reg.map.hasKey("macro:record"))

  test "User config initialization":
    var cfg = initConfig()
    var st = initStyle()
    var km = initKeymap()
    var reg = initCommandRegistry()

    initUserConfig(cfg, st, km, reg)
    check(km.getBinding("core:quit") == "ctrl+escape")
