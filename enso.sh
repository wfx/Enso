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

load_package_tree() {
  # load package_tree.conf
  # defined available packages and the tree/path to pkgsrc.sh
  id=0
  msg "note" "load package_tree.conf"
  exec 3<"package_tree.conf"
  while IFS=';' read -r -u 3 var || [[ -n "$var" ]]; do
      # get index and seek
      i=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
      # get tree (path), next line
      t=${var%%;*};
      package_tree[${i}]="${t}"
  done
  msg "txt" "load done."
}

load_process_list() {
  # load process_list.conf
  # efl,python-efl,enlightenment and terminology marked to install
  # options for each package are "install", "uninstall" or "" to do nothing
  msg "note" "load package_tree.conf"
  exec 3<"process_list.conf"
  while IFS=';' read -r -u 3 var || [[ -n "$var" ]]; do
      # get index and seek
      i=${var%%;*}; [ "$var" = "$i" ] && var='' || var="${var#*;}"
      # get process, next line
      p=${var%%;*};
      process_list[${i}]="${p}"
  done
  msg "txt" "load done."
}

set_distribution() {
  # need this to install dependings (base devel, libs etc)
  case $1 in
    "archlinux") distribution="archlinux" ;;
    "antergos") distribution="archlinux" ;;
    "debian") distribution="debian" ;;
    "ubuntu") distribution="ubuntu" ;;
    *) distribution="" ;;
  esac
  if [[ $distribution == "" ]]; then
    #TODO: autodetection
    echo "TODO: Autodetecting distribution"
  fi
}

set_process_list() {
  if [[ $1 == "prepared" ]]; then
    load_process_list
    list_type="prepared"
  elif [[ $1 == "edit" ]]; then
    echo "edit process list"
    list_type="edited"
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

menu_set_process_list() {
  clear
  msg "hr"
  msg "h1" "Enso: Enlightenment Software"
  PS3="Select: "
  printf "Process list:\t%s\n" "${list_type}"
  msg "h2" "Set process list"
  local options=("Prepared" "Edit")
  select opt in "${options[@]}" "Quit"; do
     case "$REPLY" in
       1 ) set_process_list "prepared"; break ;;
       2 ) set_process_list "edit"; break ;;
       $(( ${#options[@]}+1 )) ) break ;;
       *) echo "Invalid option. Try another one.";continue;;
    esac
  done
  menu_main
}

menu_install() {
  for i in "${!process_list[@]}"; do
    echo "Processing: ${package_tree[$i]} ${process_list[$i]}"
  done
}

menu_main() {
  clear
  msg "hr"
  msg "h1" "Enso: Enlightenment Software"
  PS3="Select: "
  printf "Distribution:\t%s\n" "${distribution}"
  printf "Process list:\t%s\n" "${list_type}"
  msg "h2" "Main menu"
  local options=("Set Distribution" "Set Process list" "Install")
  select opt in "${options[@]}" "Quit"; do
     case "$REPLY" in
       1 ) menu_set_distribution ;;
       2 ) menu_set_process_list ;;
       3 ) menu_install ;;
       $(( ${#options[@]}+1 )) ) break ;;
       *) echo "Invalid option. Try another one.";continue;;
    esac
  done
}

list_package() {
  msg "hr"
  msg "h1" "Available packages"
  for i in "${!process_list[@]}"; do
    printf "%s => %s => %s\n" "$i" "${process_list[$i]}" "${package_tree[$i]}"
  done
}

# ===========================================================================

[[ $ENSO_HOME ]] || export ENSO_HOME=$(pwd)

. $ENSO_HOME/tools.sh

declare -A package_tree
declare -A process_list

set_distribution ""
load_package_tree
set_process_list "prepared"

# ===========================================================================

# The order is important and not the same as in the file(process_list.conf)?
# list_package
# --------------------------------------------------------------------------

#menu_main

# until menu is finish: enso.sh efl
$ENSO_HOME/${package_tree[$1]}/pkgsrc.sh ${process_list[$1]}

unset ENSO_HOME
exit
