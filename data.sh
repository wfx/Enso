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

# TODO:
# Clean code ( style ).
# Write comments
# SQLite ?

load_package_conf() {
  # load package.cfg
  # defined available packages in (optional) build order
  # ...
  _mti=0 # min tab size for index
  _mtn=0 # min tab size for name
  _mta=9 # min tab size for action
  _mtd=0 # min tab size for description
  exec 3<"${ENSO_HOME}/package.cfg"
  while IFS=';' read -r -u 3 var || [[ -n "$var" ]]; do
    pkg_ID=${var%%;*}; [ "$var" = "$pkg_ID" ] && var='' || var="${var#*;}"
    if [[ ${_mti} -le ${#pkg_ID} ]]; then
      _mti=${#pkg_ID}
    fi
    pkg_NAME[${pkg_ID}]=${var%%;*}; [ "$var" = "$pkg_ID" ] && var='' || var="${var#*;}"
    if [[ ${_mtn} -le ${#pkg_NAME[${pkg_ID}]} ]]; then
      _mtn=${#pkg_NAME[${pkg_ID}]}
    fi
    pkg_DIR[${pkg_ID}]=${var%%;*}; [ "$var" = "$pkg_ID" ] && var='' || var="${var#*;}"
    pkg_DIR[${pkg_ID}]="${ENSO_HOME}${pkg_DIR[${pkg_ID}]}"

    pkg_ACTION[${pkg_ID}]=${var%%;*}; [ "$var" = "$pkg_ID" ] && var='' || var="${var#*;}"
    # we know the max lenght of pkg_ACTION

    pkg_DESCRIPTION[${pkg_ID}]=${var%%;*};
    if [[ ${_mtd} -le ${#pkg_DESCRIPTION[${pkg_ID}]} ]]; then
      _mtd=${#pkg_DESCRIPTION[${pkg_ID}]}
    fi
  done
}

save_package_conf() {
  # Using global defined variables
  # ENSO_HOME, pkg_NAME, pkg_DIR, pkg_ACTION, pkg_DESCRIPTION

  local _i _p
  if [[ -f "${ENSO_HOME}/package.cfg" ]]; then
    rm "${ENSO_HOME}/package.cfg"
    for _i in "${!pkg_NAME[@]}"; do
      _p="${pkg_DIR[${_i}]#${ENSO_HOME}}"
      echo "${_i};${pkg_NAME[$_i]};${_p};${pkg_ACTION[$_i]};${pkg_DESCRIPTION[$_i]}" >> "${ENSO_HOME}/package.cfg"
    done
  else
    return 1
  fi

  return 0
}

load_package_source_definition() {
  pkg_url=""        # full archive or git resource url (url/name.extension)
  pkg_ext=""        # archive compressing type (extension) or git
  pkg_rel=""        # optional git release number (branch)
  src_build=""      # build for c, python(3) code or "" to use build.sh
  src_prefix=""     # optional install prefix (/usr/local)
  src_cflags=""     # optional cflags
  src_cxxflags=""   # optional cxxflags
  src_configure=""  # optional configure options (you dont need to add a prefix is src_prefix set)

  if [[ -f "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh" ]]; then
    . "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    return 0
  fi
  return 1
}

save_package_source_definition(){
  if [[ -d "${pkg_DIR[${pkg_ID}]}" ]]; then
    touch "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$pkg_url" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$pkg_ext" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$pkg_rel" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$src_build" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$src_prefix" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$src_cflags" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$src_cxxflags" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    echo "$src_configure" >> "${pkg_DIR[${pkg_ID}]}/pkgsrc.sh"
    return 0
  else
    return 1
  fi
}

save_created_edit_package_conf(){
  #if [[ -d "${ENSO_HOME}/${ed_pkg_DIR}" ]]; then
    if [[ $ed_pkg_id -lt ${#pkg_NAME[@]} ]]; then
      #inset
      insert_at $ed_pkg_id $ed_pkg_name pkg_NAME
      insert_at $ed_pkg_id $ed_pkg_DIR pkg_DIR
      insert_at $ed_pkg_id "none" pkg_ACTION
      insert_at $ed_pkg_id $ed_pkg_description pkg_DESCRIPTION
    else
      pkg_NAME[${ed_pkg_id}]=$ed_pkg_name
      pkg_DIR[${ed_pkg_id}]=$ed_pkg_dir
      pkg_ACTION[${ed_pkg_id}]="none"
      pkg_DESCRIPTION[${ed_pkg_id}]=$ed_pkg_description
    fi
    #save_package_source_definition
    #save_package_conf
  #fi
}

load_distribution_conf() {
  # Using global defined variables
  # ENSO_HOME, dist_NAME, dist_BUILD_ESSENTIAL, dist_GRAPHICAL_SYSTEM, dist_BUILD_PACKAGES

  if [[ -f "${ENSO_HOME}/distribution.sh" ]]; then
    . "${ENSO_HOME}/distribution.sh"
  else
    return 1
  fi

  return 0
}

save_distribution_conf() {
  # Using global defined variables
  # ENSO_HOME, dist_NAME, dist_BUILD_ESSENTIAL, dist_GRAPHICAL_SYSTEM, dist_BUILD_PACKAGES

  if [[ -f "${ENSO_HOME}/distribution.sh" ]]; then
    rm "${ENSO_HOME}/distribution.sh"
    echo "dist_NAME=${dist_NAME}"
    echo "dist_BUILD_ESSENTIAL=${dist_BUILD_ESSENTIAL}"
    echo "dist_GRAPHICAL_SYSTEM=${dist_GRAPHICAL_SYSTEM}"
    echo "dist_BUILD_PACKAGES=${dist_BUILD_PACKAGES}"
  else
    return 1
  fi

  return 0
}
