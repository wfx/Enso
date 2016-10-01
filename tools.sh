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
  local fg_col_h1=$(tput setaf 7) \
    bg_col_h1=$(tput setab 4) \
    fg_col_h2=$(tput setaf 0) \
    bg_col_h2=$(tput setab 3) \
    fg_col_txt=$(tput setaf 2) \
    fg_col_alert=$(tput setaf 1) \
    fg_col_note=$(tput setaf 3) \
    fg_col_quote=$(tput setaf 4) \
    fg_col_red=$(tput setaf 1) \
    bg_col_red=$(tput setab 1) \
    bg_col_black=$(tput setab 0) \
    cols=$(tput cols) \
    col_normal=$(tput sgr0)

  case $1 in
    "h1")
      printf "%s" "${bg_col_h1}${fg_col_h1}${2^^}"
      printf "%*s${col_normal}\n" $(($cols - ${#2}))
      ;;
    "h2")
      printf "%s" "${bg_col_h2}${fg_col_h2}${2^^}"
      printf "%*s${col_normal}\n" $(($cols - ${#2}))
      ;;
    "hr")
      printf '%*s\n' "$cols" | tr ' ' '-'
      ;;
    "txt")
      printf "\t%s\n" "${fg_col_txt}${2}"
      ;;
    "alert")
      printf "\t%s\n" "${fg_col_alert}${2}"
      ;;
    "note")
      printf "\t%s\n" "${fg_col_note}${2}"
      ;;
    "quote_c")
      printf "\t%s\n" "${fg_col_quote}C Code!" "One lang to rule them all," "One lang to find them," "One lang to bring them all and in the enlightenment bind them."
      ;;
    "quote_python")
      printf "\t%s\n" "${fg_col_quote}Python code..." "what else :-p"
      ;;
    "guru_meditation")
      local t1="Software failure. Press enter button to continue."
      local t2="GURU MEDITATION #${2} "
      local m=$((${cols} % 2))
      printf -v _sl "%*s" $(((${cols} - ${#t1} - 2 - ${m}) / 2))
      printf -v _sr "%*s" $(((${cols} - ${#t1} - 2 - ${m}) / 2 + ${m}))
      t1="${bg_col_red} "${col_normal}${_sl}${fg_col_red}${t1}${_sr}"${bg_col_red} "
      printf -v _sl "%*s" $(((${cols} - ${#t2} - 2 - ${m}) / 2))
      printf -v _sr "%*s" $(((${cols} - ${#t2} - 2 - ${m}) / 2 + ${m}))
      t2="${bg_col_red} "${col_normal}${_sl}${fg_col_red}${t2}${_sr}"${bg_col_red} "
      printf "\n${bg_col_red}%*s\n" ${cols}
      printf "%s\n" "${t1}"
      printf "%s\n" "${t2}"
      printf "${bg_col_red}%*s${col_normal}\n" ${cols}
      echo
      read -s -n 1 key
      if [[ $key = "" ]]; then
        exit
      else
        cat "$_scriptdir/stderr.log"
        exit
      fi
      ;;
    *)
      printf "\t%s\n" "${col_normal}${1}"
      ;;
  esac
}
