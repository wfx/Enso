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

load_package_conf() {
  # load package.conf
  # defined available packages in build order:
  # 0;efl;tree/enlightenment/rel/libs/efl;install
  # ...
  _mti=0 # min tab size for index
  _mtn=0 # min tab size for name
  _mtt=0 # min tab size for tree
  _mta=9 # min tab size for action
  exec 3<"package.conf"
  while IFS=';' read -r -u 3 var || [[ -n "$var" ]]; do
    # get build index and seek
    i=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    if [[ ${_mti} -le ${#i} ]]; then
      _mti=${#i}
    fi
    # get name and seek
    n=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    if [[ ${_mtn} -le ${#n} ]]; then
      _mtn=${#n}
    fi
    # get tree (path) and seek
    t=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    if [[ ${_mtt} -le ${#t} ]]; then
      _mtt=${#t}
    fi
    # process action, next line
    a=${var%%;*};
    package_index[${i}]="${i}"
    package_name[${i}]="${n}"
    package_tree[${i}]="${t}"
    package_action[${i}]="${a}"
  done
}

save_package_conf() {
  rm "${ENSO_HOME}/package.conf"
  for i in "${package_index[@]}"; do
    echo "${i};${package_name[$i]};${package_tree[$i]};${package_action[$i]}" >> "${ENSO_HOME}/package.conf"
  done
}

load_distribution_conf() {
  exec 3<"${ENSO_HOME}/distribution.conf"
  while IFS=';' read -r -u 3 var || [[ -n "$var" ]]; do
    # get distributin name and seek
    distribution[0]=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    # get install graphical system option (enabled|disabled)
    distribution[1]=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    # get install build essential option (enabled|disabled)
    distribution[2]=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    # get build packages option (enabled|disabled)
    distribution[3]=${var%%;*};
  done
}

save_distribution_conf() {
  rm "${ENSO_HOME}/distribution.conf"
  echo "${distribution[0]};${distribution[1]};${distribution[2]};${distribution[3]}" > "${ENSO_HOME}/distribution.conf"
}

package_processing() {
  msg "h1" "Processing..."
  for i in "${!package_name[@]}"; do
    if [[ "${package_action[$i]}" == "none" ]]; then
      msg "note" "nothing todo for: ${package_name[$i]}"
    else
      msg "h2" "Process ${package_name[$i]}"
      if [[ -x "$ENSO_HOME/${package_tree[$i]}/pkgsrc.sh" ]]; then
        "$ENSO_HOME/${package_tree[$i]}/pkgsrc.sh" "${package_action[$i]}"
      else
        msg "note" "make pkgsrc.sh executable..."
        chmod +x "$ENSO_HOME/${package_tree[$i]}/pkgsrc.sh"
        msg "note" "...done"
        "$ENSO_HOME/${package_tree[$i]}/pkgsrc.sh" "${package_action[$i]}"
      fi
      msg "h1" "Processing..."
    fi
    log_package_processing
  done
}

sub_menu_prepare_distribution() {
  # distribution[0] name
  # distribution[1] install graphical system enabled|disabled
  # distribution[2] install build essential enabled|disabled
  # distribution[3] build packages enabled|disabled
  _reply=""
  while [[ $_reply != "e" ]]; do
    clear
    msg "h1" "Prepare:"
    msg "hr"
    printf "  Distribution ........... : %s\n"  "${distribution[0]}"
    msg "hr"
    msg "1 Install graphical system : ${distribution[1]}"
    msg "2 Install build essential  : ${distribution[2]}"
    msg "3 Build packages           : ${distribution[3]}"
    msg "hr"
    msg "h2" "[#] ... change option [#][d|e]"
    msg "h2" "[e] ... exit"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      e | E) break ;;
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
  # distribution[0] name
  _reply=""
  while [[ $_reply != "e" ]]; do
    clear
    msg "h1" "Prepare distribution:"
    msg "hr"
    msg "# Name"
    msg "1 Arch Linux"
    msg "2 Debian"
    msg "3 Ubuntu"
    msg "hr"
    msg "h2" "[#] ... set distribution [#]"
    msg "h2" "[e] ... exit"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      1)
        distribution[0]="archlinux"
        sub_menu_prepare_distribution
        ;;
      2)
        distribution[0]="debian"
        sub_menu_prepare_distribution
        ;;
      3)
        distribution[0]="ubuntu"
        sub_menu_prepare_distribution
        ;;
      e | E) break ;;
    esac
  done
  menu_main
}

menu_main() {
  _reply=""
  while [[ $_reply != "q" ]]; do
    clear
    msg "h1" "Main menu: "
    msg "hr"
    list_distribution_conf
    msg "hr"
    list_package_conf
    msg "hr"
    msg "h2" "[d] ... prepare distribution"
    msg "h2" "[n] ... set all package to action none"
    msg "h2" "[i] ... set all package to action install"
    msg "h2" "[u] ... set all package to action uninstall"
    msg "h2" "[#] ... set action for package [#][n/i/u]"
    msg "h2" "[p] ... processing all package action"
    msg "h2" "[q] ... quit"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      d | D) menu_prepare_distribution ;;
      n | N)
        for i in "${package_index[@]}"; do
          package_action[${i}]="none"
        done
        save_package_conf ;;
      i | I)
        for i in "${package_index[@]}"; do
          package_action[${i}]="install"
        done
        save_package_conf ;;
      u | U)
        for i in "${package_index[@]}"; do
          package_action[${i}]="uninstall"
        done
        save_package_conf ;;
      p | P)
        package_processing
        msg "h2" "All done"
        exit
        ;;
      q | Q)
        clear
        echo "Have a lot of fun!"
        exit ;;
      *)
        # index is ${_reply%?}
        # action is reply minus number ${_reply#${_reply%?}}
        case ${_reply#${_reply%?}} in
          n) package_action[${_reply%?}]="none" ;;
          i) package_action[${_reply%?}]="install" ;;
          u) package_action[${_reply%?}]="uninstall" ;;
          *) ;;
        esac
        save_package_conf
        ;;
    esac
  done
  clear
  echo "Have a lot of fun!"
  exit
}

log_package_processing() {
  echo "${package_index[${i}]}:${package_name[${i}]}:${package_action[${i}]}:exitcode ${?}" >> "${ENSO_HOME}/enso.log"
}

list_distribution_conf() {
  printf "Distribution ........... : %s\n" "${distribution[0]}"
  printf "Install graphical system : %s\n" "${distribution[1]}"
  printf "Install build essential  : %s\n" "${distribution[2]}"
  printf "Build packages ......... : %s\n" "${distribution[3]}"
}

list_package_conf() {
  printf "%${_mti}s %-${_mtn}s %-${_mta}s %-${_mtt}s\n" "#" "NAME" "ACTION" "TREE (PKGSRC)"
  for i in "${!package_name[@]}"; do
    printf "%${_mti}s %-${_mtn}s %-${_mta}s %-${_mtt}s\n" "${i}" "${package_name[$i]}" "${package_action[$i]}" "${package_tree[$i]}"
  done
}

# ===========================================================================

[[ $ENSO_HOME ]] || export ENSO_HOME=$(pwd)
. $ENSO_HOME/tools.sh

declare -a package_index
declare -a package_name
declare -a package_tree
declare -a package_action

msg "h1" "Prepare ENSO"
msg "h2" "load distribution configuration"
load_distribution_conf
msg "h2" "load package configuration"
load_package_conf
msg "h2" "log timestap"
echo "$(date %Y/%m/%d_%T)" >> "${ENSO_HOME}/enso.log"

# ===========================================================================
case $1 in
  -h | --help)
    echo "Help:"
    echo "-m --menu for menu"
    echo "-l --list list available packages"
  ;;
  -m | --menu)
    menu_main
  ;;
  -l | --list)
    msg "h1" "Available packages"
    list_package_conf
  ;;
  *)
    msg "h1" "Processing all packages"
    read -p "Press [Enter] to continue or [CTRL+C] to cancel... "
    package_processing
esac

unset ENSO_HOME
exit
