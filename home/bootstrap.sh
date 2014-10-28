#!/usr/bin/env bash
cd $HOME

# install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# download & exec Brewfile
curl -O https://raw.githubusercontent.com/jzelenkov/dotfiles/master/home/Brewfile
brew bundle Brewfile

# install ruby with ruby-install
ruby-install ruby 2.1

# install homeshick (for managing dotfiles)
git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick

# install & link homeshick castles
$HOME/.homesick/repos/homeshick/homeshick.sh clone https://github.com/jzelenkov/dotfiles.git
$HOME/.homesick/repos/homeshick/homeshick.sh link dotfiles
$HOME/.homesick/repos/homeshick/homeshick.sh clone https://github.com/jzelenkov/vim-castle.git
$HOME/.homesick/repos/homeshick/homeshick.sh link vim-castle
$HOME/.homesick/repos/homeshick/homeshick.sh clone https://github.com/jzelenkov/subl-castle.git
$HOME/.homesick/repos/homeshick/homeshick.sh link subl-castle

# install homebrew cask
brew install caskroom/cask/brew-cask

brew cask install vlc
brew cask install google-chrome
brew cask install skype
brew cask install virtualbox
brew cask install vagrant
brew cask install tunnelblick
brew cask install appcleaner
brew cask install xld
brew cask install divvy
brew cask install spotify
brew cask install colloquy
brew cask install firefox
brew cask install adium
brew cask install nzbvortex
brew cask install omnifocus
brew cask install the-unarchiver
brew cask install iterm2
brew cask install caffeine
brew cask install kaleidoscope
brew cask install ichm
brew cask install seil
brew cask install clipmenu
