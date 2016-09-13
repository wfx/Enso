#!/bin/bash

declare -A opt_enso
declare -A pkg_source
declare -A cfg_prepare

# SETTING ============================================ #
opt_enso[testing]="no"                                 # yes||no
opt_enso[ignore_all]="no"                              # yes||no

pkg_source[description]="EFL user interface for the connman connection manager"       # Short description (optional)
pkg_source[url]="http://download.enlightenment.org/rel/apps/econnman/econnman-1.1.tar.gz" # full url (address/filename.extension)
pkg_source[package]="archive"                          # archive -> use bsdtar || git -> git clone TODO: get this information from file
pkg_source[language]="c"                               # c||python TODO: is it empty then looks for build.sh
pkg_source[release]=""                                 # optional release number (used for git)
pkg_source[user]=""                                    # if you have a username for any repository (git)

cfg_prepare[prefix]="/usr/local"                       # prefix default is /usr/local
cfg_prepare[cflags]="-O2 -ffast-math -march=native -g -ggdb3"  # optional cflags
cfg_prepare[options]=""                                # optionial configure settings TODO: maybe go back to regex here the prefix
# ==================================================== #

. ${ENSO_HOME}/processing.sh
