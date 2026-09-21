import std/[unittest, tables]
import ../src/core/[config, style, keymap, command, doc, docview, rootview, commandview]
import ../src/languages/[languages_c, languages_web_script, languages_other]
import ../src/themes/[themes_dark, themes_light]
import ../src/plugins/[plugins_nav, plugins_edit, plugins_ui]
import ../src/user/user

suite "Languages, Themes, Plugins, User Config Tests":
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

  test "Plugins initialization":
    var reg = initCommandRegistry()
    var km = initKeymap()
    let rv = newRootView()
    let tv = newTreeView()

    initNavigationPlugins(reg, km, rv, tv)
    check(reg.map.hasKey("treeview:toggle"))

    initEditingPlugins(reg, km, rv)
    check(reg.map.hasKey("trim-whitespace:trim"))

    initUIPlugins(reg, km)
    check(reg.map.hasKey("scale:increase"))

  test "User config initialization":
    var cfg = initConfig()
    var st = initStyle()
    var km = initKeymap()
    var reg = initCommandRegistry()

    initUserConfig(cfg, st, km, reg)
    check(km.getBinding("core:quit") == "ctrl+escape")
