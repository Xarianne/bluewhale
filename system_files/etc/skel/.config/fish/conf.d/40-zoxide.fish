if command -q zoxide
    abbr --add -- cd z
    zoxide init fish | source
end
