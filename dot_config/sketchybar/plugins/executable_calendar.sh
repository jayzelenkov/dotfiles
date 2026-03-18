#!/bin/bash

day=$(date +%d | sed 's/^0//')
case $((day % 10)) in
  1) [ $((day % 100)) -eq 11 ] && suffix=th || suffix=st ;;
  2) [ $((day % 100)) -eq 12 ] && suffix=th || suffix=nd ;;
  3) [ $((day % 100)) -eq 13 ] && suffix=th || suffix=rd ;;
  *) suffix=th ;;
esac

sketchybar --set $NAME \
  icon="$(date '+%a, %B') ${day}${suffix}" \
  label="$(date '+%H:%M')"
