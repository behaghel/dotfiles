let
  standard = email: {
    address = email;
    userName = email;
    realName = "Hubert Behaghel";
    folders = {
      inbox = "inbox";
      drafts = "drafts";
      sent = "sent";
      trash = "trash";
    };
    gpg.key = email;

    mu.enable = true;
    msmtp.enable = true;
  };
in {
  inherit standard;
  gmail = name: email: lang:
    let
      farSent = if lang == "fr" then "[Gmail]/Messages envoy&AOk-s" else "[Gmail]/Sent Mail";
      farTrash = if lang == "fr" then "[Gmail]/Corbeille" else "[Gmail]/Trash";
      farDraft = if lang == "fr" then "[Gmail]/Brouillons" else "[Gmail]/Draft";
      farStarred = if lang == "fr" then "[Gmail]/Important" else "[Gmail]/Starred";
      farAll = if lang == "fr" then "[Gmail]/Tous les messages" else "[Gmail]/All Mail";
      base = standard email;
    in base // {
      flavor = "gmail.com";
      mbsync = {
        enable = true;
        create = "maildir";
        remove = "none";
        expunge = "both";
        groups.${name}.channels = {
          inbox = {
            patterns = [ "INBOX" ];
            extraConfig = {
              CopyArrivalDate = "yes";
              Sync = "All";
            };
          };
          all = {
            farPattern = farAll;
            nearPattern = "archive";
            extraConfig = {
              CopyArrivalDate = "yes";
              Create = "Near";
              Sync = "All";
            };
          };
          starred = {
            farPattern = farStarred;
            nearPattern = "starred";
            extraConfig = {
              CopyArrivalDate = "yes";
              Create = "Near";
              Sync = "All";
            };
          };
          trash = {
            farPattern = farTrash;
            nearPattern = "trash";
            extraConfig = {
              CopyArrivalDate = "yes";
              Create = "Near";
              Sync = "All";
            };
          };
          sent = {
            farPattern = farSent;
            nearPattern = "sent";
            extraConfig = {
              CopyArrivalDate = "yes";
              Create = "Near";
              Sync = "Pull";
            };
          };
        };
      };
    };
}
