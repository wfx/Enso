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
  # Prepare working directory
  # Removing old log files
  msg "h1" "main"
  _scriptdir=$(dirname $0) # main working directory
  run_cmd "cd $_scriptdir"
  if [[ -f "stdout.log" ]]; then
    run_cmd "rm stdout.log"
  fi
  if [[ -f "stderr.log" ]]; then
    run_cmd "rm stderr.log"
  fi
  _srcdir=$(find . -mindepth 1 -maxdepth 1 -type d) # get source directory (we dont create one so the one i find is it)
  _srcdir=${_srcdir#"./"}
}

init() {
  # Source Directoy:
  # Use existing one or get the source (archive or git)
  msg "h1" "init"
  msg "h2" "${pkg_source[package]} source"
  _srcdir=$(find . -mindepth 1 -maxdepth 1 -type d) # get source directory (we dont create one so the one i find is it)
  _srcdir=${_srcdir#"./"}
  if [[ -d $_srcdir ]]; then
    msg "txt" "found directoy $_srcdir"
  else
    case "${pkg_source[package]}" in
      archive)
        _filename=$(basename ${pkg_source[url]})
        if [[ -f $_filename ]]; then # filename (whitout url)
          msg "txt" "found archive $_filename"
        else
          msg "txt" "download archive... "
          wget -q --show-progress ${pkg_source[url]} && msg "txt" "... passed." || msg "guru_meditation" "$?" # want the progess
        fi
        msg "txt" "extract archive... "
        run_cmd "tar -xf $_filename"
      ;;
      git)
        if [[ -z ${pkg_source[release]} ]]; then
          msg "txt" "git clone $(basename ${pkg_source[url]}) branch ${pkg_source[release]}"
          run_cmd "git clone ${pkg_source[url]}"
        else
          msg "txt" "git clone $(basename ${pkg_source[url]})"
          run_cmd "git clone --branch ${pkg_source[release]} ${pkg_source[url]}"
        fi
      ;;
    esac
  fi
  _srcdir=$(find . -mindepth 1 -maxdepth 1 -type d)
  _srcdir=${_srcdir#"./"}
  run_cmd "cd $_srcdir"
}

prepare() {
  # Environment
  msg "h1" "prepare"
  msg "h2" "check environment"
  if [[ -z "${cfg_prepare[prefix]}" ]]
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

  if [[ -z "${cfg_prepare[cflags]}" ]]
    then
      msg "txt" "set: CFLAGS to ${cfg_prepare[cflags]}"
      export CFLAGS="${cfg_prepare[cflags]}"
  fi
}

patch() {
  msg "h1" "patch"
  if [[ -f "patch.sh" ]]
    then
      msg "h2" "processing..."
      run_cmd "patch -p0 -i $_scriptdir/pkg.patch"
    else
      msg "txt" "nothing to patch."
  fi
}

build() {
  msg "h1" "build"
  if [[ -f "$_scriptdir/build.sh" ]]; then
    msg "note" "running build.sh"
    run_cmd "$_scriptdir/build.sh"
  else
    case "${pkg_source[language]}" in
      c)
        msg "quote_c"
        if [[ -f "autogen.sh" ]] || [[ -f "configure" ]]; then
          if [[ -f "autogen.sh" ]]; then
              msg "h2" "run autogen.sh ..."
              run_cmd "./autogen.sh"
          fi
          if [[ -f "configure" ]]; then
              msg "h2" "configure ..."
              run_cmd "./configure ${cfg_prepare[options]}"
          fi
        else
          msg "alert" "can not find autogen.sh or configure.sh script?!"
          if [ "${opt_enso[ignore_all]}" == "yes" ]
            then
              msg "alert" "i have to ignore it"
            else
              msg "txt" "to ignore this, set \$opt_enso[ignore_all]=\"yes\""
              exit
          fi
        fi
        msg "h2" "make..."
        run_cmd "make"
      ;;
      python)
        msg "quote_python"
      ;;
    esac
  fi
}

install() {
  msg "h1" "install"
  if [[ -f "$_scriptdir/install.sh" ]]; then
    msg "note" "${pkg_source[language]} running install.sh"
    run_cmd "$_scriptdir/install.sh"
  else
    case "${pkg_source[language]}" in
      c)
        run_cmd "sudo make install"
      ;;
      python)
        run_cmd "sudo python3 setup.py install"
      ;;
      *)
        msg "guru_meditation" "Unknow code (use install.sh)!"
      ;;
    esac
  fi
}

# some extra works (install a xsession file etc.)
post_install() {
  msg "h2" "post install..."
  if [[ -f "$_scriptdir/post_install.sh" ]]
    then
      msg "txt" "found..."
      run_cmd "$_scriptdir/post_install.sh"
    else
      msg "txt" "nothing todo"
  fi
}

uninstall() {
  msg "h1" "uninstall"
  if [[ -f "$_scriptdir/uninstall.sh" ]]; then
    msg "alert" "${pkg_source[language]} running uninstall.sh"
    run_cmd "$_scriptdir/uninstall.sh"
  else
    case ${pkg_source[language]} in
       c)
        run_cmd "sudo make uninstall"
      ;;
      python)
        run_cmd "sudo python setup.py uninstall"
      ;;
    esac
  fi
}

# cleaning up something (remove a xsession file etc.)
post_uninstall() {
  msg "h2" "post uninstall..."
  if [[ -f "$_scriptdir/post_uninstall.sh" ]]
    then
      msg "txt" "found... "
      run_cmd "$_scriptdir/post_uninstall.sh"
    else
      msg "txt" "nothing todo"
  fi
}

run_cmd() {
  $1 > $_scriptdir/stdout.log 2> $_scriptdir/stderr.log && msg "txt" "${1}... passed" || msg "guru_meditation" "$?"
 }

# =============================================================
# set -x  #debug
# =============================================================

. $ENSO_HOME/tools.sh

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
  run_cmd "cd ${_srcdir}"
  uninstall      # .
  post_uninstall # .
else
  msg "h2" "usage"
  msg "note" "call me with: install || uninstall"
fi

exit 0
