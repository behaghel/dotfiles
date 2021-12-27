{config, lib, pkgs, ... }: {
  # Spacebar
  services.spacebar.enable = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.config = {
    # general
    debug_output = "on";
    display = "all";
    position = "top";
    background_color = "0xff222222";
    foreground_color = "0xffd8dee9";
    text_font = ''"Roboto Mono:Regular:12.0"'';
    icon_font = ''"Font Awesome 5 Free:Solid:12.0"'';
    # spaces (left)
    space_icon = "•";
    space_icon_color = "0xffffab91";
    space_icon_color_secondary = "0xff78c4d4";
    space_icon_color_tertiary = "0xfffff9b0";
    space_icon_strip = "1 2 3 4 5 6 7 8 9 10";
    spaces_for_all_displays = "on";
    display_separator = "on";
    display_separator_icon = "";
    # info (right)
    clock_format = "%R";
    clock_icon = "";
    clock_icon_color = "0xffd8dee9";
    dnd_icon = "";
    dnd_icon_color = "0xffd8dee9";
    power_icon_strip = " ";
    power_icon_color = "0xffd8dee9";
    battery_icon_color = "0xffd8dee9";
    right_shell = "on";
    right_shell_icon = "";
    right_shell_icon_color = "0xffd8dee9";
    # TODO: print # unread emails
    right_shell_command = "whoami";
  };

  #launchd.user.agents.spacebar.serviceConfig.EnvironmentVariables.PATH = pkgs.lib.mkForce
  #  (builtins.replaceStrings [ "$HOME" ] [ config.users.users.hub.home ] config.environment.systemPath);
  launchd.user.agents.spacebar.serviceConfig.StandardErrorPath = "/tmp/spacebar.err.log";
  launchd.user.agents.spacebar.serviceConfig.StandardOutPath = "/tmp/spacebar.out.log";
}
