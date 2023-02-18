(self: super: {
  # pkgs
  sketchybar = super.callPackage ./pkgs/sketchybar { };

  # overrides
  # emacsUnstable = (super.emacs.override { srcRepo = true; nativeComp = false; }).overrideAttrs (
  #   o: rec {
  #     version = "28";
  #     src = super.fetchgit {
  #       url = "https://github.com/emacs-mirror/emacs.git";
  #       rev = "emacs-28.2";
  #       sha256 = "0274fmqmyp8wk2h0n6xvkqy28ksma8k3ml4xny2c7l6i81qqp172";
  #     };
  #     patches = [
  #       ./pkgs/emacs/fix-window-role.patch
  #       ./pkgs/emacs/no-titlebar.patch
  #     ];
  #     postPatch = o.postPatch + ''
  #         substituteInPlace lisp/loadup.el \
  #         --replace '(emacs-repository-get-branch)' '"master"'
  #       '';
  #     CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=110203 -g -O2";
  #   }
  # );
}
)
