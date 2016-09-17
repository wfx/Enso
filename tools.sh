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

msg() {
  # messages
  local fg_col_h1=$(tput setaf 7)
  local bg_col_h1=$(tput setab 4)
  local fg_col_h2=$(tput setaf 0)
  local bg_col_h2=$(tput setab 3)
  local fg_col_txt=$(tput setaf 2)
  local fg_col_alert=$(tput setaf 1)
  local fg_col_note=$(tput setaf 3)
  local fg_col_quote=$(tput setaf 4)
  local cols=$(tput cols)
  case $1 in
    "h1")
      printf "%s%s " "${fg_col_h1}${bg_col_h1}" "${2^^}"
      printf "%*s\n" $(($cols - ${#2} - 1))
      #tput sgr0
      ;;
    "h2")
      printf "%s%s " "${fg_col_h2}${bg_col_h2}" "${2^^}"
      printf "%*s\n" $(($cols - ${#2} - 1))
      #tput sgr0
      ;;
    "hr") printf '%*s\n' "$cols" | tr ' ' '_' ;;
    "txt") printf "\t%s\n" "${fg_col_txt}${2}" ;;
    "alert") printf "\t%s\n" "${fg_col_alert}${2}" ;;
    "note") printf "\t%s\n" "${fg_col_note}${2}" ;;

    "quote_c") printf "\t%s\n" "${fg_col_quote}C Code!" "One lang to rule them all," "One lang to find them," "One lang to bring them all and into in the enlightenment bind them.";;
    "quote_python") printf "\t%s\n" "${fg_col_quote}Python code..." "what else :-p" ;;
    *)  printf "\t%s\n" "$1" ;;
  esac
  tput sgr0 # legalize
}

guru_meditation() {
  #TODO: make it better :)

  local tmp
  local cols=$(tput cols)

  tput setaf 1
  local t1="Software failure. Press enter button to continue."
  local t2="GURU MEDITATION #$1"
  printf '%*s\n' "$cols" | tr ' ' '#'
  printf -v tmp '%*s' $((($cols - ${#t1}) / 2 - 2))
  printf "#%s%s%s#\n" "${tmp}" "${t1}" "${tmp}"
  printf -v tmp '%*s' $((($cols - ${#t2}) / 2 - 2))
  printf "#%s%s%s#\n" "${tmp}" "${t2}" "${tmp}"
  printf '%*s\n' "$cols" | tr ' ' '#'
  unset tmp

  read -s -n 1 key
  if [[ $key = "" ]]; then
    tput sgr0
  else
    echo ""
    cat "$_scriptdir/stderr.log"
    msg "hr"
    tput sgr0
  fi
  exit
}
