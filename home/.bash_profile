# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.secrets can be used for other settings you don’t want to commit.
for file in ~/.{paths,exports,aliases,secrets,yp_aliases}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Enable console colors
export CLICOLOR=1
export TERM="xterm-256color"


# Sensible Bash
# Repository: https://github.com/mrzool/bash-sensible
[ -r "$HOME/.sensible.bash" ] && source "$HOME/.sensible.bash";


# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
	source "$(brew --prefix)/etc/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;


# Enable tools / utilities

# Enable homeshick
# source "$HOME/.homesick/repos/homeshick/homeshick.sh"

# Enable chruby
#source "/usr/local/opt/chruby/share/chruby/chruby.sh"
#source "/usr/local/opt/chruby/share/chruby/auto.sh"
# enable rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# enable nvm
source $(brew --prefix nvm)/nvm.sh


# Style bash promt
source ~/.bash_prompt
