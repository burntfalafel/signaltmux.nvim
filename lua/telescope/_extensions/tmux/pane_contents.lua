-- Copied from https://github.com/camgraff/telescope-tmux.nvim/blob/master/lua/telescope/_extensions/tmux/pane_contents.lua
local utils = require('telescope.utils')

local pane_contents = {}

local ns_id = vim.api.nvim_create_namespace('telescope-tmux.previewers')

local function is_buf_empty(bufid)
    local line_count = vim.api.nvim_buf_line_count(bufid)
    local first_line = vim.api.nvim_buf_get_lines(bufid, 0, 1, false)[1]
    return line_count == 1 and first_line == ''
end
pane_contents.define_preview = function(entry, winid, bufid, num_history_lines)
    local pane = entry.value.pane
    vim.api.nvim_win_set_buf(winid, bufid)

    if is_buf_empty(bufid) then
        -- TODO: can we avoid this call and reuse the original capture-pane output?
        local pane_content = utils.get_os_command_output({'tmux', 'capture-pane', '-p', '-t', pane, '-S', -num_history_lines})
        --local pane_content = {"one pane", "two pane", "three pane"}
        vim.api.nvim_win_set_option(winid, "number", false)
        vim.api.nvim_win_set_option(winid, "relativenumber", false)
        vim.api.nvim_win_set_option(winid, "wrap", false)

        -- TODO: check for nvim-terminal.lua and only include term escape codes if plugin is present
        vim.api.nvim_buf_set_option(bufid, "filetype", "terminal")
        vim.api.nvim_buf_set_lines(bufid, 0, -1, false, pane_content)
    end

    vim.api.nvim_buf_clear_namespace(bufid, ns_id, 0, -1)
end

pane_contents.list_panes = function()
  local raw_panes = utils.get_os_command_output({'tmux', 'list-panes', '-a', '-F', '#{pane_id}\t#{session_name}\t#{window_index}'})

  local panes = {}
  for _, pane in ipairs(raw_panes) do
    -- Split the output by tab characters
    local it = string.gmatch(pane, "[^\t]+") -- Use + to match one or more characters

    -- Extract the pane_id, session_name, and window_index
    local id = it()      -- pane_id
    local session = it() -- session_name
    local window = it()  -- window_index (last part)

    -- Check if the variables were extracted correctly
    if id and session and window then
      -- Store the extracted values in the panes table
      table.insert(panes, {id = id, session = session, window = window})
    else
      -- Print error message for debugging
      print("Error: Could not extract values from pane: " .. pane)
    end
  end
  return panes
end

pane_contents.get_current_pane_id = function()
    return utils.get_os_command_output({'tmux', 'display-message', '-p', '#{pane_id}'})[1]
end

return pane_contents
