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
  if [[ -f $_filename ]]; then
    _srcdir=$(bsdtar -tf $_filename | head -1 | cut -f1 -d "/")   # getting foldername from archive
  fi
  cd $_scriptdir
  msg "note" "$_scriptdir"
}

init() {
  msg "hr"
  msg "h1" "init"
  msg "h2" "getting ${pkg_source[package]} source"
  case "${pkg_source[package]}" in
    "archive" )
      if [[ -f $_filename ]]; then
          msg "txt" "archive $_filename exist"
        else
          msg "txt" "download archive... "
          wget -q --show-progress ${pkg_source[url]}  && msg "done: $?"  || exit_error "$?"
          _srcdir=$(bsdtar -tf $_filename | head -1 | cut -f1 -d "/")   # getting foldername from archive
          msg "txt" "done"
      fi
      if [[ -d $_srcdir ]]; then
          msg "txt" "archive folder exist"
        else
          msg "txt" "extract archive... "
          bsdtar -xf $_filename  && msg "done: $?"  || exit_error "$?"
          msg "txt" "done"
      fi
      ;;
    "git" )
      msg "warn" "git source not yet implemented!"
      exit
      ;;
  esac
  msg "txt" "change to $_srcdir directory"
  cd $_srcdir
  msg "txt" "init... done"
}

prepare() {
  msg "hr"
  msg "h1" "prepare"
  msg "h2" "build environment"
  if [ -z "${cfg_prepare[prefix]}" ]
    then
      msg "warn" "prefix is not defined"
    else
      msg "h2" "check for prefix in PATH..."
      if [[ "$PATH" == ?(*:)"${cfg_prepare[prefix]}/bin"?(:*) ]]
        then
          msg "txt" "is set"
        else
          msg "txt" "set: ${cfg_prepare["prefix"]}/bin"
          export PATH="${cfg_prepare["prefix"]}/bin:$PATH"
      fi
      msg "h2" "check for prefix in PKG_CONFIG_PATH..."
      if [[ "$PKG_CONFIG_PATH" == ?(*:)"${cfg_prepare["prefix"]}/lib/pkgconfig"?(:*) ]]
        then
          msg "txt" "is set"
        else
          msg "txt" "set: ${cfg_prepare["prefix"]}/lib/pkgconfig"
          export PKG_CONFIG_PATH="${cfg_prepare["prefix"]}/lib/pkgconfig:$PKG_CONFIG_PATH"
      fi
      msg "h2" "check for prefix in LD_LIBRARY_PATH..."
      if [[ "$LD_LIBRARY_PATH" == ?(*:)"${cfg_prepare[prefix]}/lib"?(:*) ]]
        then
          msg "txt" "is set"
        else
          msg "txt" "set: ${cfg_prepare[prefix]}/lib"
          export LD_LIBRARY_PATH="${cfg_prepare[prefix]}/lib:$LD_LIBRARY_PATH"
      fi
  fi

  msg "h2" "check for CFLAGS... "
  if [ -z "${cfg_prepare[cflags]}" ]
    then
      msg "txt" "is set"
    else
      msg "txt" "set: CFLAGS to ${cfg_prepare[cflags]}"
      export CFLAGS="${cfg_prepare[cflags]}"
  fi
  msg "txt" "prepare... done"
}

patch() {
  msg "hr"
  msg "h1" "patch"
  if [ -f "pkg.patch" ]
    then
      msg "h2" "processing... "
      patch -p0 -i $_scriptdir/pkg.patch  && msg "done: $?"  || exit_error "$?"
      msg "txt" "done"
    else
      msg "txt" "nothing to patch."
  fi
  msg "txt" "patch... done"
}

build() {
  msg "hr"
  msg "h1" "build"
  msg "h2" "configure source..."
  case "${pkg_source[language]}" in
    "c")
      msg "quote_c"
      if [[ -f "autogen.sh" ]] || [[ -f "configure" ]]
        then
          if [ -f "autogen.sh" ]
            then
               ./autogen.sh  && msg "done: $?"  || exit_error "$?"
          elif [ -f "configure" ]
            then
               ./configure ${cfg_prepare[options]}  && msg "done: $?"  || exit_error "$?"
          fi
        else
          msg "warn" "can not find autogen.sh or configure.sh script?!"
          if [ "${opt_enso[ignore_all]}" == "no" ]
            then
              msg "txt" "to ignore this, set \$opt_enso[ignore_all]=\"yes\""
              exit
            else
              msg "warn" "i have to ignore it"
          fi
      fi
      msg "h2" "make"
      make  && msg "done: $?"  || exit_error "$?"
      ;;
    "python")
      msg "quote_python"
      ;;
    *)
      msg "warn" "${pkg_source[language]} is not supported: running build.sh"
      # TODO: if . $_scriptdir/build.sh || exit
      exit
      ;;
  esac
  msg "txt" "build... done"
}

install() {
  msg "hr"
  msg "h2" "install"
  msg "txt" "processing... "
  case "${pkg_source[language]}" in
    "c")
       sudo make install  && msg "done: $?"  || exit_error "$?"
      ;;
    "python")
      sudo python3 setup.py install  && msg "done: $?"  || exit_error "$?"
      # --prefix="${cfg_prepare[prefix]}" ....i have trouble with pkgconfig
      ;;
    *)
      msg "w" "${pkg_source[language]} is not supported: running install.sh"
      # TODO: if . $_scriptdir/install.sh || exit
      exit
      ;;
  esac
  msg "txt" "install... done"
}

post_install() {
  msg "hr"
  msg "h2" "post install"
  if [ -f "post_install.sh" ]
    then
      msg "txt" "found..."
      # shellcheck source=/dev/null
      . $_scriptdir/post_install.sh  && msg "done: $?"  || exit_error "$?"
    else
      msg "txt" "nothing todo"
  fi
  msg "txt" "post install... done"
}

uninstall() {
  msg "hr"
  msg "h2" "uninstall"
  msg "processing... "
  case ${pkg_source[language]} in
    c)
       sudo make uninstall && msg "done: $?"  || exit_error "$?"
      ;;
    python)
       sudo python setup.py uninstall && msg "done: $?"  || exit_error "$?"
      ;;
    *)
      msg "warn" "${pkg_source[language]} is not supported: running install.sh"
      # TODO: if . $_scriptdir/install.sh || exit
      exit
      ;;
  esac
  msg "txt" "uninstall... done"
}

post_uninstall() {
  msg "hr"
  msg "txt" "processing... "
  if [[ -f "post_uninstall.sh" ]]
    then
      msg "txt" "found... "
      # shellcheck source=/dev/null
      . $_scriptdir/post_uninstall.sh && msg "done: $?"  || exit_error "$?"
      msg "txt" "done"
    else
      msg "txt" "nothing todo"
  fi
  msg "txt" "post uninstall... done"
}

exit_error() {
  # cmd && msg "done: $?"  || exit_error "$?"
  msg "hr"
  msg "exit" "$basename $0 error: $1"
  msg "hr"
  exit -1
}
# =============================================================

. $ENSO_HOME/tools.sh

clear
msg "hr"
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
