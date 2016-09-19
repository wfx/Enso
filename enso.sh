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
  msg "h1" "load package configuration"
  exec 3<"package.conf"
  while IFS=';' read -r -u 3 var || [[ -n "$var" ]]; do
    # get build index and seek
    i=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    # get name and seek
    n=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    # get tree (path) and seek
    t=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
    # process action, next line
    a=${var%%;*};
    package_name[${i}]="${n}"
    package_tree[${i}]="${t}"
    package_action[${i}]="${a}"
  done
}


package_processing() {
  msg "h1" "Processing..."
  for i in "${!package_name[@]}"; do
    if [[ "${package_action[$i]}" == "none" ]]; then
      msg "note" "nothing todo for: ${package_name[$i]}"
    else
      msg "h2" "Process ${package_name[$i]}"
      "$ENSO_HOME/${package_tree[$i]}/pkgsrc.sh" "${package_action[$i]}"
    fi
  done
}

set_distribution() {
  # to install dependings (base devel, libs etc)
  case $1 in
    "archlinux") distribution="archlinux" ;;
    "antergos") distribution="archlinux" ;;
    "debian") distribution="debian" ;;
    "ubuntu") distribution="ubuntu" ;;
    *) distribution="" ;;
  esac
  if [[ $distribution == "" ]]; then
    #TODO: autodetection
    msg "txt" "TODO: Autodetecting distribution"
  fi
}

menu_set_distribution() {
  clear
  msg "hr"
  msg "h1" "Enso: Enlightenment Software"
  PS3="Select: "
  printf "Distribution:\t%s\n" "${distribution}"
  msg "h2" "Set Distribution"
  local options=("Arch Linux" "Debian" "Ubuntu")
  select opt in "${options[@]}" "Quit"; do
     case "$REPLY" in
       1 ) set_distribution "archlinux"; break ;;
       2 ) set_distribution "debian"; break ;;
       3 ) set_distribution "ubuntu"; break ;;
       $(( ${#options[@]}+1 )) ) break ;;
       *) echo "Invalid option. Try another one.";continue;;
    esac
  done
  menu_main
}

menu_set_package_action() {
  clear
  msg "hr"
  msg "h1" "Enso: Enlightenment Software"
  PS3="Select: "
  printf "Process list:\t%s\n" "${list_type}"
  msg "h2" "Set process list"
  local options=("Prepared" "Edit")
  select opt in "${options[@]}" "Quit"; do
     case "$REPLY" in
       1 ) set_package_action "prepared"; break ;;
       2 ) set_package_action "edit"; break ;;
       $(( ${#options[@]}+1 )) ) break ;;
       *) echo "Invalid option. Try another one.";continue;;
    esac
  done
  menu_main
}

menu_install() {
  for i in "${!package_action[@]}"; do
    echo "Processing: ${package_tree[$i]} ${package_action[$i]}"
  done
}

menu_main() {
  clear
  msg "h1" "Enso: Enlightenment Software"
  PS3="Select: "
  printf "Distribution:\t%s\n" "${distribution}"
  msg "hr"
  msg "h2" "Main menu"
  echo ""
  local options=("Set Distribution" "Set Process list" "Install")
  select opt in "${options[@]}" "Quit"; do
     case "$REPLY" in
       1 ) menu_set_distribution ;;
       2 ) menu_set_package_action ;;
       3 ) menu_install ;;
       $(( ${#options[@]}+1 )) ) break ;;
       *) echo "Invalid option. Try another one.";continue;;
    esac
  done
}


list_package_conf() {
  msg "h1" "Available packages"
  for i in "${!package_name[@]}"; do
    printf "%s => %s => %s => %s\n" "${i}" "${package_name[$i]}" "${package_tree[$i]}" "${package_action[$i]}"
  done
}

# ===========================================================================

[[ $ENSO_HOME ]] || export ENSO_HOME=$(pwd)
. $ENSO_HOME/tools.sh

declare -a package_name
declare -a package_tree
declare -a package_action

load_package_conf
#list_package_conf

# ===========================================================================

#menu_main

# until menu is finish (edit package.conf):
# enter all package in the compiling order
# 0;NAME;TREE TO PKGSRC.SH;install uninstall or none action
# >enso.sh
msg "h1" "Processing all packages"
package_processing

unset ENSO_HOME
exit
