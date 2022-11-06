{pkgs, lib, ...}:
{ # nix-darwin system config
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      userKeyMapping = let
        pow =
          let
            pow' = base: exponent: value:
              # FIXME: It will silently overflow on values > 2**62 :(
              # The value will become negative or zero in this case
              if exponent == 0
              then 1
              else if exponent <= 1
              then value
              else (pow' base (exponent - 1) (value * base));
          in base: exponent: pow' base exponent base;
        hexToDec = v:
          let
            hexToInt = {
              "0" = 0; "1" = 1;  "2" = 2;
              "3" = 3; "4" = 4;  "5" = 5;
              "6" = 6; "7" = 7;  "8" = 8;
              "9" = 9; "A" = 10; "B" = 11;
              "C" = 12;"D" = 13; "E" = 14;
              "F" = 15;
            };
            chars = lib.stringToCharacters v;
            charsLen = builtins.length chars;
          in
            lib.lists.foldl
              (a: v: a + v)
              0
              (lib.lists.imap0
                (k: v: hexToInt."${v}" * (pow 16 (charsLen - k - 1)))
                chars);
        translateKey = (value:
          # hidutil accepts values that consists of 0x700000000 binary ORed with the
          # desired keyboard usage value.
          #
          # The actual number can be base-10 or hexadecimal.
          # 0x700000000
          #
          # 30064771072 == 0x700000000
          #
          # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
          builtins.bitOr 30064771072 (hexToDec value));
      in [
        # GLOBAL MAPPINGS
        # magic keyboard Vendor ID:	0x004C Product ID:	0x029C
        # builtin keyboard Vendor ID:	0x05ac (Apple Inc.) Product ID:	0x0341
        { # right alt -> right control
          # 0xE6 => 30064771302
          HIDKeyboardModifierMappingSrc = translateKey "E6";
          HIDKeyboardModifierMappingDst = translateKey "E4";
        }
        { # right cmd -> right alt
          HIDKeyboardModifierMappingSrc = translateKey "E7";
          HIDKeyboardModifierMappingDst = translateKey "E6";
        }
        # DEVICE SPECIFIC MAPPINGS
        # TODO: create a module with
        # a deviceSpecificMappings options
        # try to combine global mappings and device
        # specific one getting inspiration from
        # https://github.com/LnL7/nix-darwin/pull/210/files#diff-419506783ec861ca10717edb955cc3b39db637bbc691fc1ddac1f4dfaf522adeR224
        # hopefully it could be enough to force
        # system.activationScript.keyboard.text
        # with several line one per product ID
        # https://github.com/LnL7/nix-darwin/blob/master/modules/system/keyboard.nix#L71
        # it looks like mixing global and device-specific
        # remapping is a bad idea so one hidutil command
        # per product ID should be all
        # Realforce
        # Product ID:	0x0124
        # Vendor ID:	0x0853
        # left cmd <=> left alt
        # {
        #   HIDKeyboardModifierMappingSrc = translateKey "E3";
        #   HIDKeyboardModifierMappingDst = translateKey "E2";
        # }
        # {
        #   HIDKeyboardModifierMappingSrc = translateKey "E2";
        #   HIDKeyboardModifierMappingDst = translateKey "E3";
        # }
      ];
    };
    defaults = {
      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        CreateDesktop = false; # disable desktop icons
      };
      NSGlobalDomain = {
        # "com.apple.trackpad.scaling"       = "3.0";
        AppleFontSmoothing                   = 1;
        # don't ruin vim motions in Terminal
        ApplePressAndHoldEnabled             = false;
        AppleKeyboardUIMode                  = 3;
        AppleMeasurementUnits                = "Centimeters";
        AppleMetricUnits                     = 1;
        AppleShowScrollBars                  = "Automatic";
        AppleShowAllExtensions               = true;
        AppleTemperatureUnit                 = "Celsius";
        # InitialKeyRepeat                   = 15;
        KeyRepeat                            = 2;
        NSAutomaticCapitalizationEnabled     = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        # _HIHideMenuBar                       = true;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        # Enable full keyboard access for all controls
        # (e.g. enable Tab in modal dialogs)
      };
      dock = {
        autohide = true;
        mru-spaces = false;
        minimize-to-application = true;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
    };
  };
}
