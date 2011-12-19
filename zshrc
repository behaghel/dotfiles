# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set to the name theme to load.
# Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="hub"

# Set to this to use case-sensitive completion
# export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git github vi-mode osx brew)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

# BÉPO
bindkey -a c vi-backward-char
bindkey -a r vi-forward-char
bindkey -a t vi-down-line-or-history
bindkey -a s vi-up-line-or-history
bindkey -a $ vi-end-of-line
bindkey -a 0 vi-digit-or-beginning-of-line 
bindkey -a l vi-change
bindkey -a L vi-change-eol
bindkey -a dd vi-change-whole-line
bindkey -a j vi-replace-chars
bindkey -a J vi-replace
bindkey -a k vi-substitute

bindkey '\ee' edit-command-line

setopt nocorrectall
source ~/.profile
source ~/.aliases
