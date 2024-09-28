local tutils = require('telescope.utils')

local tmux_commands = {}

-- Include the session name since the window may be linked to multiple sessions
-- This format makes the window location unambiguous
tmux_commands.window_id_fmt = "#{session_name}:#{window_id}"
tmux_commands.session_id_fmt = "#{session_id}"
tmux_commands.session_name_fmt = "#S"

tmux_commands.list_windows = function(opts)
  local cmd = {'tmux', 'list-windows', '-a'}
  if opts.format ~= nil then
    table.insert(cmd, "-F")
    table.insert(cmd, opts.format)
  end
  if opts.window ~= nil then
    table.insert(cmd, "-t")
    table.insert(cmd, opts.window)
  end
  return tutils.get_os_command_output(cmd)
end

tmux_commands.list_sessions = function(opts)
 local cmd = {'tmux', 'list-sessions'}
 if opts.format ~= nil then
   table.insert(cmd, "-F")
   table.insert(cmd, opts.format)
 end
 return tutils.get_os_command_output(cmd)
end

tmux_commands.send_previous_command = function(opts)
  local command_output, ret, stderr = tutils.get_os_command_output({
    'zsh', '-c', 'echo $LAST_COMMAND'
  })

  if ret ~= 0 then
    error("Error fetching previous command: " .. table.concat(stderr, "\n"))
    return
  end

  -- Strip any trailing newlines or spaces
  local last_command = command_output[1]:gsub("%s+$", "")

  local tmux_command = string.format("tmux send-keys -t %s:%s.%s '%s' C-m",
  opts.session, opts.window, opts.pane, last_command)

  return tutils.get_os_command_output({'zsh', '-c', tmux_command})
end

return tmux_commands
