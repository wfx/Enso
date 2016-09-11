#!/bin/bash
echo "POST UNINSTALL"
# a stupid fix for stupid login manager that don't look in /usr/local
# DaveMDS quote :)
sudo rm /usr/share/xsessions/enlightenment.desktop
