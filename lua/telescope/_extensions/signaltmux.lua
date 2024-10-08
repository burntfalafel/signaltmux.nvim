local telescope = require('telescope')

local interface = require'telescope._extensions.tmux.tmux_interface'
--[[
The idea is:
lua require("signaltmux").signal(pane, command)
has to be cached
--]]

return telescope.register_extension {
  exports = {
    interface = interface
  }
}
