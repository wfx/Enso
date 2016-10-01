#!/bin/bash

declare -A pkg_source
declare -A cfg_prepare

# SETTING ============================================ #
pkg_source[description]="Emotion Media Center"         # Short description (optional)
pkg_source[url]="https://github.com/DaveMDS/epymc.git" # full url (address/filename.extension)
pkg_source[package]="git"                              # archive -> use bsdtar || git -> git clone TODO: get this information from file
pkg_source[language]="python"                          # c||python TODO: is it empty then looks for build.sh
pkg_source[release]="v1.2.0"                           # optional release number (used for git)

cfg_prepare[prefix]="/usr/local"                       # prefix default is /usr/local
cfg_prepare[cflags]=""                                 # optional cflags
cfg_prepare[options]=""                                # optionial configure settings TODO: maybe go back and regex the prefix
# ==================================================== #

. ${ENSO_HOME}/processing.sh
