{ system, pkgs, home-manager, lib, user, ... }:
with builtins;
{
  mkHost = { name, NICs, initrdMods, kernelMods, kernelParams, kernelPackage,
             systemConfig, cpuCores, users, wifi ? [], gpuTemSensor ? null,
             cpuTempSensor ? null
           }:
             let
               networkCfg = listToAttrs (map (n: {
                 name = "${n}"; value = { useDHCP = true; };
               }) NICs);

               userCfg = {
                 inherit name NICs systemConfig cpuCores gpuTempSensor cpuTempSensor;
               };

               sys_users = (map (u: user.mkSystemUser u) users);
             in lib.nixosSystem {
               inherit system;

               modules = [
                 {
                   imports = [ ../modules/system ] ++ sys_users;

                   # to put custom options in a separate namespace to
                   # standard NixOS module system options: hub.*
                   hub = systemConfig;

                   environment.etc = {
                     "hmsystemdata.json".text = toJSON userCfg;
                   };

                   networking.hostName = "${name}";
                   networking.interfaces = networkCfg;
                   networking.wireless.interfaces = wifi;

                   networking.networkmanager.enable = true;
                   networking.useDHCP = false;

                   boot.initrd.availableKernelModules = initrdMods;
                   boot.kernelModules = kernelMods;
                   boot.kernelParams = kernelParams;
                   boot.kernelPackages = kernelPackage;

                   nixpkgs.pkgs = pkgs;
                   nix.maxJobs = lib.mkDefault cpuCores;

                   system.stateVersion = "21.05";
                 }
               ];
             };
}
