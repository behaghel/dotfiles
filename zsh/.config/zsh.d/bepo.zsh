# Customize to your needs...
#fpath=(~/.zsh/completion $fpath)
fpath=(/usr/local/share/zsh-completions $fpath)
fpath=(/usr/local/share/zsh/site-functions $fpath)

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

autoload edit-command-line; zle -N edit-command-line
bindkey -a v edit-command-line
bindkey '^R' history-incremental-search-backward
