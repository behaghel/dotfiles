{ config, pkgs, lib, ... }:
{
  # Yabai
  # csrutil enable --without fs --without debug --without nvram
  # nvram boot-args=-arm64e_preview_abi
  environment.etc."sudoers.d/yabai".text = ''
hub ALL = (root) NOPASSWD: sha256:6f316734a0dec66b04d8de5aab7e5e65703b6013836d379df10d127d70d2c0a8 ${pkgs.yabai}/bin/yabai --load-sa

''; # TODO: don't hardcode user 'hub'
  launchd.user.agents.yabai.serviceConfig = {
   StandardErrorPath = "/tmp/yabai.err.log";
   StandardOutPath = "/tmp/yabai.log";
  };
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true;
    config = {
      debug_output = "on";
      window_placement = "second_child";
      window_opacity = "on";
      window_topmost = "on";
      window_shadow = "on";
      window_border = "off"; # broken in "many ways"
      # window_border_width = 5;
      # active_window_border_color = "0xff81a1c1";
      # normal_window_border_color = "0xff3b4252";
      active_window_opacity = "1.0";
      normal_window_opacity = "0.9";
      split_ratio = "0.50";
      auto_balance = "on";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      # focus_follows_mouse = "autoraise";
      mouse_follows_focus = "off";
      mouse_drop_action = "stack";
      layout = "bsp";
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
      # external_bar = "main:26:0";
    };
    extraConfig = pkgs.lib.mkDefault ''
# rules
yabai -m rule --add app='About This Mac' manage=off
yabai -m rule --add app='System Information' manage=off
yabai -m rule --add app='System Preferences' manage=off
yabai -m rule --add app='zoom.us' manage=off topmost=on
yabai -m rule --add app=alacritty border=off
yabai -m rule --add app=kitty border=off
yabai -m rule --add app=emacs-27.2 manage=on space=2 border=off grid=1:10:5:0:5:1
yabai -m rule --add label=emacs app=Emacs manage=on space=2 border=off grid=1:10:5:0:5:1
'';
    # zoom.us simply crashes if its windows are managed by yabai...
    # yabai -m rule --add app='Emacs' title='.*Minibuf.*' manage=off border=off
  };

}
