# create sc_cf.h and sc_version_string.h

# Take the sc config file template as the starting point for
# sc_cf.h.in - scripts may need to append to the template, so
# it is read into memory initially.
set(CONFIG_H_FILE ${SC_BINARY_DIR}/include/sc_cf.h.in)
set_source_files_properties(${CONFIG_H_FILE} PROPERTIES GENERATED TRUE)
set(CMAKE_CURRENT_PROJECT SC)
define_property(GLOBAL PROPERTY SC_CONFIG_H_CONTENTS BRIEF_DOCS "config.h.in contents" FULL_DOCS "config.h.in contents for SC project")
if(NOT COMMAND CONFIG_H_APPEND)
  macro(CONFIG_H_APPEND PROJECT_NAME NEW_CONTENTS)
    if(PROJECT_NAME)
      get_property(${PROJECT_NAME}_CONFIG_H_CONTENTS GLOBAL PROPERTY ${PROJECT_NAME}_CONFIG_H_CONTENTS)
      set(${PROJECT_NAME}_CONFIG_H_FILE_CONTENTS "${${PROJECT_NAME}_CONFIG_H_CONTENTS}${NEW_CONTENTS}")
      set_property(GLOBAL PROPERTY ${PROJECT_NAME}_CONFIG_H_CONTENTS "${${PROJECT_NAME}_CONFIG_H_FILE_CONTENTS}")
    endif(PROJECT_NAME)
  endmacro(CONFIG_H_APPEND NEW_CONTENTS)
endif(NOT COMMAND CONFIG_H_APPEND)
file(READ ${SC_SOURCE_DIR}/include/sc_cf_cmake.h.in CONFIG_H_FILE_CONTENTS)
CONFIG_H_APPEND(SC "${CONFIG_H_FILE_CONTENTS}")

include(CheckLibraryExists)
include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckTypeSize)
include(CMakePushCheckState)
include(CheckCXXSourceRuns)

CHECK_INCLUDE_FILE(ndir.h HAVE_NDIR_H)
CHECK_INCLUDE_FILE(stdarg.h HAVE_STDARG_H)
CHECK_INCLUDE_FILE(sys/stat.h HAVE_SYS_STAT_H)
CHECK_INCLUDE_FILE(sys/param.h HAVE_SYS_PARAM_H)
CHECK_INCLUDE_FILE(sysent.h HAVE_SYSENT_H)
CHECK_INCLUDE_FILE(unistd.h HAVE_UNISTD_H)
CHECK_INCLUDE_FILE(dirent.h HAVE_DIRENT_H)
CHECK_INCLUDE_FILE(stdbool.h HAVE_STDBOOL_H)
CHECK_INCLUDE_FILE(process.h HAVE_PROCESS_H)
CHECK_INCLUDE_FILE(io.h HAVE_IO_H)

CHECK_FUNCTION_EXISTS(abs HAVE_ABS)
CHECK_FUNCTION_EXISTS(memcpy HAVE_MEMCPY)
CHECK_FUNCTION_EXISTS(memmove HAVE_MEMMOVE)
CHECK_FUNCTION_EXISTS(getopt HAVE_GETOPT)

CHECK_TYPE_SIZE("ssize_t" SSIZE_T)

set( TEST_STD_THREAD "
#include <iostream>
#include <thread>
void do_work() {
        std::cout << \"thread\" << std::endl;
}
int main() {
        std::thread t(do_work);
        t.join();
}
" )
cmake_push_check_state()
  if( UNIX )
    set( CMAKE_REQUIRED_FLAGS "-pthread -std=c++0x" )
  else( UNIX )
    # vars probably need set for MSVC11, embarcadero, etc
  endif( UNIX )
  CHECK_CXX_SOURCE_RUNS( "${TEST_STD_THREAD}" HAVE_STD_THREAD )   #quotes are *required*!
cmake_pop_check_state()

# Now that all the tests are done, configure the sc_cf.h file:
get_property(CONFIG_H_FILE_CONTENTS GLOBAL PROPERTY SC_CONFIG_H_CONTENTS)
file(WRITE ${CONFIG_H_FILE} "${CONFIG_H_FILE_CONTENTS}")
configure_file(${CONFIG_H_FILE} ${SC_BINARY_DIR}/${INCLUDE_INSTALL_DIR}/sc_cf.h)

# ------------------------

# create sc_version_string.h, http://stackoverflow.com/questions/3780667
# Using 'ver_string' instead of 'sc_version_string.h' is a trick to force the
# command to always execute when the custom target is built. It works because
# a file by that name never exists.
configure_file(${SC_CMAKE_DIR}/sc_version_string.cmake ${SC_BINARY_DIR}/sc_version_string.cmake @ONLY)
add_custom_target(version_string ALL DEPENDS ver_string )
# creates sc_version_string.h using cmake script
add_custom_command(OUTPUT ver_string ${CMAKE_CURRENT_BINARY_DIR}/${INCLUDE_INSTALL_DIR}/sc_version_string.h
  COMMAND ${CMAKE_COMMAND} -DSOURCE_DIR=${SC_SOURCE_DIR}
  -DBINARY_DIR=${SC_BINARY_DIR}
  -P ${SC_BINARY_DIR}/sc_version_string.cmake)
# sc_version_string.h is a generated file
set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/${INCLUDE_INSTALL_DIR}/sc_version_string.h
  PROPERTIES GENERATED TRUE
  HEADER_FILE_ONLY TRUE )

# Local Variables:
# tab-width: 8
# mode: cmake
# indent-tabs-mode: t
# End:
# ex: shiftwidth=2 tabstop=8

