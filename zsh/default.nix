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
      enableSyntaxHighlighting = true;
      # oh-my-zsh = {
      #   enable = true;
      #   # theme = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k";
      #   # doesn't work => I source the theme in zshrc — see below
      # };
      plugins = [
        # update these in nix-shell -p nix-prefetch-github
        # $ nix-prefetch-github zsh-users zsh-syntax-highlighting
        # {
        #   name = "zsh-syntax-highlighting";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "zsh-users";
        #     repo = "zsh-syntax-highlighting";
        #     "rev" = "0e1bb14452e3fc66dcc81531212e1061e02c1a61";
        #     "sha256" = "13nzmkljmzkjh85phby2d8ni7x0fs0ggnii51vsbngkbqqzxs6zb";
        #     "fetchSubmodules" = true;
        #   };
        # }
      ];

      # stolen: https://github.com/mjlbach/nix-dotfiles/blob/master/home-manager/modules/cli.nix
      initExtraBeforeCompInit = ''
        # Emacs tramp mode compatibility
        [[ $TERM == "tramp" ]] && unsetopt zle && PS1='$ ' && return
        # password-store completion broken
        fpath=(${pkgs.pass}/share/zsh/site-functions $fpath)
        source ~/.aliases
      '';
      initExtra = ''
        for i in ~/.config/profile.d/*.profile; do
          source $i
        done
        source ~/.aliases
        for i in ~/.config/zsh.d/*.zsh; do
          source $i
        done
        bindkey '^ ' autosuggest-accept
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=23'

        export -U PATH=~/.nix-profile/bin''${PATH:+:$PATH}
        eval "$(${pkgs.starship}/bin/starship init zsh)"
      '';
    };
    xdg.configFile."zsh.d/gpg.zsh".source = ./.config/zsh.d/gpg.zsh;
    xdg.configFile."zsh.d/bepo.zsh".source = ./.config/zsh.d/bepo.zsh;

    programs.direnv.enableZshIntegration = true;
  };
}
