## user.nim - User configuration module
## Ports data/user/init.lua to Nim.

import ../core/[config, style, keymap, command]

proc initUserConfig*(cfg: var Config, st: var Style, km: Keymap, reg: CommandRegistry) =
  # Custom keybindings and overrides
  km.addBinding("ctrl+escape", "core:quit")
