#!/bin/bash
# minimal x (with startx)
sudo apt-get update -y

sudo apt-get install -y x-window-system dbus-x11 ethtool hdparm pm-utils powermgmt-base vbetool
#lightdm lightdm-gtk-greeter

cd ~
echo "exec enlightenment_start" > .xinitrc
