#!/usr/bin/env bash
COUNT=$(/etc/profiles/per-user/hub/bin/mu find flag:unread | sort | uniq  | wc -l | tr -d ' ')
if [ $? == 0 ]; then
  sketchybar -m --set $NAME label="$COUNT"
else
  sketchybar -m --set $NAME label=
fi

