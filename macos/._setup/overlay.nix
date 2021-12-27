{ pkgsX86, installNivDmg, nur }:
let
  nivSources = import ./nix/sources.nix;
in
[
  nur.overlay
  (self: super: {
    # programs that fail compilation on M1 (will run on rosetta)
    inherit (pkgsX86) pandoc niv;

    # pkgs
    sketchybar = super.callPackage ./pkgs/sketchybar { };
    yabai = super.callPackage ./pkgs/yabai { };

    Firefox = installNivDmg {
      name = "Firefox";
      src = nivSources.Firefox;
    };

    # overrides
    emacsUnstable = (super.emacs.override { srcRepo = true; nativeComp = false; }).overrideAttrs (
      o: rec {
        version = "28";
        src = super.fetchgit {
          url = "https://github.com/emacs-mirror/emacs.git";
          rev = "emacs-28.0.90";
          sha256 = "sha256-db8D5X264wFJpVxeFcNYh3U3NhSO7wvb9p+QM8Hrm0o=";
        };
        patches = [
          ./pkgs/emacs/fix-window-role.patch
          ./pkgs/emacs/no-titlebar.patch
        ];
        postPatch = o.postPatch + ''
          substituteInPlace lisp/loadup.el \
          --replace '(emacs-repository-get-branch)' '"master"'
        '';
        CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110203 -g -O2";
      }
    );
    kitty = super.kitty.overrideAttrs (
      o: rec {
        buildInputs = o.buildInputs ++
                      super.lib.optionals
                        (super.stdenv.isDarwin && (builtins.hasAttr "UserNotifications" super.darwin.apple_sdk.frameworks))
                        [ super.darwin.apple_sdk.frameworks.UserNotifications ];
        patches = super.lib.optionals super.stdenv.isDarwin [ ./pkgs/kitty/apple-sdk-11.patch ];
      }
    );
  }
  )
]
