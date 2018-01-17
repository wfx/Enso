#!/bin/bash
msg "note" "POST INSTALL"
# a stupid fix for stupid login manager that don't look in /usr/local
# DaveMDS quote :)

if [[ ! -d "/usr/share/xsessions/" ]]; then
  sudo mkdir /usr/share/xsessions/
fi
sudo cp "${pkg_DIR[${pkg_ID}]}/${src_DIR}/data/session/enlightenment.desktop" /usr/share/xsessions/
