#!/bin/bash

declare -A pkg_source
declare -A cfg_prepare

# SETTING ============================================ #
pkg_source[description]="Enlightenment IDE"       # Short description (optional)
pkg_source[url]="https://github.com/ajwillia-ms/edi/releases/download/v0.4.0/edi-0.4.0.tar.bz2" # full url (address/filename.extension)
pkg_source[package]="archive"                          # archive -> use bsdtar || git -> git clone TODO: get this information from file
pkg_source[language]="c"                               # c||python TODO: is it empty then looks for build.sh
pkg_source[release]=""                                 # optional release number (used for git)

cfg_prepare[prefix]="/usr/local"                       # prefix default is /usr/local
cfg_prepare[cflags]="-O2 -ffast-math -march=native -g -ggdb3"  # optional cflags
cfg_prepare[options]="--prefix=/usr/local"             # optionial configure settings TODO: maybe go back to regex here the prefix
# ==================================================== #

. ${ENSO_HOME}/processing.sh
