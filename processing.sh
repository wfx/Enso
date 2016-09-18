#!/bin/bash
#
# COPYRIGHT (c) 2016 Wolfgang Morawetz wolfgang.morawetz@gmail.com
#
# GNU GENERAL PUBLIC LICENSE
#    Version 3, 29 June 2007
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

main() {
  _scriptdir=$(dirname $0)                    # the directory of pkg.sh
  _filename=$(basename ${pkg_source[url]})    # filename (whitout url)
  msg "h2" "Setup"
  msg "note" "working directory: \n$_scriptdir"
  cd $_scriptdir
  if [[ -f $_filename ]]; then
    _srcdir=$(bsdtar -tf $_filename | head -1 | cut -f1 -d "/")   # getting foldername from archive
  fi
  if [[ -f "stdout.log" ]]; then
    run_cmd "rm stdout.log"
  fi
  if [[ -f "stderr.log" ]]; then
    run_cmd "rm stderr.log"
  fi
}

init() {
  msg "h1" "init"
  msg "h2" "getting ${pkg_source[package]} source"
  case "${pkg_source[package]}" in
    "archive" )
      if [[ -f $_filename ]]; then
          msg "txt" "archive $_filename exist"
        else
          msg "txt" "download archive... "
          # here i dont use run_cmd (want the progess)
          wget -q --show-progress ${pkg_source[url]} && msg "txt" "... passed." || guru_meditation "$?"
          _srcdir=$(bsdtar -tf $_filename | head -1 | cut -f1 -d "/")   # getting foldername from archive
      fi
      if [[ -d $_srcdir ]]; then
          msg "txt" "found directory $_srcdir"
        else
          #bsdtar -xf $_filename  && msg "done: $?"  || exit_error "$?"
          run_cmd "bsdtar -xf $_filename"
      fi
      ;;
    "git" )
      msg "alert" "git source!"
      _srcdir=$(find . -mindepth 1 -maxdepth 1 -type d)
      _srcdir=${_srcdir#"./"}
      if [[ -d $_srcdir ]]; then
        msg "txt" "found directoy $_srcdir"
      else
        git clone ${pkg_source[url]}
        _srcdir=$(find . -mindepth 1 -maxdepth 1 -type d)
        _srcdir=${_srcdir#"./"}
      fi
      ;;
  esac
  msg "txt" "change to $_srcdir directory"
  cd $_srcdir
  msg "txt" "init... done"
}

prepare() {
  msg "h1" "prepare"
  msg "h2" "check environment"
  if [ -z "${cfg_prepare[prefix]}" ]
    then
      msg "alert" "prefix is not defined"
    else
      msg "h2" "check for prefix in PATH..."
      if [[ "$PATH" == ?(*:)"${cfg_prepare[prefix]}/bin"?(:*) ]]
        then
          msg "txt" "prefix is set"
        else
          msg "txt" "set: ${cfg_prepare["prefix"]}/bin"
          export PATH="${cfg_prepare["prefix"]}/bin:$PATH"
      fi
      msg "h2" "check for prefix in PKG_CONFIG_PATH..."
      if [[ "$PKG_CONFIG_PATH" == ?(*:)"${cfg_prepare["prefix"]}/lib/pkgconfig"?(:*) ]]
        then
          msg "txt" "PKG_CONFIG_PATH is set"
        else
          msg "txt" "set: ${cfg_prepare["prefix"]}/lib/pkgconfig"
          export PKG_CONFIG_PATH="${cfg_prepare["prefix"]}/lib/pkgconfig:$PKG_CONFIG_PATH"
      fi
      msg "h2" "check for prefix in LD_LIBRARY_PATH..."
      if [[ "$LD_LIBRARY_PATH" == ?(*:)"${cfg_prepare[prefix]}/lib"?(:*) ]]
        then
          msg "txt" "LD_LIBRARY_PATH is set"
        else
          msg "txt" "set: ${cfg_prepare[prefix]}/lib"
          export LD_LIBRARY_PATH="${cfg_prepare[prefix]}/lib:$LD_LIBRARY_PATH"
      fi
  fi

  msg "h2" "check for CFLAGS..."
  if [ -z "${cfg_prepare[cflags]}" ]
    then
      msg "txt" "CFLAGS is set"
    else
      msg "txt" "set: CFLAGS to ${cfg_prepare[cflags]}"
      export CFLAGS="${cfg_prepare[cflags]}"
  fi
}

patch() {
  msg "h1" "patch"
  if [ -f "pkg.patch" ]
    then
      msg "h2" "processing..."
      #patch -p0 -i $_scriptdir/pkg.patch  && msg "done: $?"  || exit_error "$?"
      run_cmd "patch -p0 -i $_scriptdir/pkg.patch"
    else
      msg "txt" "nothing to patch."
  fi
}

build() {
  msg "h1" "build"
  case "${pkg_source[language]}" in
    "c")
      msg "quote_c"
      if [[ -f "autogen.sh" ]] || [[ -f "configure" ]]
        then
          if [ -f "autogen.sh" ]
            then
              msg "h2" "autogen..."
              #./autogen.sh  && msg "done: $?"  || exit_error "$?"
              run_cmd "./autogen.sh"
            fi
          if [ -f "configure" ]
            then
              msg "h2" "configure..."
              #./configure ${cfg_prepare[options]}  && msg "done: $?"  || exit_error "$?"
              run_cmd "./configure ${cfg_prepare[options]}"
          fi
        else
          msg "alert" "can not find autogen.sh or configure.sh script?!"
          if [ "${opt_enso[ignore_all]}" == "no" ]
            then
              msg "txt" "to ignore this, set \$opt_enso[ignore_all]=\"yes\""
              exit
            else
              msg "alert" "i have to ignore it"
          fi
      fi
      msg "h2" "make..."
      #make  && msg "done: $?"  || exit_error "$?"
      run_cmd "make"
      ;;
    "python")
      msg "quote_python"
      ;;
    *)
      msg "alert" "${pkg_source[language]} running build.sh"
      run_cmd "$_scriptdir/build.sh"
      ;;
  esac
}

install() {
  msg "h1" "install"
  case "${pkg_source[language]}" in
    "c")
      #sudo make install  && msg "done: $?"  || exit_error "$?"
      run_cmd "sudo make install"
      ;;
    "python")
      #sudo python3 setup.py install  && msg "done: $?"  || exit_error "$?"
      # --prefix="${cfg_prepare[prefix]}" ....i have trouble with pkgconfig :/ ?
      run_cmd "git checkout ${pkg_source[release]}"
      run_cmd "sudo python3 setup.py install"
      ;;
    *)
      msg "alert" "${pkg_source[language]} running install.sh"
      run_cmd "$_scriptdir/install.sh"
      ;;
  esac
}

post_install() {
  msg "h2" "post install..."
  if [ -f "post_install.sh" ]
    then
      msg "txt" "found..."
      # shellcheck source=/dev/null
      #. $_scriptdir/post_install.sh  && msg "done: $?"  || exit_error "$?"
      run_cmd "$_scriptdir/post_install.sh"
    else
      msg "txt" "nothing todo"
  fi
}

uninstall() {
  msg "h1" "uninstall"
  case ${pkg_source[language]} in
    c)
      #sudo make uninstall && msg "done: $?"  || exit_error "$?"
      run_cmd "sudo make uninstall"
      ;;
    python)
      #sudo python setup.py uninstall && msg "done: $?"  || exit_error "$?"
      run_cmd "sudo python setup.py uninstall"
      ;;
    *)
      msg "alert" "${pkg_source[language]} running uninstall.sh"
      run_cmd "$_scriptdir/uninstall.sh"
      ;;
  esac
}

post_uninstall() {
  msg "h2" "post uninstall..."
  if [[ -f "post_uninstall.sh" ]]
    then
      msg "txt" "found... "
      # shellcheck source=/dev/null
      #. $_scriptdir/post_uninstall.sh && msg "done: $?"  || exit_error "$?"
      run_cmd "$_scriptdir/post_uninstall.sh"
    else
      msg "txt" "nothing todo"
  fi
}

run_cmd() {
  $1 > $_scriptdir/stdout.log 2> $_scriptdir/stderr.log && msg "txt" "${1}... passed" || guru_meditation "$?"
 }

# =============================================================
# note: using -fx filename?
# set -x  #debug
# =============================================================

. $ENSO_HOME/tools.sh

clear
msg "h1" "${pkg_source[description]}"

main         # main things

if [[ "$1" == "install" ]]; then
  init         # getting source
  prepare      # set environment and
  patch        # .
  build        # .
  install      # .
  post_install # .
elif [[ "$1" == "uninstall" ]]; then
  cd $_srcdir
  uninstall      # .
  post_uninstall # .
else
  msg "h2" "usage"
  msg "note" "call me with: install || uninstall"
fi

exit 0
