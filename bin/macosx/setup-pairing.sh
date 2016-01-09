#!/bin/sh

# IMPORTANT
# to be run with sudo

# create user 'peer' to be used remotely
dscl . create /Users/peer
dscl . create /Users/peer UserShell /bin/bash
dscl . create /Users/peer RealName "Pairing Peer"
dscl . create /Users/peer UniqueID 601 # TODO: ensure id not taken already
# this lists existing IDs but is limited to 256 entries on its output...
# dscl . -list /Users UniqueID | awk '{print $2}' | sort -n

# 20 for regular user, 80 for admin
dscl . create /Users/peer PrimaryGroupID 20

# cp -R /System/Library/User\ Template/English.lproj /Users/peer
# chown -R peer:staff /Users/peer
createhomedir -c -u peer
chgrp pairing /Users/peer
chmod g+ws /Users/peer
dscl . create /Users/peer NFSHomeDirectory /Users/peer

dscl . passwd /Users/peer pairing

echo "User 'peer' created with password 'pairing'. You might want to change it with passwd."

echo "It is recommended to turn off PasswordAuthentication in your /etc/sshd_config and use /Users/peer/.ssh/authorized_keys to grant access to remote peers."

# create group 'pairing' to share permissions with 'peer'
dscl . create /Groups/pairing
dscl . append /Groups/pairing RealName "Remote pairing peers"
dscl . append /Groups/pairing gid 1009 # TODO: check it's not taken before!
# this lists existing gids but is limited to 256 entries on its output...
# dscl . list /Groups PrimaryGroupID | awk '{print $2}' | sort -n

# add 'peer' to 'pairing' group
dseditgroup -o edit -t user -a peer pairing
# doesn't work as whoami return root with sudo...
# dseditgroup -o edit -t user -a $(whoami) pairing

# dseditgroup is the recommended way: remove the below
# dscl . append /Groups/pairing GroupMembership $(whoami)
# dscl . append /Groups/pairing GroupMembership peer

# turn on screen sharing
# XXX: this seems weak/obscure, I think I'd prefer the UI way
# defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
# launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist 2> /dev/null

# set up tmux for remote pairing
TMUX_SOCKET_DIR=/usr/local/var/tmux-pairing
mkdir -p $TMUX_SOCKET_DIR
chgrp pairing $TMUX_SOCKET_DIR
chmod g+ws $TMUX_SOCKET_DIR

echo "To be able to share a tmux session, put the socket under $TMUX_SOCKET_DIR/."
echo "Eg: $ tmux -S $TMUX_SOCKET_DIR/my-session"
echo "Your peer can then: $ tmux -S $TMUX_SOCKET_DIR/my-session attach-session"
echo "You may even want to append those lines at the end of your /etc/sshd_config:"
echo "  Match User peer"
echo "    ForceCommand tmux -S $TMUX_SOCKET_DIR/my-session attach"

# to revert the effect of this script:
# sudo dscl . rm /Users/peer && sudo rm -rf /Users/peer && sudo dscl . rm /Groups/pairing && \
#  sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true && \
#  sudo launchctl load /System/Library/LaunchDaemons/com.apple.screensharing.plist
