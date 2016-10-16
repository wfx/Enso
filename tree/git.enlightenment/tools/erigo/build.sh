msg "quote" "Devel, devel, on the wall. Ain't you got no sense at all?"
if [[ ! -d "${_scriptdir}/${_srcdir}/build" ]]; then
  run_cmd "mkdir build"
fi
run_cmd "cd build"
run_cmd "cmake .."
run_cmd "make"
