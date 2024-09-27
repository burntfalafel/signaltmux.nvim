local telescope = require('telescope')

local interface = require('telescope._extensions.tmux_interface')
local M = {}
M.setup = function(opts)
    print("hi")
end
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
