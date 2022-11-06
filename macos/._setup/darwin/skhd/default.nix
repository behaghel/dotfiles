{ config, lib, pkgs, ... }:

let skhdConf = ./skhd.conf;
in {
  services.skhd.enable = true;
  services.skhd.skhdConfig = builtins.readFile skhdConf;
}
