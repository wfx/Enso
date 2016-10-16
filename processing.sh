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
  _scriptdir=$(dirname $0) # processing.sh is included from pkgsrc.sh (_scriptdir == pkgsrc home dir)
  run_cmd "cd ${_scriptdir}"
  _srcdir=$(find . -mindepth 1 -maxdepth 1 -type d) # get source directory (we dont create one so the one i find is it)
  _srcdir=${_srcdir#"./"}
  _filename=$(basename ${pkg_source[url]}) # ! git is not filename... i can ignore this.
  _path_log="${_scriptdir}"
}

init() {
  # Source Directoy:
  # Use existing one or get the source (archive or git)
  msg "h2" "stage: init ${pkg_source[package]} source"
  #_srcdir=$(find . -mindepth 1 -maxdepth 1 -type d) # get source directory (we dont create one so the one i find is it)
  #_srcdir=${_srcdir#"./"}
  if [[ -d $_srcdir ]]; then
    msg "txt" "found directoy $_srcdir"
  else
    case "${pkg_source[package]}" in
      archive)
        _filename=$(basename ${pkg_source[url]})
        if [[ -f $_filename ]]; then # filename (whitout url)
          msg "txt" "found archive $_filename"
        else
            # test if i can get the resource.... works with git but not with archive :/
            #run_cmd "wget --spider ${pkg_source[url]} -nv"
            wget -q --show-progress ${pkg_source[url]} && msg "txt" "... passed." || enso_error ${?} # want the progess
        fi
        msg "txt" "extract archive ${_filename}... "
        run_cmd "tar -xf ${_filename}"
      ;;
      git)
        if [[ -z ${pkg_source[release]} ]]; then
          run_cmd "git clone ${pkg_source[url]}"
        else
          run_cmd "git clone --branch ${pkg_source[release]} ${pkg_source[url]}"
        fi
      ;;
    esac
    _srcdir=$(find . -mindepth 1 -maxdepth 1 -type d)
    _srcdir=${_srcdir#"./"}
    _path_log="${_scriptdir}/${_srcdir}"
  fi
  run_cmd "cd $_srcdir"
}

prepare() {
  # Environment
  msg "h2" "stage: prepare..."
  if [[ -z "${cfg_prepare[prefix]}" ]]
    then
      msg "alert" "prefix is not defined"
    else
      msg "note" "check for prefix in PATH..."
      if [[ "$PATH" == ?(*:)"${cfg_prepare[prefix]}/bin"?(:*) ]]
        then
          msg "txt" "prefix is set"
        else
          msg "txt" "set: ${cfg_prepare["prefix"]}/bin"
          export PATH="${cfg_prepare["prefix"]}/bin:$PATH"
      fi
      msg "note" "check for prefix in PKG_CONFIG_PATH..."
      if [[ "$PKG_CONFIG_PATH" == ?(*:)"${cfg_prepare["prefix"]}/lib/pkgconfig"?(:*) ]]
        then
          msg "txt" "PKG_CONFIG_PATH is set"
        else
          msg "txt" "set: ${cfg_prepare["prefix"]}/lib/pkgconfig"
          export PKG_CONFIG_PATH="${cfg_prepare["prefix"]}/lib/pkgconfig:$PKG_CONFIG_PATH"
      fi
      msg "note" "check for prefix in LD_LIBRARY_PATH..."
      if [[ "$LD_LIBRARY_PATH" == ?(*:)"${cfg_prepare[prefix]}/lib"?(:*) ]]
        then
          msg "txt" "LD_LIBRARY_PATH is set"
        else
          msg "txt" "set: ${cfg_prepare[prefix]}/lib"
          export LD_LIBRARY_PATH="${cfg_prepare[prefix]}/lib:$LD_LIBRARY_PATH"
      fi
  fi

  if [[ "${cfg_prepare[cflags]}" != "" ]]; then
    msg "txt" "set: CFLAGS to ${cfg_prepare[cflags]}"
    export CFLAGS="${cfg_prepare[cflags]}"
  fi
}

patch() {
  msg "h2" "stage: patch..."
  if [[ -f "${_scriptdir}/patch.sh" ]]
    then
      # something like: patch -p0 -i $_scriptdir/patch.txt
      # source it so we can use vars, tools etc.
      . "${_scriptdir}/patch.sh"
    else
      msg "txt" "nothing to patch."
  fi
}

build() {
  msg "h2" "stage: build..."
  if [[ -f "${_scriptdir}/build.sh" ]]; then
    msg "note" "running build.sh"
    . "${_scriptdir}/build.sh" # source it so we can use vars, tools etc.
  else
    case "${pkg_source[language]}" in
      c)
        msg "quote_c"
        if [[ -f "autogen.sh" ]] || [[ -f "configure" ]]; then
          if [[ -f "autogen.sh" ]]; then
              run_cmd "./autogen.sh"
          fi
          if [[ -f "configure" ]]; then
              run_cmd "./configure ${cfg_prepare[options]}"
          fi
        else
          msg "alert" "can not find autogen.sh or configure.sh script?!"
          if [ "${opt_enso[ignore_missing]}" == "yes" ]
            then
              msg "alert" "i have to ignore it"
            else
              msg "txt" "to ignore it set: ignore_missing = enabled"
              exit
          fi
        fi
        run_cmd "make clean"
        run_cmd "make"
      ;;
      python)
        msg "quote_python"
      ;;
    esac
  fi
}

install() {
  msg "h2" "stage: install..."
  if [[ -f "${_scriptdir}/install.sh" ]]; then
    msg "note" "${pkg_source[language]} running install.sh"
    . "${_scriptdir}/install.sh"  # source it so we can use vars, tools etc.
  else
    case "${pkg_source[language]}" in
      c)
        run_cmd "sudo -E make install"
      ;;
      python)
        # sudo -E to have the environment vars
        run_cmd "sudo -E python3 setup.py install"
      ;;
      *)
        msg "guru_meditation" "Unknow code (use install.sh)!"
      ;;
    esac
  fi
  # needed on Linux to update linker library database
  run_cmd "sudo ldconfig"
}

# some extra works (install a xsession file etc.)
post_install() {
  msg "h2" "stage: post install..."
  if [[ -f "${_scriptdir}/post_install.sh" ]]
    then
      . "${_scriptdir}/post_install.sh" # source it so we can use vars, tools etc.
    else
      msg "txt" "nothing todo."
  fi
}

uninstall() {
  msg "h2" "stage: uninstall..."
  if [[ -d $_srcdir ]]; then
    run_cmd "cd ${_srcdir}"
    if [[ -f "${_scriptdir}/uninstall.sh" ]]; then
      . "$_scriptdir/uninstall.sh" # source it so we can use vars, tools etc.
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
  else
    msg "note" "source directoy not found."
  fi
}

# cleaning up something (remove a xsession file etc.)
post_uninstall() {
  msg "h2" "stage: post uninstall..."
  if [[ -f "${_scriptdir}/post_uninstall.sh" ]]
    then
      . "${_scriptdir}/post_uninstall.sh"  # source it so we can use vars, tools etc.
    else
      msg "txt" "nothing todo"
  fi
}

cleaning() {
  msg "h2" "stage: cleaning..."
  run_cmd "cd ${_scriptdir}"
  if [[ -d ${_srcdir} ]]; then
    run_cmd "shopt -s extglob"
    run_cmd "sudo rm -rf ${_srcdir}"
  fi
  if [[ -f "${_filename}" ]]; then
    run_cmd "sudo rm ${_filename}"
  fi
  if [[ -f "stdout.log" ]]; then
    run_cmd "rm stdout.log"
  fi
  if [[ -f "stderr.log" ]]; then
    run_cmd "rm stdout.log"
  fi
}

#log_package_processing() {
#  echo "$(date +%Y/%m/%d_%T): ${package_index[${i}]}:${package_name[${i}]}:${package_action[${i}]}:exitcode ${?}" >> "${ENSO_HOME}/enso.log"
#}

# =============================================================
# set -x  #debug
# =============================================================

. $ENSO_HOME/tools.sh
  main

# ===========================================================================

case $1 in
  -i | --install)
    msg "h1" "install"
    msg "h1" "${pkg_source[description]}"
    main
    init         # getting source
    prepare      # set environment and
    patch        # if we have a patch.sh
    build        # or run youre own build.sh
    install      # or run youre own install.sh
    post_install # if we have a post_install.sh
  ;;
  -r | --reinstall)
    $0 -u        # call myself to uninstall
    $0 -c        # call myself to cleanup
    $0 -i        # call myself to install
  ;;
  -u | --uninstall)
    msg "h1" "uninstall"
    main
    uninstall
    post_uninstall
  ;;
  -c | --cleanup)
    msg "h1" "cleanup"
    main
    cleaning
  ;;
  -h | --help | *)
    msg "h1" "help"
    msg "note" "Usage: processing.sh [OPTION]"
    msg "note" "Mandatory arguments to long options are mandatory for short options too."
    msg "txt" "-i, --install    getting source, build and install it"
    msg "txt" "-r, --reinstall  reinstall the source"
    msg "txt" "-u, --uninstall  uninstall the source"
    msg "txt" "-c, --cleanup    cleanup the tree (TODO: rename this)"
esac
exit
