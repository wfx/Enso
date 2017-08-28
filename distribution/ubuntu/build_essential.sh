#!/bin/bash
_grp="sudo"
_usr=${USER}

install_essential() {
  sudo apt-get install -y \
  make gcc bison flex gawk autoconf automake autopoint bison build-essential ccache check cmake \
  connman connman-dev connman-vpn doxygen flex freeglut3-dev git graphviz graphviz-dev imagemagick \
  libasound2-dev libblkid-dev libblkid-dev libbullet-dev libclang-dev libdbus-1-dev libffi-dev \
  libffi6-dbg libfontconfig1-dev libfreetype6-dev libpoppler-cpp-dev libpoppler-dev libfribidi-dev \
  libgbm-dev libgif-dev libgles2-mesa-dev \
  libglib2.0-dev libgstreamer-plugins-bad1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev \
  libharfbuzz-dev libibus-1.0-dev libiconv-hook-dev libinput-dev libjpeg-dev libluajit-5.1-dev libmount-dev \
  libmtdev-dev libopenjpeg-dev libpam0g-dev libpng12-dev libpoppler-dev libpulse-dev libraw-dev librsvg2-dev \
  libscim-dev libsndfile1-dev libspectre-dev libssl-dev libsystemd-dev libtiff5-dev libtool libtool-bin \
  libtorrent-rasterbar-dev libudev-dev libudisks2-dev libunibreak-dev libv8-dev libvlc-dev libwebp-dev \
  libxcb-keysyms1-dev libxcb-shape0-dev libxcomposite-dev libxcursor-dev libxine2-dev libxinerama-dev \
  libxkbcommon-dev libxrandr-dev libxrender-dev libxss-dev libxtst-dev mtdev-tools pkg-config python-dbus-dev \
  python-dev python-dbus-dev python3-dbus python3-dev python3-distutils-extra python3-xdg ragel valgrind wmctrl xserver-xephyr
}

if id -nG "${_usr}" | grep -qw "${_grp}"; then
  install_essential
else
  echo "please install sudo and add youreself to sudo group:"
  echo "----------------------------------------------------"
  echo "su"
  echo "apt-get install sudo"
  echo "adduser ${_usr} sudo"
fi
