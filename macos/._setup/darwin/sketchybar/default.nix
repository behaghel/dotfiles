{ config, lib, pkgs, ... }:

let scripts = ./scripts;

in

{
  environment.systemPackages = [ pkgs.jq pkgs.gh ];
  launchd.user.agents.sketchybar.serviceConfig = {
    StandardErrorPath = "/tmp/sketchybar.log";
    StandardOutPath = "/tmp/sketchybar.log";
  };
  services.sketchybar.enable = true;
  services.sketchybar.package = pkgs.sketchybar;
  services.yabai.config.external_bar = "main:25:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
