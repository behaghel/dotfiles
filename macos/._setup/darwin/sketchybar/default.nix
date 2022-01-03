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
  services.sketchybar.extraConfig = ''
#!/bin/sh
# This is a demo config to bring across some of the most important commands more easily.
#
############## BAR ##############
sketchybar -m --bar height=25        \
                    blur_radius=50   \
                    position=top     \
                    padding_left=10  \
                    padding_right=10 \
                    color=0x44000000

############## GLOBAL DEFAULTS ##############
sketchybar -m --default updates=when_shown                    \
                        drawing=on                            \
                        cache_scripts=on                      \
                        icon.font="Hack Nerd Font:Bold:17.0"  \
                        icon.color=0xffffffff                 \
                        label.font="Hack Nerd Font:Bold:14.0" \
                        label.color=0xffffffff

############## SPACE DEFAULTS ##############
sketchybar -m --default label.padding_left=2  \
                        label.padding_right=2 \
                        icon.padding_left=8   \
                        icon.padding_right=8

############## PRIMARY DISPLAY SPACES ##############
sketchybar -m --add space perso left                             \
              --set perso associated_space=1                     \
                         associated_display=1                    \
                         icon.font="Hack Nerd Font:Bold:20.0"    \
                         icon=                                  \
                         icon.highlight_color=0xff48aa2a         \
                         label=perso                             \
                         click_script="yabai -m space --focus 1" \
                                                                 \
              --add space emacs left                             \
              --set emacs  associated_display=1                  \
                         associated_space=2                      \
                         icon.highlight_color=0xffc065db         \
                         icon.font="file-icons:Regular:20.0"     \
                         icon=                                 \
                         label=emacs                             \
                         click_script="yabai -m space --focus 2" \
                                                                 \
              --add space work left                              \
              --set work  associated_display=1                   \
                         associated_space=3                      \
                         icon.highlight_color=0xffffce20         \
                         icon.font="Hack Nerd Font:Bold:20.0"    \
                         icon=                                 \
                         label=work                             \
                         click_script="yabai -m space --focus 3"


############## SECONDARY DISPLAY SPACES ##############
sketchybar -m --add space diary left                             \
              --set diary associated_display=2                   \
                         associated_space=5                      \
                         icon.font="Hack Nerd Font:Bold:20.0"    \
                         icon=                                  \
                         icon.highlight_color=0xff48aa2a         \
                         icon.padding_left=0                     \
                         label=diary                             \
                         click_script="yabai -m space --focus 5"

############## ITEM DEFAULTS ###############
sketchybar -m --default label.padding_left=2  \
                        icon.padding_right=2  \
                        icon.padding_left=6   \
                        label.padding_right=6


############## LEFT ITEMS ##############
sketchybar -m --add item space_separator left                                                  \
              --set space_separator  icon=                                                    \
                                     associated_space=1,2,3                                    \
                                     icon.padding_left=15                                      \
                                     label.padding_right=15                                    \
                                     icon.font="Hack Nerd Font:Bold:15.0"                      \
                                                                                               \
              --add item gitNotifications left                                                 \
              --set gitNotifications associated_space=1,2                                        \
                                     update_freq=300                                           \
                                     icon.font="Hack Nerd Font:Bold:18.0"                      \
                                     icon=                                                    \
                                     script="${scripts}/gitNotifications.sh"                   \
                                     click_script="open https://github.com/notifications"      \
              --subscribe gitNotifications system_woke                                         \
                                                                                               \
              --add item githubIndicator left                                                  \
              --set githubIndicator  associated_space=1,2                                        \
                                     update_freq=1000                                          \
                                     icon.font="Hack Nerd Font:Bold:18.0"                      \
                                     icon=                                                    \
                                     click_script="open https://github.com"                    \
                                     script="${scripts}/githubIndicator.sh"                    \
              --subscribe githubIndicator system_woke                                          \
                                                                                               \
              --add item topmem left                                                           \
              --set topmem           associated_space=1,2,3,5                                  \
                                     icon.padding_left=10                                      \
                                     update_freq=15                                            \
                                     script="${scripts}/topmem.sh"
##
############## RIGHT ITEMS ##############
sketchybar -m --add item clock right                                                          \
              --set clock         update_freq=10                                              \
                                  script="${scripts}/clock.sh"                                \
                                                                                              \
              --add item mailIndicator right                                                  \
              --set mailIndicator associated_space=1,2,3,5                                    \
                                  update_freq=30                                              \
                                  script="${scripts}/mailIndicator.sh"                        \
                                  icon.font="Hack Nerd Font:Bold:20.0"                        \
                                  icon=                                                      \
                                  click_script="yabai -m space --focus 2"
##
# Creating Graphs
sketchybar -m --add graph cpu_user right 200                                        \
              --set cpu_user     graph.color=0xffffffff                             \
                                 update_freq=2                                      \
                                 width=0                                            \
                                 associated_space=1                                 \
                                 label.padding_left=0                               \
                                 icon=                                             \
                                 script="${scripts}/cpu_graph.sh" \
                                 lazy=on                                            \
                                                                                    \
              --add graph cpu_sys right 200                                         \
              --set cpu_sys      label.padding_left=0                               \
                                 associated_space=1,2                                 \
                                 icon=                                             \
                                 graph.color=0xff48aa2a                             \
                                                                                    \
              --add item topproc right                                              \
              --set topproc      associated_space=1,2                                 \
                                 label.padding_right=10                             \
                                 update_freq=15                                     \
                                 script="${scripts}/topproc.sh"
##
###################### CENTER ITEMS ###################
##
# Adding custom events which can listen on distributed notifications from other running processes
sketchybar -m --add event spotify_change "com.spotify.client.PlaybackStateChanged"                       \
              --add item spotifyIndicator center                                                         \
              --set spotifyIndicator script="${scripts}/spotifyIndicator.sh"           \
              --set spotifyIndicator click_script="osascript -e 'tell application \"Spotify\" to pause'" \
              --subscribe spotifyIndicator spotify_change
##
############## FINALIZING THE SETUP ##############
sketchybar -m --update

echo "sketchybar configuration loaded.."
  '';
  services.yabai.config.external_bar = "main:25:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
