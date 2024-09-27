local tmux_cmds = require 'tmux_commands'
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local get_panes = function(opts)
  local session_ids = tmux_cmds.list_sessions{format = tmux_cmds.session_id_fmt}
  local user_formatted_session_names = tmux_cmds.list_sessions{format = opts.entry_format or tmux_cmds.session_name_fmt}
  local formatted_to_real_session_map = {}
  for i, v in ipairs(user_formatted_session_names) do
    formatted_to_real_session_map[v] = session_ids[i]
  end

  -- local pane_ids = tmux_cmds.list_panes(
  pickers.new(opts, {
    prompt_title = "Tmux windows",
    finder = finders.new_table {
      results = formatted_to_real_session_map
    },
    sorter = conf.generic_sorter(opts)
  }).find()

end

return get_panes
