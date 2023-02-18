{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.hub.zsh;
  HOME = config.home.homeDirectory;
  emailAccount = import ./._setup/gmail.nix;
in {
  options.hub.mail = {
    enable = mkOption {
      description = "Enable emails";
      type = types.bool;
      default = true;
    };
    # TODO: make an array of emails to fetch / manage
    # [ "hubert@behaghel.org" "behaghel@gmail.com" ]
  };

  config = mkIf (cfg.enable) {
    accounts.email = {
      maildirBasePath = "${HOME}/Mail";
      accounts = {
        gmail = emailAccount.gmail "gmail" "behaghel@gmail.com" "en" // {
          primary = true;
          passwordCommand = "${pkgs.pass}/bin/pass online/gmail/token";
        };
        "behaghel.fr" = emailAccount.gmail "behaghel.fr" "hubert@behaghel.fr" "fr" // {
          primary = false;
          passwordCommand = "${pkgs.pass}/bin/pass online/behaghel.fr/token";
        };
        "behaghel.org" = emailAccount.standard "hubert@behaghel.org" // {
          primary = false;
          userName = "behaghel@mailfence.com";
          passwordCommand = "${pkgs.pass}/bin/pass online/mailfence.com";
          aliases = ["behaghel@mailfence.com"];
          gpg.signByDefault = true;
          imap = {
            host = "imap.mailfence.com";
            port = 993;
            tls = {
              enable = true;
            };
          };
          smtp = {
            host = "smtp.mailfence.com";
            port = 465;
            tls = {
              enable = true;
            };
          };
          mbsync = {
            enable = true;
            create = "maildir";
            remove = "none";
            expunge = "both";

            groups."behaghel.org".channels = {
              inbox = {
                # patterns = [ "*" "INBOX" "!Spam?" "!Sent Items" "!Archive" "!Trash" "!Drafts" ];
                patterns = [ "INBOX" ];
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Sync = "All";
                };
              };
              archive = {
                farPattern = "Archive";
                nearPattern = "archive";
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Create = "Near";
                  Sync = "All";
                };
              };
              trash = {
                farPattern = "Trash";
                nearPattern = "trash";
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Create = "Near";
                  Sync = "All";
                };
              };
              sent = {
                farPattern = "Sent Items";
                nearPattern = "sent";
                extraConfig = {
                  CopyArrivalDate = "yes";
                  Create = "Near";
                  Sync = "All";
                };
              };
            };
          };
        };
      };
    };
    programs = {
      # at activation it want to init db
      # but mu isn't in the path => home package instead
      mu.enable = false;
      msmtp.enable = true;
      mbsync = {
        enable = true;
        extraConfig = ''
SyncState "*"

                 '';
      };
    };
    home.packages = [ pkgs.mu ];
  };
}
