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
  local tmp
  local color_green=$(tput setaf 2)
  local color_red=$(tput setaf 1)
  local color_orange=$(tput setaf 3)
  local color_blue=$(tput setaf 4)
  local color_normal=$(tput sgr0)
  local cols=$(tput cols)
  case $1 in
    "h1")
      printf -v tmp '%*s' "$cols"
      printf -v tmp '%s' "${tmp// /_}"
      printf "%s %s\n" "${color_green}${2^^}" "${tmp:${#2}+1}"
      tmp=""
      ;;
    "h2") printf "\t%s\n" "${color_green}${2}" ;;
    "hr") printf '%*s\n' "$cols" | tr ' ' \* ;;
    "txt") printf "\t%s\n" "${2}" ;;
    "warn") printf "\t%s\n" "${color_red}${2}" ;;
    "note") printf "\t%s\n" "${color_orange}${2}" ;;

    "quote_c") printf "\t%s\n" "${color_blue}C Code!" "One lang to rule them all," "One lang to find them," "One lang to bring them all and into in the enlightenment bind them.";;
    "quote_python") printf "\t%s\n" "${color_blue}Python code..." "what else :-p" ;;
    *)  printf "\t%s\n" "$1" ;;
  esac
  tput sgr0 # normal
}
