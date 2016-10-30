#!/bin/bash
msg "quote" "May the source be with you"
if [[ ! -d "${src_DIR}/build" ]]; then
  run_cmd "mkdir ${src_DIR}/build"
fi
run_cmd "cd ${src_DIR}/build"
run_cmd "cmake .."
run_cmd "make all"
if [[ ! -d "${pkg_DIR[${pkg_ID}]}/${src_DIR}/build" ]]; then
  mkdir "${pkg_DIR[${pkg_ID}]}/${src_DIR}/build"
fi
cd "${pkg_DIR[${pkg_ID}]}/${src_DIR}/build"
msg "cmd" "cmake .." ; cmake .. && msg "cmd_passed"
msg "cmd" "make" ; make && msg "cmd_passed"
