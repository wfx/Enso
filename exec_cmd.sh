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
  msg "cmd" "make"
  make >> "$stdout" 2> "$stderr" &&  msg "cmd_passed" || enso_error "10sec" "$?"
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
