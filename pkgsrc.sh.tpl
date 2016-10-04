#!/bin/bash

declare -A pkg_source
declare -A cfg_prepare

# SETTING ============================================ #
pkg_source[description]=""                             # Short description (optional)
pkg_source[url]=""                                     # full url (address/filename.extension)
pkg_source[package]="archive"                          # archive -> use tar || git -> git clone TODO: get this information from file
pkg_source[language]="c"                               # c|python TODO: is it empty then looks for build.sh
pkg_source[release]=""                                 # optional release number (used for git)

cfg_prepare[prefix]="/usr/local"                       # prefix default is /usr/local
cfg_prepare[cflags]="-O2 -ffast-math -march=native -g -ggdb3"  # optional cflags
cfg_prepare[options]=""                                # optionial configure settings TODO: maybe go back to regex from here the prefix
# ==================================================== #

. ${ENSO_HOME}/processing.sh
