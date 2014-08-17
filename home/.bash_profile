# Mac OS X's Terminal.app runs a login shell by default for each new terminal
# window and tab, calling `.bash_profile` instead of `.bashrc`.
# `.bashrc` is never called in Mac's Terminal.app!

# Let's fix this for bash:
if [ -n "$BASH_VERSION" ]; then
    
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi

    # load bash_completions from brew
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi

fi
