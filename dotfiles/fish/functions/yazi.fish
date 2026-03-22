function yazi
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    # Notice the word 'command' added to the line below!
    command yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
