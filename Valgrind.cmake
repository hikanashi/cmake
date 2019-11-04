include(CMakeParseArguments)

# Check prereqs
find_program( VALGRIND_PATH valgrind )
set(VALGRIND_SUPPRESSIONS "" CACHE STRING "Add Valgrind suppressions file.")

# Builds dependencies, runs the given executable and outputs reports.
#
# SETUP_TARGET_FOR_MEMCHECK_VALGRIND(
#     NAME ctest_memcheck                    # New target name
#     VALGRIND_ARGS --log-file=$<TARGET_FILE_DIR:mytarget>/memcheck.log # valgrind args
#     EXECUTABLE ctest -j ${PROCESSOR_COUNT} # Executable in PROJECT_BINARY_DIR
#     DEPENDENCIES executable_target         # Dependencies to build first
# )
function(SETUP_TARGET_FOR_VALGRIND_MEMCHECK)
    set(options NONE)
    set(oneValueArgs NAME)
    set(multiValueArgs SUDOCMD VALGRIND_ARGS EXECUTABLE EXECUTABLE_ARGS SUPPRESSIONS DEPENDENCIES)
    cmake_parse_arguments(Memcheck "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT VALGRIND_PATH)
        message(FATAL_ERROR "Valgrind not found! Aborting...")
    endif()

    # build valgrind command
    if (NOT ${Memcheck_SUPPRESSIONS} STREQUAL "" AND EXISTS ${Memcheck_SUPPRESSIONS})
       set(VALGRIND_SUPP "--suppressions=${Memcheck_SUPPRESSIONS}")
    endif()

    # run valgrind memcheck
    add_custom_target(${Memcheck_NAME}
        ${Memcheck_SUDOCMD} ${VALGRIND_PATH} ${VALGRIND_SUPP} ${Memcheck_VALGRIND_ARGS}
                         --tool=memcheck --error-limit=no
#                         -v
#                         --show-reachable=yes
                         --gen-suppressions=all
                         --leak-check=full
                         --undef-value-errors=yes --track-origins=no
                         --child-silent-after-fork=yes --trace-children=no
                          ${Memcheck_EXECUTABLE} ${Memcheck_EXECUTABLE_ARGS}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        DEPENDS ${Memcheck_DEPENDENCIES}
        COMMENT "Running valgrind for memory check."
    )

endfunction(SETUP_TARGET_FOR_VALGRIND_MEMCHECK)

# Builds dependencies, runs the given executable and outputs reports.
#
# SETUP_TARGET_FOR_MEMCHECK_VALGRIND_XML(
#     NAME ctest_memcheck                    # New target name
#     EXECUTABLE ctest -j ${PROCESSOR_COUNT} # Executable in PROJECT_BINARY_DIR
#     DEPENDENCIES executable_target         # Dependencies to build first
# )
function(SETUP_TARGET_FOR_VALGRIND_MEMCHECK_XML)
    set(options NONE)
    set(oneValueArgs NAME)
    set(multiValueArgs VALGRIND_ARGS EXECUTABLE EXECUTABLE_ARGS SUPPRESSIONS DEPENDENCIES)
    cmake_parse_arguments(Memcheck "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT VALGRIND_PATH)
        message(FATAL_ERROR "Valgrind not found! Aborting...")
    endif()

    # build valgrind command
    if (NOT ${Memcheck_SUPPRESSIONS} STREQUAL "" AND EXISTS ${Memcheck_SUPPRESSIONS})
       set(VALGRIND_SUPP "--suppressions=${Memcheck_SUPPRESSIONS}")
    endif()

    # run valgrind memcheck
    add_custom_target(${Memcheck_NAME}
        ${Memcheck_SUDOCMD} ${VALGRIND_PATH} ${VALGRIND_SUPP} ${Memcheck_VALGRIND_ARGS}
                         --tool=memcheck
                         --error-limit=no
#                         -v
#                         --show-reachable=yes
                         --gen-suppressions=all
                         --leak-check=full
                         --undef-value-errors=yes
                         --track-origins=no
                         --child-silent-after-fork=yes
                         --trace-children=no
                         --xml=yes 
                         --xml-file=${PROJECT_BINARY_DIR}/valgrind.memcheck.xml
                          ${Memcheck_EXECUTABLE} ${Memcheck_EXECUTABLE_ARGS}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        DEPENDS ${Memcheck_DEPENDENCIES}
        COMMENT "Running valgrind for memory check."
    )

    # show comment where to find the report
    add_custom_command(TARGET ${Memcheck_NAME} POST_BUILD
        COMMAND ;
        COMMENT "Open ./valgrind.memcheck.log in your browser to view the threadcheck log."
    )

endfunction(SETUP_TARGET_FOR_VALGRIND_MEMCHECK_XML)

# Builds dependencies, runs the given executable and outputs reports.
#
# SETUP_TARGET_FOR_HELGRIND_VALGRIND(
#     NAME ctest_helgrind                    # New target name
#     EXECUTABLE ctest -j ${PROCESSOR_COUNT} # Executable in PROJECT_BINARY_DIR
#     DEPENDENCIES executable_target         # Dependencies to build first
# )
function(SETUP_TARGET_FOR_VALGRIND_HELGRIND)
    set(options NONE)
    set(oneValueArgs NAME)
    set(multiValueArgs VALGRIND_ARGS EXECUTABLE EXECUTABLE_ARGS SUPPRESSIONS DEPENDENCIES)
    cmake_parse_arguments(Helgrind "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT VALGRIND_PATH)
        message(FATAL_ERROR "Valgrind not found! Aborting...")
    endif()

    # build valgrind command
    if (NOT ${Helgrind_SUPPRESSIONS} STREQUAL "" AND EXISTS ${Helgrind_SUPPRESSIONS})
       set(VALGRIND_SUPP "--suppressions=${Helgrind_SUPPRESSIONS}")
    endif()

    # run valgrind helgrind
    add_custom_target(${Helgrind_NAME}
        ${Memcheck_SUDOCMD} ${VALGRIND_PATH} ${VALGRIND_SUPP} ${Helgrind_VALGRIND_ARGS}
                         --tool=helgrind
                         --error-limit=no
#                         -v
                         --gen-suppressions=all
                         --child-silent-after-fork=yes
                         --trace-children=no
                          ${Helgrind_EXECUTABLE} ${Helgrind_EXECUTABLE_ARGS}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        DEPENDS ${Helgrind_DEPENDENCIES}
        COMMENT "Running valgrind for thread check."
    )

endfunction(SETUP_TARGET_FOR_VALGRIND_HELGRIND)

# Builds dependencies, runs the given executable and outputs reports.
#
# SETUP_TARGET_FOR_HELGRIND_VALGRIND_XML(
#     NAME ctest_helgrind                    # New target name
#     EXECUTABLE ctest -j ${PROCESSOR_COUNT} # Executable in PROJECT_BINARY_DIR
#     DEPENDENCIES executable_target         # Dependencies to build first
# )
function(SETUP_TARGET_FOR_VALGRIND_HELGRIND_XML)

    set(options NONE)
    set(oneValueArgs NAME)
    set(multiValueArgs VALGRIND_ARGS EXECUTABLE EXECUTABLE_ARGS SUPPRESSIONS DEPENDENCIES)
    cmake_parse_arguments(Helgrind "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT VALGRIND_PATH)
        message(FATAL_ERROR "Valgrind not found! Aborting...")
    endif()

    # build valgrind command
    if (NOT ${Helgrind_SUPPRESSIONS} STREQUAL "" AND EXISTS ${Helgrind_SUPPRESSIONS})
       set(VALGRIND_SUPP "--suppressions=${Helgrind_SUPPRESSIONS}")
    endif()

    # run valgrind helgrind
    add_custom_target(${Helgrind_NAME}
        ${VALGRIND_PATH} ${VALGRIND_SUPP} ${Helgrind_VALGRIND_ARGS}
                         --tool=helgrind
                         --error-limit=no
#                         -v
                         --gen-suppressions=all
                         --child-silent-after-fork=yes --trace-children=no
                         --xml=yes --xml-file=${PROJECT_BINARY_DIR}/valgrind.helgrind.xml
                          ${Helgrind_EXECUTABLE} ${Helgrind_EXECUTABLE_ARGS}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        DEPENDS ${Helgrind_DEPENDENCIES}
        COMMENT "Running valgrind for thread check."
    )

    # show comment where to find the report
    add_custom_command(TARGET ${Helgrind_NAME} POST_BUILD
        COMMAND ;
        COMMENT "Open ./valgrind.helgrind.xml in your browser to view the threadcheck log."
    )

endfunction(SETUP_TARGET_FOR_VALGRIND_HELGRIND_XML)
