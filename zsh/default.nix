{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.zsh;
in {
  options.hub.zsh = {
    enable = mkOption {
      description = "Enable zsh";
      type = types.bool;
      default = true;
    };

  };

  config = mkIf (cfg.enable) {
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      enableCompletion = true;
      enableAutosuggestions = true;
      # oh-my-zsh = {
      #   enable = true;
      #   # theme = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k";
      #   # doesn't work => I source the theme in zshrc — see below
      # };
      plugins = [
        # update these in nix-shell -p nix-prefetch-github
        # $ nix-prefetch-github zsh-users zsh-syntax-highlighting
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            "rev" = "0e1bb14452e3fc66dcc81531212e1061e02c1a61";
            "sha256" = "13nzmkljmzkjh85phby2d8ni7x0fs0ggnii51vsbngkbqqzxs6zb";
            "fetchSubmodules" = true;
          };
        }
      ];

      # stolen: https://github.com/mjlbach/nix-dotfiles/blob/master/home-manager/modules/cli.nix
      initExtraBeforeCompInit = ''
        # Emacs tramp mode compatibility
        [[ $TERM == "tramp" ]] && unsetopt zle && PS1='$ ' && return
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
        # password-store completion broken
        fpath=(${pkgs.pass}/share/zsh/site-functions $fpath)
        source ~/.aliases
      '';
      initExtra = ''
        for i in ~/.config/profile.d/*.profile; do
          source $i
        done
        for i in ~/.config/zsh.d/*.zsh; do
          source $i
        done
        bindkey '^ ' autosuggest-accept
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=23'
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/config/p10k-lean.zsh
        # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        export -U PATH=~/.nix-profile/bin''${PATH:+:$PATH}
      '';
    };
    xdg.configFile."zsh.d/gpg.zsh".source = ./.config/zsh.d/gpg.zsh;
    xdg.configFile."zsh.d/bepo.zsh".source = ./.config/zsh.d/bepo.zsh;
  };
}
