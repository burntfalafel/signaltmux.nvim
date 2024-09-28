# signaltmux.nvim

Ever have this problem of remotely triggering commands to a tmux session from your nvim?
Surely you would have faced with this problem if you use 2 or more screens. Otherwise you're a single-screen poor soydev, and this plugin has nothing to do with you.

Put `Plug burntfalafel/signaltmux` in your nvim config (or whatever plugin manager you're using)

Now run
`Telescope signaltmux interface`

You also need -
```
# Variable to hold the last command
export LAST_COMMAND=""

# Function to capture the last command
capture_last_command() {
    LAST_COMMAND="$1"
}

# Hook into the command execution
preexec() {
    capture_last_command "$1"
}
```
in your `~/.zshrc`. Or whatever shell you're using.

### Reason for more bloat in your shell init?

Ideally `zsh -c 'fc -ln -1'` should've done the trick, but I was getting this error - `zsh:fc:1: no such event: 0`. I think this is expected as tmux is running zsh inside it.

Also, history files and any commands referencing that file are useless. We want history PER tmux pane, not the global history captured by zsh.

### TODO:

- better documentation
- cleaner code
- Idk, a lot of stuff - this was done in 1 weekend copy-pasting and making sense of https://github.com/camgraff/telescope-tmux.nvim, as well as adding more error handling + more structured API

