# in case we have CMake < 2.8.3
get_filename_component (
  CMAKE_CURRENT_LIST_DIR
  ${CMAKE_CURRENT_LIST_FILE}
  PATH
  )

# read list of projects from external file
include (${CMAKE_CURRENT_LIST_DIR}/CMakeLists_files.cmake)

# make space-separated list (for bash-parsing)
string (REPLACE ";" " " projlist "${PROJECTS}")

# print-out (to stdout, not /dev/tty)
execute_process (COMMAND
  ${CMAKE_COMMAND} -E echo_append ${projlist}
  )
