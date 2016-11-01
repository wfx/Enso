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

# name: prepare git
# desc: check for the source directory, clone or update it
prepare_git(){
  if [[ ! -d "${pkg_DIR[${pkg_ID}]}/${src_DIR}" ]]; then  # check for source directory
    msg "txt" "src directory: missing"
    _src_dir=$(find ${pkg_DIR[${pkg_ID}]} -mindepth 1 -maxdepth 1 -type d)  # get directory name
    if [[ -d "$_src_dir" ]]; then
      msg "txt" "remove old source directory $_src_dir"
      exec_rm_rf "$_src_dir"
    fi
    exec_git_validate_remote ${pkg_url}
    exec_git_clone ${pkg_rel} ${pkg_url}
    _src_dir=$(find ${pkg_DIR[${pkg_ID}]} -mindepth 1 -maxdepth 1 -type d)
    if [[ ! -d "${pkg_DIR[${pkg_ID}]}/${src_DIR}" ]]; then
      # change source directory name to archivename whitout extension
      exec_mv "$_src_dir" "$src_DIR"
    fi
  else
    exec_cd "${pkg_DIR[${pkg_ID}]}/${src_DIR}"
    exec_git_remote_update
    exec_git_checkout ${pkg_rel}
    exec_cd "${pkg_DIR}"
  fi
}
# name: prepare archive
# desc: check for the source directory, extract or download archive, rename source directory
prepare_archive(){
  if [[ ! -d "${pkg_DIR[${pkg_ID}]}/${src_DIR}" ]]; then  # check for source directory
    msg "txt" "src directory: missing"
    _src_dir=$(find ${pkg_DIR[${pkg_ID}]} -mindepth 1 -maxdepth 1 -type d)  # get directory name
    if [[ -d "$_src_dir" ]]; then
      msg "txt" "remove old source directory $_src_dir"
      exec_rm_rf "$_src_dir"
    fi
    if [[ -f "${pkg_url##*/}" ]]; then  # archive name whitout url
      msg "txt" "archive: found"
    else
      msg "txt" "archive: missing... check remote url and download archive"
      exec_archive_validate_remote "${pkg_url}"
      exec_archive_download "${pkg_url}"
    fi
    exec_archive_extract "${pkg_url##*/}"
    _src_dir=$(find ${pkg_DIR[${pkg_ID}]} -mindepth 1 -maxdepth 1 -type d)
    if [[ ! -d "${pkg_DIR[${pkg_ID}]}/${src_DIR}" ]]; then
      # change source directory name to archivename whitout extension
      exec_mv "$_src_dir" "$src_DIR"
    fi
  fi
}
# Name       : prepare_source
# Description: Download the source and extract the archive or clone it ( depending on what we have )
prepare_source() {
  # prepare source (build) directory
  # if we found one then try to update it.
  # if we find none then get archive and extract it or clone git repository
  load_package_source_definition
  src_DIR=${pkg_url##*/}  # remove url
  src_DIR=${src_DIR%.${pkg_ext}}  # remove ext ( used for source directory )
  if [[ ${pkg_ACTION[${pkg_ID}]} = "cleanup" ]]; then
    msg "note" "no nedd to get any type of source"
  else
    cd "${pkg_DIR[${pkg_ID}]}" >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
    case "${pkg_ext}" in
      git)
        prepare_git
      ;;
      tar.*)
        prepare_archive
      ;;
      *)
        # TODO: add support for "prepare_package.sh" as fall back
        enso_error "1" "Unknow type: ${pkg_ext}"
        exit 1
      ;;
    esac
  fi
  return 0  # success
}
# Name       : prepare_environment
# Description: Prepare (build) environment
prepare_environment() {
  msg "h2" "prepare (build) environment"

  if [[ -n ${src_prefix} ]]; then
    src_CONFIGURE="--prefix=${src_prefix} ${src_configure}"
    if [[ "$PATH" == ?(*:)"${src_prefix}/bin"?(:*) ]]
      then
        msg "txt" "prefix is in PATH"
      else
        msg "txt" "adding ${src_prefix}/bin to PATH"
        export PATH="${src_prefix}/bin:$PATH"
    fi
    if [[ "$PKG_CONFIG_PATH" == ?(*:)"${src_prefix}/lib/pkgconfig"?(:*) ]]
      then
        msg "txt" "prefix is in PKG_CONFIG_PATH"
      else
        msg "txt" "adding ${src_prefix}/lib/pkgconfig to PKG_CONFIG_PATH"
        export PKG_CONFIG_PATH="${src_prefix}/lib/pkgconfig:$PKG_CONFIG_PATH"
    fi
    if [[ "$LD_LIBRARY_PATH" == ?(*:)"${cfg_prepare[prefix]}/lib"?(:*) ]]
      then
        msg "txt" "prefix is in LD_LIBRARY_PATH"
      else
        msg "txt" "adding ${src_prefix}/lib to LD_LIBRARY_PATH"
        export LD_LIBRARY_PATH="${src_prefix}/lib:$LD_LIBRARY_PATH"
    fi
  else
    msg "alert" "prefix is not defined!"
  fi
  # set CFLAGS and CXXFLAGS
  if [[ "${src_cflags}" != "" ]]; then
    msg "txt" "setting CFLAGS to ${src_cflags}"
    export CFLAGS="${src_cflags}"
  fi
  if [[ "${src_cxxflags}" != "" ]]; then
    msg "txt" "setting CXXFLAGS to ${src_cxxflags}"
    export CFLAGS="${src_cxxflags}"
  fi

  return 0  # success
}
# Name       : c_configure
# Description: Configure c source code
# Name       : build
# Description: Source code build/compile processing
build() {
  msg "h2" "build"
  # patch
  # something like: patch -p0 -i ${pkg_DIR[${pkg_ID}]}/patchfile
  if [[ -f "${pkg_DIR[${pkg_ID}]}/patch.sh" ]]; then
    msg "note" "patch source code" #
    . "${pkg_DIR[${pkg_ID}]}/patch.sh"  # source it so we can use vars, tools etc.
  fi
  # Enter source directoy
  msg "cmd" "cd ${pkg_DIR[${pkg_ID}]}/${src_DIR}"
  cd "${pkg_DIR[${pkg_ID}]}/${src_DIR}" >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
  # build
  case "${src_build}" in
    c)
      msg "quote_c"
      # Configure...
      if [[ -f "autogen.sh" ]] || [[ -f "configure" ]]; then
        if [[ -f "autogen.sh" ]]; then
          exec_c_autogen
        fi
        if [[ -f "configure" ]]; then
          exec_c_configure
        fi
        # clean...
        exec_c_make_clean
        # make...
        exec_c_make
      else
        # 100: Missing: autogen or configure script
        enso_error "${err_MSG[100]}" "100"
      fi
    ;;
    python)
      msg "quote_python"  # nothing more.
    ;;
    *)
      if [[ -f "${pkg_DIR[${pkg_ID}]}/build.sh" ]]; then
        msg "note" "Utilize: build.sh"
        . "${pkg_DIR[${pkg_ID}]}/build.sh"  # source it so we can use vars, tools etc.
      else
        enso_error "5sec" "Unknow build (use build.sh)!"
        exit 1
      fi
    ;;
  esac
}
# Name       : install
# Description: Install software
install() {
  msg "h2" "install"
  case "${src_build}" in
    c)
      exec_c_make_install
    ;;
    python)
      exec_py_setup_install
    ;;
    *)
      if [[ -f "${pkg_DIR[${pkg_ID}]}/install.sh" ]]; then
        msg "note" "Utilize: install.sh"
        . "${pkg_DIR[${pkg_ID}]}/install.sh"  # source it so we can use vars, tools etc.
      else
        enso_error "1" "Unknow install (use install.sh)!"
        exit 1
      fi
    ;;
  esac
  # update linker library database
  exec_ldconfig
  # some extra works (install a xsession file etc... )
  if [[ -f "${pkg_DIR[${pkg_ID}]}/post_install.sh" ]]; then
    msg "note" "Utilize: post_install.sh"
    . "${pkg_DIR[${pkg_ID}]}/post_install.sh"  # source it so we can use vars, tools etc.
  fi
}
# Name       : uninstall
# Description: Uninstall installed software
uninstall() {
  msg "h2" "uninstall"
  # Enter source directoy
  msg "cmd" "cd ${pkg_DIR[${pkg_ID}]}/${src_DIR}"
  cd ${pkg_DIR[${pkg_ID}]}/${src_DIR} >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
  case ${src_build} in
    c)
      # Configure...
      if [[ -f "autogen.sh" ]] || [[ -f "configure" ]]; then
        if [[ -f "autogen.sh" ]]; then
          exec_c_autogen
        fi
        if [[ -f "configure" ]]; then
          exec_c_configure
        fi
      else
        # 100: Missing: autogen or configure script
        enso_error "${err_MSG[100]}" "100"
      fi
      exec_c_make_uninstall
    ;;
    python)
      exec_py_setup_uninstall
    ;;
    *)
      if [[ -f "${pkg_DIR[${pkg_ID}]}/uninstall.sh" ]]; then
        msg "note" "Utilize: uninstall.sh"
        . "$pkg_DIR/uninstall.sh"  # source it so we can use vars, tools etc.
      fi
    ;;
  esac
  # update linker library database
  msg "cmd_sudo" "sudo ldconfig"
  sudo ldconfig >> "$stdout" 2> "$stderr" &&  msg "cmd_sudo_passed" || enso_error "1" "$?"

  # cleaning up something (remove a xsession file etc.)
  if [[ -f "${pkg_DIR[${pkg_ID}]}/post_uninstall.sh" ]]; then
    msg "note" "Utilize: uninstall.sh"
    . "${pkg_DIR[${pkg_ID}]}/post_uninstall.sh"  # source it so we can use vars, tools etc.
  fi
}
# Name       : cleardir
# Description: Remove all created or downloaded files
cleanup() {
  msg "h1" "cleanup"
  # Remove source directory
  if [[ -d "${pkg_DIR[${pkg_ID}]}/${src_DIR}" ]]; then
    msg "cmd" "shopt -s extglob"
    shopt -s extglob >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
    msg "cmd_sudo" "sudo rm -rf ${pkg_DIR[${pkg_ID}]}/${src_DIR}"
    sudo rm -rf "${pkg_DIR[${pkg_ID}]}/$src_DIR" >> "$stdout" 2> "$stderr" &&  msg "cmd_sudo_passed" || enso_error "1" "$?"
  else
    msg "note" "none source directory to remove"
  fi
  # Remove archive file
  if [[ -f "${pkg_DIR[${pkg_ID}]}/${pkg_url##*/}" ]]; then
    msg "cmd" "sudo rm ${pkg_DIR[${pkg_ID}]}/${pkg_url##*/}"
    sudo rm "${pkg_DIR[${pkg_ID}]}/${pkg_url##*/}" >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
  else
    msg "note" "none archive file to remove"
  fi
  # Remove stdout.log file
  if [[ -f "${pkg_DIR[${pkg_ID}]}/stdout.log" ]]; then
    msg "cmd" "rm ${pkg_DIR[${pkg_ID}]}/stdout.log"
    rm "${pkg_DIR[${pkg_ID}]}/stdout.log" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
  else
    msg "note" "none stdout.log file to remove"
  fi
  # Remove stderr.log file
  if [[ -f "${pkg_DIR[${pkg_ID}]}/stderr.log" ]]; then
    msg "cmd" "rm ${pkg_DIR[${pkg_ID}]}/stderr.log"
    rm "${pkg_DIR[${pkg_ID}]}/stderr.log" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
  else
    msg "note" "none stderr.log file to remove"
  fi
}
# Name       : main processing
# Description: Processing the choosen action
#              called from enso.sh: package_processing() {}
processing_main() {

  declare stdout="${pkg_DIR[$[pkg_ID]]}/stdout.log"
  declare stderr="${pkg_DIR[$[pkg_ID]]}/stderr.log"

  case "--${pkg_ACTION[${pkg_ID}]}" in
    --install)
      prepare_source
      prepare_environment
      build
      install
    ;;
    --uninstall)
      prepare_source
      uninstall
    ;;
    --cleanup)
      prepare_source
      cleanup
    ;;
    *)
      msg "h1" "help"
      msg "note" "Usage: processing.sh [action]"
      msg "note" "actions:"
      msg "txt" "--install    install/upgrade a single package"
      msg "txt" "--remove     remove a single package"
      msg "txt" "--cleanup    cleanup, remove log and downloaded files (TODO: rename it?)"
      exit # show help nothing more.
  esac
}
