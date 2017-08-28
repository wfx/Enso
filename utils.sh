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
    fg_col_txt=$(tput setaf 3) \
    fg_col_alert=$(tput setaf 1) \
    fg_col_note=$(tput setaf 2) \
    fg_col_quote=$(tput setaf 4) \
    fg_col_red=$(tput setaf 1) \
    bg_col_red=$(tput setab 1) \
    bg_col_black=$(tput setab 0) \
    cols=$(tput cols) \
    col_normal=$(tput sgr0)

  case $1 in
    h1)
      printf "%s" "${bg_col_h1}${fg_col_h1}${2^^}"
      printf "%*s${col_normal}\n" $(($cols - ${#2}))
    ;;
    h2)
      printf "%s" "${bg_col_h2}${fg_col_h2}${2^^}"
      printf "%*s${col_normal}\n" $(($cols - ${#2}))
    ;;
    hr)
      printf "${col_normal}%*s\n" "${cols}" | tr " " "-"
    ;;
    txt)
      printf "%s\n" "${fg_col_txt}${2}"
    ;;
    alert)
      printf "%s\n" "${fg_col_alert}${2}"
    ;;
    note)
      printf "%s\n" "${fg_col_note}:: ${2}"
    ;;
    cmd_sudo)
      printf "%s\n" "${fg_col_alert}${2}"
    ;;
    cmd_sudo_passed)
      printf "%s\n" "${fg_col_alert}[ passed ]"
      ;;
    cmd)
      printf "%s" "${fg_col_note}${2}"
    ;;
    cmd_passed)
      printf "%s\n" "${fg_col_note} [ passed ]"
      ;;
    quote)
      printf "%s\n" "${fg_col_quote}${2}"
    ;;
    quote_c)
      printf "%s\n" "${fg_col_quote}C Code!" "One lang to rule them all," "One lang to find them," "One lang to bring them all and in the enlightenment bind them."
    ;;
    quote_python)
      printf "%s\n" "${fg_col_quote}Python code..." "what else :-p"
    ;;
    guru_meditation)
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
    ;;
    *)
      printf "%s\n" "${col_normal}${1}"
    ;;
  esac

}

enso_error() {
  declare _err=$2
  msg "guru_meditation" $_err
  cat "${pkg_DIR[$pkg_ID]}/stderr.log"

  case $1 in
    1)
      read -p "Press [CTRL+C] to exit or [Return] to continue execution." || exit 1
    ;;
    *sec)
      msg "note" "Press [CTRL+C] to exit or wait ${1%sec} to continue..."
      sleep ${1%sec}
    ;;
  esac
}

insert_at(){
  # args
  # $1: index
  # $2: value
  # $3: nameref
  # example:
  # ar=("a" "b" "c" "d" "e")
  # insert_at "2" "here" ar
  # echo "${ar[@]}" result is: a b here c d e
  declare _i=$1
  declare _v=$2
  declare -n _a=$3
  # "0 to index" "value" "index to lenght of array"
  _a=("${_a[@]:0:_i}" "$_v" "${_a[@]:_i:${#_a[@]}}")
}

spinner(){
  _txt=$1
  _pid=$!
  _s[0]="p     "
  _s[1]="pl    "
  _s[2]="ple   "
  _s[3]="plea  "
  _s[4]="pleas "
  _s[5]="please"
  _s[6]=" lease"
  _s[7]="  ease"
  _s[8]="   ase"
  _s[9]="    se"
  _s[10]="     e"
  _s[11]="    t "
  _s[12]="   it "
  _s[13]="  ait "
  _s[14]=" wait "
  _s[15]=" wai  "
  _s[16]=" wa   "
  _s[17]=" w    "
  _i=0
  SECONDS=0
  while kill -0 $_pid 2>/dev/null
  do
    _i=$(( (_i+1) %17 ))
    printf "\r[ %02d:%02d ${_s[${_i-1}]:0}] $_txt " $((SECONDS/60)) $((SECONDS%60))
    sleep .1
  done
}
