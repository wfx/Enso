#!/bin/bash
echo "POST INSTALL"
# a stupid fix for stupid login manager that don't look in /usr/local
# DaveMDS quote :)
sudo cp core/enlightenment/data/xsession/enlightenment.desktop /usr/share/xsessions/
