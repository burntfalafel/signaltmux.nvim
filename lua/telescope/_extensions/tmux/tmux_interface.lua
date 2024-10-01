local tmux_cmds = require'telescope._extensions.tmux.tmux_commands'
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local utils = require('telescope.utils')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local pane_contents = require'telescope._extensions.tmux.pane_contents'

local get_panes = function(opts)
  local session_ids = tmux_cmds.list_sessions{format = tmux_cmds.session_id_fmt}
  local user_formatted_session_names = tmux_cmds.list_sessions{format = opts.entry_format or tmux_cmds.session_name_fmt}
  local formatted_to_real_session_map = {}
  for i, v in ipairs(user_formatted_session_names) do
    formatted_to_real_session_map[v] = session_ids[i]
  end
  local panes = pane_contents.list_panes()
  local current_pane = pane_contents.get_current_pane_id()
  local num_history_lines = opts.max_history_lines or 10000
  local results = {}
  for _, pane in ipairs(panes) do
    local pane_id = pane.id
    local session = pane.session
    local window = pane.window
    table.insert(results, {pane=pane_id, session=session, window=window})
  end

  -- local pane_ids = tmux_cmds.list_panes(
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Tmux windows",
    finder = finders.new_table {
      results = results,
      entry_maker = function(result)
        return {
          value = {
            pane = result.pane,
            window = result.window,
            session = result.session
          },
          -- TODO: make the display prefix prettier
          display = result.session .. ":" .. result.window .. "." .. result.pane,
          ordinal = result.pane,
          valid = result.pane
        }
      end
    },
    sorter = conf.generic_sorter(opts),
    -- would prefer to use this when https://github.com/neovim/neovim/issues/14557 is fixed.
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry, status)
        pane_contents.define_preview(entry, self.state.winid, self.state.bufnr, num_history_lines)
      end,
      get_buffer_by_name = function (self, entry)
        return entry.value.pane
      end
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        local pane = selection.value.pane
        local window = selection.value.window
        local session = selection.value.session
        actions.close(prompt_bufnr)
        tmux_cmds.send_previous_command({session = session, window = window, pane = pane})
      end)

      return true
    end
  }):find()
end

return get_panes
