#!/bin/bash
msg "note" "POST UNINSTALL"
# a stupid fix for stupid login manager that don't look in /usr/local
# DaveMDS quote :)
if [[ -f "/usr/share/xsessions/enlightenment.desktop" ]]; then
  sudo rm /usr/share/xsessions/enlightenment.desktop
fi
