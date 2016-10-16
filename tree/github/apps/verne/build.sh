msg "quote" "May the source be with you"
if [[ ! -d "${_scriptdir}/${_srcdir}/build" ]]; then
  run_cmd "mkdir build"
fi
run_cmd "cd build"
run_cmd "cmake .."
run_cmd "make all"
