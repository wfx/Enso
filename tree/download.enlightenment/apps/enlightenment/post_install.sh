#!/bin/bash
# a stupid fix for stupid login manager that don't look in /usr/local
# DaveMDS quote :)

if [[ ! -d "/usr/share/xsessions/" ]]; then
  sudo mkdir /usr/share/xsessions/
fi
sudo cp data/xsession/enlightenment.desktop /usr/share/xsessions/
