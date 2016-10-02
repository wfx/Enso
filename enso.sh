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
  msg "h1" "load package configuration"
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
    echo "${i};${package_name[$i]};${package_tree[$i]};${package_action[$i]}"
  done
  read -p
}

load_distribution_conf() {
  msg "h1" "load distribution configuration"
  # the conf conatins only the name
  exec 3<"${ENSO_HOME}/distribution.conf"
  read -r -u 3 distribution
}

save_distribution_conf() {
  msg "h1" "save distribution configuration"
  rm $ENSO_HOME/distribution.conf
  echo "$distribution" > "${ENSO_HOME}/distribution.conf"
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


menu_set_distribution() {
  _reply=""
  while [[ $_reply != "e" ]]; do
    clear
    msg "h1" "Set distribution: ${distribution}"
    msg "hr"
    msg "h2" "[0] ... Arch Linux"
    msg "h2" "[1] ... Debian"
    msg "h2" "[2] ... Ubuntu"
    msg "h2" "[3] ... Fedora"
    msg "h2" "[e] ... exit"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      0) distribution="archlinux" ;;
      1) distribution="debian" ;;
      2) distribution="ubuntu" ;;
      3) distribution="fedora" ;;
      e | E) break ;;
    esac
    save_distribution_conf
  done
  menu_main
}

menu_main() {
  _reply=""
  while [[ $_reply != "q" ]]; do
    clear
    msg "h1" "Main menu: "
    printf "Distribution: %s\n" "${distribution}"
    msg "hr"
    list_package_conf
    msg "hr"
    msg "h2" "[d] ... change distribution"
    msg "h2" "[n] ... set all package to action none"
    msg "h2" "[i] ... set all package to action install"
    msg "h2" "[u] ... set all package to action uninstall"
    msg "h2" "[#] ... set action for package [#][n/i/u]"
    msg "h2" "[p] ... processing all package action"
    msg "h2" "[q] ... quit"
    read -p "> "
    _reply=$REPLY
    case $_reply in
      d | D) menu_set_distribution ;;
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

load_distribution_conf
load_package_conf
echo "$(date %Y/%m/%d_%T)" >> "${ENSO_HOME}/enso.log"
#list_package_conf

# ===========================================================================
case $1 in
  -h | --help)
    echo "Help:"
    echo "-m --menu for menu"
  ;;
  -m | --menu)
    menu_main
    #menu_set_distribution
    #menu_set_package_action
    #menu_list_package_action
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
