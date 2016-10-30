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

package_processing() {
  if [[ "${dist_NAME}" != "none" ]]; then
    msg "h1" "Prepare distribution ${Distribution[0]}"
    if [[ "${dist_BUILD_ESSENTIAL}" == "enabled" ]]; then
      msg "h2" "Install build essential"
      "${ENSO_HOME}/distribution/${dist_NAME}/build_essential.sh"
    fi
    if [[ "${dist_GRAPHICAL_SYSTEM}" == "enabled" ]]; then
      msg "h2" "Install graphical system"
      "${ENSO_HOME}/distribution/${dist_NAME}/install_graphics_system.sh"
    fi
    if [[ "${dist_BUILD_PACKAGES}" == "enabled" ]]; then
      msg "h2" "Build packages"
      # not yet implemented... v2.0
    fi
  fi
  msg "h1" "Processing all packages..."
  for pkg_ID in "${!pkg_NAME[@]}"; do
    if [[ "${pkg_ACTION[$pkg_ID]}" == "none" ]]; then
      echo "nothing todo for: ${pkg_NAME[$pkg_ID]}" >> "${ENSO_HOME}/stdout.log"
    else
      msg "hr"
      msg "h1" "Process ${pkg_ACTION[$pkg_ID]} ${pkg_NAME[$pkg_ID]}"
      echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#" >> "${ENSO_HOME}/stdout.log"
      echo "START: $(date +%Y/%m/%d)" >> "${ENSO_HOME}/stdout.log"
      echo "processing ${pkg_ACTION[$pkg_ID]} ${pkg_NAME[$pkg_ID]}" >> "${ENSO_HOME}/stdout.log"
      processing_main
      msg "note" "processing ${pkg_ACTION[$pkg_ID]} ${pkg_NAME[$pkg_ID]} done" >> "${ENSO_HOME}/stdout.log"
      echo "#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#" >> "${ENSO_HOME}/stdout.log"
    fi
  done
}

sub_menu_prepare_distribution() {
  # Distribution[0] name
  # Distribution[1] install build essential enabled|disabled
  # Distribution[2] install graphical system enabled|disabled
  # Distribution[3] build packages enabled|disabled
  _reply=""
  while [[ $_reply != "e" ]]; do
    clear
    msg "h1" "Prepare:"
    msg "hr"
    printf "  Distribution ........... : %s\n"  "${Distribution[0]}"
    msg "hr"
    msg "1 Install build essential  : ${Distribution[1]}"
    msg "2 Install graphical system : ${Distribution[2]}"
    #msg "3 Build packages           : ${Distribution[3]}"
    msg "hr"
    msg "h2" "[#] ... change option [#][d|e]"
    msg "h2" "[q] ... quit"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      q | Q) break ;;
      *)
        # index is ${_reply%?}
        # action is reply minus number ${_reply#${_reply%?}}
        echo ${_reply%?}
        echo  ${_reply#${_reply%?}}
        if [[ "${_reply%?}" -gt 0 ]] || [[ "${_reply%?}" -lt 4 ]]; then
          case ${_reply#${_reply%?}} in
            e) distribution[${_reply%?}]="enabled" ;;
            d) distribution[${_reply%?}]="disabled" ;;
            *) ;;
          esac
        fi
    esac
  done
  save_distribution_conf
  menu_prepare_distribution
}

menu_prepare_distribution() {
  # Distribution[0] name
  _reply=""
  while [[ $_reply != "e" ]]; do
    clear
    msg "h1" "Prepare distribution:"
    list_distribution_conf
    msg "hr"
    msg "# Name"
    msg "0 None"
    msg "1 Arch Linux"
    msg "2 Debian"
    msg "3 Ubuntu"
    msg "hr"
    msg "h2" "[#] ... set distribution [#]"
    msg "h2" "[q] ... quit"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      0)
        Distribution[0]="none"
        save_distribution_conf
      ;;
      1)
        Distribution[0]="archlinux"
        sub_menu_prepare_distribution
      ;;
      2)
        Distribution[0]="debian"
        sub_menu_prepare_distribution
      ;;
      3)
        Distribution[0]="ubuntu"
        sub_menu_prepare_distribution
      ;;
      q | Q)
        break
      ;;
    esac
  done
  menu_main
}

menu_main() {
  _reply=""
  while [[ $_reply != "q" ]]; do
    clear
    msg "h1" "Main menu: "
    #list_distribution_conf
    msg "hr"
    list_package_conf
    msg "hr"
    msg "h2" "[n|i|u|c] .. : action for all package"
    msg "h2" "[#][n|i|u|c] : action for single package"
    #msg "h2" "[d] ... prepare distribution"
    msg "h2" "[p] ........ : processing all actions"
    msg "h2" "[q] ........ : quit"
    msg "txt" "[n] none, [i] install, [u] uninstall, [c] cleanup"
    msg "hr"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      n | N)
        for i in "${!pkg_NAME[@]}"; do
          pkg_ACTION[${i}]="none"
        done
        save_package_conf
      ;;
      i | I)
        for i in "${!pkg_NAME[@]}"; do
          pkg_ACTION[${i}]="install"
        done
        save_package_conf
      ;;
      u | U)
        for i in "${!pkg_NAME[@]}"; do
          pkg_ACTION[${i}]="uninstall"
        done
        save_package_conf
      ;;
      c | C)
        for i in "${!pkg_NAME[@]}"; do
          pkg_ACTION[${i}]="cleanup"
        done
        save_package_conf
      ;;
      #d | D) menu_prepare_distribution ;;
      p | P)
        package_processing
        msg "h2" "All done"
        exit
      ;;
      q | Q)
        clear
        echo "Have a lot of fun!"
        exit
      ;;
      *)
        # index is ${_reply%?}
        # action is reply minus number ${_reply#${_reply%?}}
        case ${_reply#${_reply%?}} in
          n | N)
            pkg_ACTION[${_reply%?}]="none"
            save_package_conf
          ;;
          i | I)
            pkg_ACTION[${_reply%?}]="install"
            save_package_conf
          ;;
          u | U)
            pkg_ACTION[${_reply%?}]="uninstall"
            save_package_conf
          ;;
          c | C)
            pkg_ACTION[${_reply%?}]="cleanup"
            save_package_conf
          ;;
          *) ;;
        esac
      ;;
    esac
  done
  clear
  echo "Have a lot of fun!"
  exit
}

list_distribution_conf() {
  if [[ ${dist_NAME} != "none" ]]; then
    printf "Distribution %s install:\n" "${dist_NAME}"
    printf "Build essential: %s / Graphical system: %s \n" "${dist_BUILD_ESSENTIAL}" "${dist_GRAPHICAL_SYSTEM}"
    #printf "Build packages ......... : %s\n" "${Distribution[3]}"
  else
    printf "Distribution %s:\n" "${dist_NAME}"
  fi
}

list_package_conf() {
  local _i
  printf "%${_mti}s %-${_mtn}s %-${_mta}s %-${_mtd}s\n" "#" "NAME" "ACTION" "DESCRIPTION (BUILD DEPENDENCIES)"
  for _i in "${!pkg_NAME[@]}"; do
    printf "%${_mti}s %-${_mtn}s %-${_mta}s %-${_mtd}s\n" "${_i}" "${pkg_NAME[$_i]}" "${pkg_ACTION[$_i]}" "${pkg_DESCRIPTION[$_i]}"
  done
}

list_package_actions() {
  # list all none none action's
  local _i
  printf "%${_mti}s %-${_mtn}s %-${_mta}s %-${_mtd}s\n" "#" "NAME" "ACTION" "DESCRIPTION (BUILD DEPENDENCIES)"
  for _i in "${!pkg_NAME[@]}"; do
    if [[ ! "${pkg_ACTION[$_i]}" = "none" ]]; then
      printf "%${_mti}s %-${_mtn}s %-${_mta}s %-${_mtd}s\n" "${_i}" "${pkg_NAME[$_i]}" "${pkg_ACTION[$_i]}" "${pkg_DESCRIPTION[$_i]}"
    fi
  done
}

# ===========================================================================

# set -o errexit  # script exit when a command fails ( add "... || true" to allow fail)
# set -o nounset  # script exit when it use undeclared variables
# set -o xtrace   # trace for debugging
# set -o pipefail # exit status of last command that throws a non-zero exit code

declare -r VERSION="0.1.0"
declare -r TRUE=0
declare -r FALSE=1
declare -r ENSO_HOME=$(pwd)       # Enso's home ( root )
declare -a err_MSG

err_MSG[100]="Missing: autogen or configure script"
err_MSG[101]="Access: remote resource is not available"

declare opt_IGNORE_CONFIGURE=$FALSE

declare dist_NAME                 # Distribution name
declare dist_BUILD_ESSENTIAL      # Install build essentials
declare dist_GRAPHICAL_SYSTEM     # Install graphical system
declare dist_BUILD_PACKAGES       # Build distribution packages

declare pkg_ID                    # Package id ( pkg_ARRAY[pkg_ID] )
declare -a pkg_NAME               # Package name
declare -a pkg_DIR                # Package directory ( processing directory )
declare -a pkg_ACTION             # Package action ( install, uninstall, update, remove )
declare -a pkg_DESCRIPTION        # Package description
declare pkg_url                   # ful archive or git resource url (url/name minus extension)
declare pkg_ext                   # archive compressing type (extension) or git
declare pkg_rel                   # optional git release (branch) for enso_pkg_ext[n]=git

declare src_DIR                   # Source directory
declare src_build                 # c, python(3) or "" to use build.sh
declare src_prefix                # optional install prefix ( /usr/local )
declare src_cflags                # optional cflags ( -O2... )
declare src_cxxflags              # optional cxxflags
declare src_configure             # optional configure options (you dont need to add a prefix is src_prefix set)

# ===========================================================================

#TODO: more include logic ( -l dont need processing.sh ... )
. "${ENSO_HOME}/utils.sh"
. "${ENSO_HOME}/data.sh"
. "${ENSO_HOME}/exec_cmd.sh"
. "${ENSO_HOME}/processing.sh"
load_package_conf  #load_distribution_conf

msg "h1" "enso"

# ===========================================================================
case $1 in
  -m | --menu)
    menu_main
  ;;
  -l | --list)
    msg "h1" "List settings"
    #list_distribution_conf
    msg "hr"
    list_package_conf
  ;;
  -p | --processing)
    msg "h1" "Processing all packages?"
    #list_distribution_conf
    msg "hr"
    list_package_actions
    msg "hr"
    read -p "Press [Enter] to continue or [CTRL+C] to cancel... "
    package_processing
  ;;
  -h | --help | *)
    msg "h1" "help"
    msg "note" "The Enlightenment software installer."
    msg "note" "Version: $VERSION"
    msg "note" "Usage: enso.sh [OPTION]"
    msg "txt" "-m, --menu       setting menu for enso"
    msg "txt" "-l, --list       list distribution and packages settings"
    msg "txt" "-p, --processing processing all packages"
    msg "txt" "-h, --help       this help"
esac

tput sgr0
exit
