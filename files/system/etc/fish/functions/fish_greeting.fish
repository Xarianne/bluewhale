function fish_greeting
    if status --is-interactive && type -q fastfetch
        fastfetch
    end
end
