{ config, pkgs, ... }:

{
  imports = [
    ../../../bash
    ../../../zsh
    ../../../git
    ../../../pass
    ../../../mail
    ../../../weechat
    ../../../nix
    ../../../X
    ../../../kitty
    ../../../alacritty
    ../../../emacs
    # ../../../tex
    ../../../firefox
  ];

  config = {
    nixpkgs.config = import ./config.nix;
    home = {
      username = "hubertbehaghel";
      homeDirectory = "/home/hubertbehaghel";
      stateVersion = "22.05";
      packages = with pkgs; [
        # see https://github.com/NixOS/nixpkgs/issues/9415
        # openGL programs on non-nixOS system can't linked
        # automatically. This is a wrapper to address that.
        # $ nixGLIntel [program args]
        nixgl.auto.nixGLDefault
        #fonts
        dejavu_fonts
        liberation_ttf
        roboto
        raleway
        ubuntu_font_family
        # unfree
        # corefonts
        # helvetica-neue-lt-std
        # fonts I use
        etBook
        emacs-all-the-icons-fonts
        # coding fonts
        source-sans-pro
        source-serif-pro
        (nerdfonts.override {
          enableWindowsFonts = true;
          fonts = [ "Iosevka" "FiraCode" "CascadiaCode" "Hack" "Inconsolata" "JetBrainsMono" "Hasklig" "Meslo" "Noto" ];
        })
        font-awesome
        # apps
      ];
    };
    fonts.fontconfig.enable = true;
    hub = {
      git.enable = true;
      mail.enable = true;
      desktop.enable = false;
      desktop.notify = false;
      nix.lorri = false;
      weechat.enable = false;
    };
    programs = {
      # Let Home Manager install and manage itself.
      home-manager.enable = true;
    };

    home = {
      sessionVariables = {
        EDITOR = (pkgs.writeShellScript "editor" ''
if [ $# -ne 0 ]; then
  ${
    pkgs.emacs29
  }/bin/emacsclient -nw "$@"
elif [ -n "$DISPLAY" ]; then
  ${
    pkgs.emacs29
  }/bin/emacsclient -c -n
else
  ${
    pkgs.emacs29
  }/bin/emacsclient -c
fi'');
      };
      activation = {
        linkDesktopApplications = {
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          data = ''
        rm -rf ${config.xdg.dataHome}/applications/home-manager
        mkdir -p ${config.xdg.dataHome}/applications/home-manager
        cp -Lr --no-preserve=mode,ownership ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/applications/home-manager/
      '';
        };
      };
    };

    services.dropbox.enable = true;
    services.emacs = {
      package = pkgs.emacs29;
    };
    programs.emacs = {
      package = pkgs.emacs29;
      enable = true;
    };
  };
}
