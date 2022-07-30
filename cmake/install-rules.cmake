
set(CMAKE_INSTALL_MESSAGE NEVER)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Allow package maintainers to freely override the path for the configs
set(Jakt_INSTALL_CMAKEDIR "${CMAKE_INSTALL_DATADIR}/${package}"
    CACHE PATH "CMake package config location relative to the install prefix")
mark_as_advanced(Jakt_INSTALL_CMAKEDIR)

install(
    FILES cmake/install-config.cmake
    DESTINATION "${Jakt_INSTALL_CMAKEDIR}"
    RENAME JaktConfig.cmake
    COMPONENT Jakt_Development
)

set(stages 0 1 2)
foreach (stage IN LISTS stages)
  if (FINAL_STAGE LESS "${stage}")
    break()
  endif()
  set(target_name "jakt_stage${stage}")
  install(
    TARGETS ${target_name}
    EXPORT JaktTargets
    RUNTIME #
        DESTINATION "${CMAKE_INSTALL_BINDIR}/stage${stage}"
        COMPONENT Jakt_Runtime
    LIBRARY #
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/stage${stage}"
        COMPONENT Jakt_Runtime
        NAMELINK_COMPONENT Jakt_Development
    ARCHIVE #
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/stage${stage}"
        COMPONENT Jakt_Development
  )
endforeach()

# Make a symlink bin/jakt to the final compiler we created
set(final_stage_target "jakt_stage${FINAL_STAGE}")
install(CODE "execute_process(COMMAND
                              ${CMAKE_COMMAND} -E create_symlink \
                                                  \"stage${FINAL_STAGE}/$<TARGET_FILE_NAME:${final_stage_target}>\" \
                                                  ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/jakt)"
)

# Install runtime files. In the future we should probably have a bazillion rules
#   for compiling this into a static archive for different configs
install(DIRECTORY "runtime"
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        COMPONENT Jakt_Development
        FILES_MATCHING PATTERN "*.h"
                       PATTERN "*.cpp"
                       PATTERN "utility"
)

# FIXME: Figure out how to get an autogenerated import target for the final compiler (Jakt::jakt), 
#        which is the symlink above
install(
    EXPORT JaktTargets
    NAMESPACE Jakt::
    DESTINATION "${Jakt_INSTALL_CMAKEDIR}"
    COMPONENT Jakt_Development
)
