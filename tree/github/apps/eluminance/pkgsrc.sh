#!/bin/bash

declare -A opt_enso
declare -A pkg_source
declare -A cfg_prepare

# SETTING ============================================ #
opt_enso[testing]="no"                                 # yes||no
opt_enso[ignore_all]="no"                              # yes||no

pkg_source[description]="A photo browser written in python"         # Short description (optional)
pkg_source[url]="https://github.com/DaveMDS/eluminance.git" # full url (address/filename.extension)
pkg_source[package]="git"                              # archive -> use bsdtar || git -> git clone TODO: get this information from file
pkg_source[language]="python"                          # c||python TODO: is it empty then looks for build.sh
pkg_source[release]=""                                 # optional release number (used for git)
pkg_source[user]=""                                    # if you have a username for any repository (git)

cfg_prepare[prefix]="/usr/local"                       # prefix default is /usr/local
cfg_prepare[cflags]=""                                 # optional cflags
cfg_prepare[options]=""                                # optionial configure settings TODO: maybe go back and regex the prefix
# ==================================================== #

. ${ENSO_HOME}/processing.sh
