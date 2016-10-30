#!/bin/bash
msg "quote" "Devel, devel, on the wall. Ain't you got no sense at all?"
if [[ ! -d "${pkg_DIR[${pkg_ID}]}/${src_DIR}/build" ]]; then
  mkdir "${pkg_DIR[${pkg_ID}]}/${src_DIR}/build"
fi
cd "${pkg_DIR[${pkg_ID}]}/${src_DIR}/build"
msg "cmd" "cmake .." ; cmake .. && msg "cmd_passed"
msg "cmd" "make" ; make && msg "cmd_passed"
