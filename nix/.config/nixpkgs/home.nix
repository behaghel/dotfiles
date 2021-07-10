{ config, pkgs, ... }:

let
  # weechat-matrix broken in stable: can't find matrix_helper_sso
  # still broken in unstable but less so: it now wants me to identify
  # myself only through facebook/google/...
  # weechat-matrix = pkgs.python3Packages.callPackage <nixpkgs/pkgs/applications/networking/irc/weechat/scripts/weechat-matrix> {};
  weechat = pkgs.weechat.override { configure = { availablePlugins, ... }: {
    plugins = with availablePlugins; [
        # PodParser for Pod::Select.pm for menu.pl for spell suggestions
        (perl.withPackages (p: [ p.PodParser ]))
        # websocket_client for wee-slack and dbus-python for notifications
        (python.withPackages (ps: with ps; [ websocket_client dbus-python ]))
      ];
    scripts = [ pkgs.weechatScripts.weechat-matrix ];
    };
  };
in {
  nixpkgs.config = import ./config.nix;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "hub";
  home.homeDirectory = "/home/hub";

  # TODO: DRY
  # technically that should look like
  # home.file.".config".source = ../../../bash/.config;
  # home.file.".config".recursive = true;
  home.file.".gitconfig".source = ../../../bash/.gitconfig;
  home.file.".lesskey".source = ../../../bash/.lesskey;
  home.file.".ctags".source = ../../../bash/.ctags;
  home.file.".aliases".source = ../../../bash/.aliases;
  xdg.configFile."profile.d/hub.profile".source = ../../../bash/.config/profile.d/hub.profile;
  xdg.configFile."profile.d/zz_path.profile".source = ../../../bash/.config/profile.d/zz_path.profile;

  home.packages = with pkgs; [
    weechat
    # weechat deps
    aspell aspellDicts.en aspellDicts.fr
    emojione
    libnotify
    # other apps
    kitty
    firefox
  ];

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
    '';
  };
  xdg.configFile."zsh.d/gpg.zsh".source = ../../../zsh/.config/zsh.d/gpg.zsh;
  xdg.configFile."zsh.d/bepo.zsh".source = ../../../zsh/.config/zsh.d/bepo.zsh;

  # required for nix, nix.el, lorri, python…
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    # enableNixDirenvIntegration = true;
  };
  xdg.configFile."direnv".source = ../../../bash/.direnvrc;

  services.dropbox.enable = true;
  services.dunst.enable = true;

  # https://github.com/nix-community/lorri
  services.lorri.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
