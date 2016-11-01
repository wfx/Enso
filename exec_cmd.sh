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

exec_ldconfig(){
  msg "cmd_sudo" "sudo ldconfig"
  sudo ldconfig >> "$stdout" 2> "$stderr" &&  msg "cmd_sudo_passed" || enso_error "1" "$?"
}

exec_rm_rf(){
  # arg: $1 directory/to/remove
  _dir=$1
  msg "cmd" "rm -rf $_dir"
  sudo rm -rf "$_dir" >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_mv(){
  # arg: move from $1 to $2 (new name)
  _from=$1
  _to=$2
  msg "cmd" "mv $_from $_to"
  mv "${_from}" "${_to}" >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_cd(){
  # arg: $1 directory/to/change
  _dir=$1
  msg "cmd" "cd $_dir"
  cd ${_dir} >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_git_validate_remote(){
  _url=$1
  msg "txt" "validity remote git repository..."...
  msg "cmd" "git ls-remote ${_url}"
  git ls-remote ${_url} >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_git_remote_update(){
  msg "cmd" "git remote update"
  git remote update >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_git_clone(){
  _rel=$1
  _url=$2
  if [[ -n ${_rel} ]]; then
    msg "cmd" "  git clone --branch ${_rel} ${_url}"
    git clone --branch ${_rel} ${_url} >> "$stdout" 2> "$stderr" & spinner &&  msg "cmd_passed" || enso_error "1" "$?"
  else
    msg "cmd" "  git clone ${_url}"
    git clone $_url >> "$stdout" 2> "$stderr" & spinner &&  msg "cmd_passed" || enso_error "1" "$?"
  fi
}

exec_git_checkout(){
  _rel=$1
  if [[ -n ${_rel} ]]; then
    msg "cmd" "git checkout ${_rel}"
    git checkout ${_rel} >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
  fi
}

exec_archive_validate_remote(){
  # check remote archive file access.
  _url=$1
  msg "cmd" "wget --spider ${_url}"
  wget --spider ${_url} -nv >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_archive_download(){
  _url=$1
  msg "cmd" "wget -q --show-progress ${_url}"
  wget -q --show-progress ${_url} >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_archive_extract(){
  # archive name whitout url
  _archive=$1
  msg "cmd" "tar -xf "${_archive}""
  tar -xf "${_archive}" >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_c_autogen(){
  msg "cmd" "autogen.sh"
  ./autogen.sh ${src_CONFIGURE} >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_c_configure(){
  msg "cmd" "configure ${src_CONFIGURE}"
  ./configure ${src_CONFIGURE} >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_c_make_clean(){
  msg "cmd" "make clean"
  make clean >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_c_make(){
  msg "cmd" "  make"
  make >> "$stdout" 2> "$stderr" & spinner &&  msg "cmd_passed" || enso_error "10sec" "$?"
}

exec_c_make_install(){
  msg "cmd_sudo" "sudo -E make install"  # -E for environment access
  sudo -E make install >> "$stdout" 2> "$stderr" &&  msg "cmd_sudo_passed" || enso_error "1" "$?"
}

exec_c_make_uninstall(){
  msg "cmd_sudo" "sudo make uninstall"
  sudo make uninstall >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "1" "$?"
}

exec_py_setup_install(){
  msg "sudo -E python3 setup.py install"  # -E for environment access
  sudo -E python3 setup.py install >> "$stdout" 2> "$stderr" &&  msg "cmd_sudo_passed" || enso_error "1" "$?"
}

exec_py_setup_uninstall(){
  msg "cmd_sudo" "sudo python setup.py uninstall"
  sudo python setup.py uninstall >> "$stdout" 2> "$stderr" &&  msg "cmd_sudo_passed" || enso_error "1" "$?"
}
