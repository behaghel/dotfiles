{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
  mkHMUser = {userConfig, username}:
    home-manager.lib.homeManagerConfiguration {
      inherit system username pkgs;
      stateVersion = "21.05";
      configuration =
        let
          trySettings = tryEval (fromJSON (readFile /etc/hmsystemdata.json));
          machineData = if trySettings.success then trySettings.value else {};

          # declare `config.machineData`
          machineModule = { pkgs, config, lib, ... }: {
            options.machineData = lib.mkOption {
              default = {};
              description = "Settings passed from nixos system configuration. If not present will be empty.";
            };

            # config.machineData.* to access system attrs
            config.machineData = machineData;
          };
        in {
          # protect namespace custom config
          hub = userConfig;

          nixpkgs.overlays = overlays;
          nixpkgs.config.allowUnfree = true;

          systemd.user.startServices = true;

          # In my understanding, this is done by homeManagerConfiguration
          # home.stateVersion = "21.05";
          # home.username = username;
          # homeDirectory = "/home/${username}";
          imports = [
            ../../.. # default user modules
            machineModule
          ];
        };
      homeDirectory = "/home/${username}";
    };

  mkSystemUser = { name, groups, uid, shell, ... }:
  {
    users.users."${name}" = {
      name = name;
      isNormalUser = true;
      isSystemUser = false;
      extragGroups = groups;
      uid = uid;
      initialPassword = "helloworld";
      shell = shell;
    };
  };
}
