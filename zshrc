source ~/etc/*.zsh

if [[ -d $HOME/.oh-my-zsh ]]; then
  export ZSH=$HOME/.oh-my-zsh;

  # Set to the name theme to load.
  # Look in ~/.oh-my-zsh/themes/
  export ZSH_THEME="hub";

  # Comment this out to disable weekly auto-update checks
  # export DISABLE_AUTO_UPDATE="true"

  # Uncomment following line if you want to disable colors in ls
  # export DISABLE_LS_COLORS="true"

  # Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
  # Example format: plugins=(rails git textmate ruby lighthouse)
  plugins=(git github vi-mode mvn);

  source $ZSH/oh-my-zsh.sh;
fi

# Customize to your needs...
fpath=(~/.zsh/completion $fpath)
source ~/.profile
source ~/.aliases

# BÉPO
bindkey -a é vi-forward-word
bindkey -a É vi-forward-blank-word
bindkey -a c vi-backward-char
bindkey -a c vi-backward-char
bindkey -a c vi-backward-char
bindkey -a r vi-forward-char
bindkey -a t vi-down-line-or-history
bindkey -a s vi-up-line-or-history
bindkey -a $ vi-end-of-line
bindkey -a 0 vi-digit-or-beginning-of-line 
bindkey -a l vi-change
bindkey -a L vi-change-eol
bindkey -a h vi-find-next-char-skip
bindkey -a H vi-find-prev-char-skip
bindkey -a j vi-replace-chars
bindkey -a k vi-substitute
bindkey -a K vi-change-whole-line
bindkey -a dd vi-change-whole-line

bindkey -a v edit-command-line

setopt nocorrectall

