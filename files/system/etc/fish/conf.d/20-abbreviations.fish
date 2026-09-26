# Abbreviations & aliases (one-liner `abbr`s merged from the old conf.d files).
# `command -q` guards make each a no-op when the tool isn't installed.

if command -q bat
    abbr --add -- cat bat
end

if command -q eza
    alias la 'eza -la --icons --git --group-directories-first'
    alias ll 'eza -lh --icons --grid --group-directories-first'
    alias lla 'eza -la'
    alias ls 'eza --icons --group-directories-first'
    alias lt 'eza --tree --level=2 --icons'
end

if command -q fd
    abbr --add -- find fd
end

if command -q trash-put
    abbr --add -- rm trash-put
end

alias metapac-unmanaged 'metapac unmanaged > $HOME/.config/metapac/groups/unmanaged.toml'



abbr --add -- opencode-status 'systemctl --user status opencode-server'

# Register !! abbreviation to expand to the previous command with sudo.
abbr -a '!!' --position anywhere --function __fish_expand_last_command
