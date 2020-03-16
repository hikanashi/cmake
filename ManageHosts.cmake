# Manage hosts file
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# CHANGES:
#
# 2020-03-17, Hiroyuki Fujita
# - Enable hosts manager for Windows
#
#
# USAGE:
#
# 1. Copy this file into your cmake modules path.
#
# 2. Add the following line to your CMakeLists.txt:
#      include(ManageHosts)
#
# 3. Append necessary compiler flags:
#      APPEND_COVERAGE_COMPILER_FLAGS()
#
# 3.a (OPTIONAL) Set appropriate optimization flags, e.g. -O0, -O1 or -Og
#
# 4. If you need to exclude additional directories from the report, specify them
#    using the COVERAGE_LCOV_EXCLUDES variable before calling SETUP_TARGET_FOR_COVERAGE_LCOV.
#    Example:
#      set(COVERAGE_LCOV_EXCLUDES 'dir1/*' 'dir2/*')
#
# 5. Use the functions described below to create a custom make target which
#    runs your test executable and produces a code coverage report.
#
# 6. Build a Debug build:
#      cmake -DCMAKE_BUILD_TYPE=Debug ..
#      make
#      make my_coverage_target
#

include(CMakeParseArguments)

# Check hosts script
if(WIN32)
	set(HOSTS_PATH "C:/Windows/System32/drivers/etc/hosts")
else()
	set(HOSTS_PATH "/etc/hosts")
endif()


# Defines a target for running and collection code coverage information
# Builds dependencies, runs the given executable and outputs reports.
# NOTE! The executable should always have a ZERO as exit code otherwise
# the coverage generation will not complete.
#
# SETUP_TARGET_FOR_COVERAGE_LCOV(
#     NAME testrunner_coverage                    # New target name
#     EXECUTABLE testrunner -j ${PROCESSOR_COUNT} # Executable in PROJECT_BINARY_DIR
#     DEPENDENCIES testrunner                     # Dependencies to build first
# )
function(UPDATE_HOSTS)
    set(options NONE_OP)
    set(oneValueArgs NONE_OV)
    set(multiValueArgs HOSTIP)
    cmake_parse_arguments(Hosts "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	file(STRINGS ${HOSTS_PATH} HOSTS_FILE)
	set(HOSTS_UPDATE OFF)

	foreach(HOSTIP_RECORD IN LISTS Hosts_HOSTIP)
		string(REPLACE " " ";" HOSTIPLIST ${HOSTIP_RECORD})		
		list(GET HOSTIPLIST 0 HOSTNAME)
		list(GET HOSTIPLIST 1 HOSTIP)

#		message("ip: ${HOSTIP} host:${HOSTNAME}")
		UPDATE_HOSTIP("${HOSTS_FILE}" ${HOSTNAME} ${HOSTIP} HOSTS_UPDATE)
	endforeach()

	if(NOT HOSTS_UPDATE)
		message("No need to update hosts")
		return()
	endif()

	set(TMP_HOSTS ${CMAKE_BINARY_DIR}/hosts)
	#file(COPY ${HOSTS_PATH} DESTINATION ${CMAKE_BINARY_DIR})
	string(REGEX REPLACE ";" "\n" HOSTS_FILE "${HOSTS_FILE}")
	file(WRITE ${TMP_HOSTS} "${HOSTS_FILE}")

	
	if(WIN32)
		# On Windows10, the automatic replacement(include copy) of hosts is access rejected.
		# so, manually copy the automatically generated hosts.
		message("Please COPY hosts file. from ${TMP_HOSTS} to ${HOSTS_PATH}")

		string(REPLACE "/" "\\" HOSTS_PATH "${HOSTS_PATH}")
		string(REPLACE "/" "\\" TMP_HOSTS "${TMP_HOSTS}")

		# Open Explorer Copy Directry
		execute_process(
			COMMAND ${CMAKE_CURRENT_LIST_DIR}/scripts/explorer.bat ${TMP_HOSTS} ${HOSTS_PATH}
			ENCODING AUTO)
	else()
		string(TIMESTAMP COPYTIME %Y%m%d_%H%M%S)
		set(ORIGINAL_HOSTS "${HOSTS_PATH}.${COPYTIME}")

		message("backup hosts. from ${HOSTS_PATH} to ${ORIGINAL_HOSTS}")
		execute_process(
			COMMAND sudo cp -p ${HOSTS_PATH} ${ORIGINAL_HOSTS}
			ENCODING AUTO)

		message("copy hosts. from ${TMP_HOSTS} to ${HOSTS_PATH}")
		execute_process(
			COMMAND sudo cp -p ${TMP_HOSTS} ${HOSTS_PATH}
			ENCODING AUTO)
	endif()
endfunction() 

function(UPDATE_HOSTIP HOSTS_FILE HOSTNAME HOSTIP HOSTS_UPDATE)
	
	set(UPDATE_HOSTS_FILE "")
	set(FOUND_HOST OFF)
	set(IS_UPDATE OFF)

	foreach(HOST_RECORD IN LISTS HOSTS_FILE)
		
#		message("HOST_RECORD:${HOST_RECORD}")

		# Delete comment field.
		string(FIND "${HOST_RECORD}" "#" COMMNETPOS)
		if( ${COMMNETPOS} LESS 0 )
			set(HOST_RECORD_WITHOUT_COMMENT ${HOST_RECORD})
		else()
			string(SUBSTRING ${HOST_RECORD} 0 ${COMMNETPOS} HOST_RECORD_WITHOUT_COMMENT)
		endif()

		# Check IP and Hostname
		if("${HOST_RECORD_WITHOUT_COMMENT}" MATCHES "([0-9A-Fa-f.:]+)[\ \t]+([0-9A-Za-z.:_-]+[\ \t]*[0-9A-Za-z.:_-]*)([\ \t]*#*.*)")
			set(TARGET_IP ${CMAKE_MATCH_1})
			set(TARGET_HOST ${CMAKE_MATCH_2})

#			message("HOST_RECORD_WITHOUT_COMMENT:${HOST_RECORD_WITHOUT_COMMENT}")
#			message("TARGET_IP:${TARGET_IP}")
#			message("TARGET_HOST:${TARGET_HOST}")

			# TargetHost not found
			string(REGEX REPLACE "[\ \t]+" ";" HOSTLIST "${TARGET_HOST}")
			list(FIND HOSTLIST "${HOSTNAME}" HOSTINDEX)
			if(${HOSTINDEX} LESS 0)
				# TargetHost isn't found. but IP is same.
				if("${TARGET_IP}" STREQUAL "${HOSTIP}")
					message("${HOSTIP} is found. appned ${HOSTNAME}")
					string(REPLACE "${TARGET_HOST}" "${TARGET_HOST} ${HOSTNAME} " HOST_RECORD "${HOST_RECORD}")
					list(APPEND UPDATE_HOSTS_FILE ${HOST_RECORD})
					set(FOUND_HOST ON)
					set(IS_UPDATE ON)
					continue()
				else()
#					message("${HOSTNAME} is not found. from: ${TARGET_HOST}")
					list(APPEND UPDATE_HOSTS_FILE ${HOST_RECORD})
					continue()
				endif()
			endif()

			# TargetHost and IP is same. 
			if("${TARGET_IP}" STREQUAL "${HOSTIP}")
				message("${HOSTNAME} is found. and IP(${HOSTIP}) is same.")
				list(APPEND UPDATE_HOSTS_FILE ${HOST_RECORD})
				set(FOUND_HOST ON)
				continue()
			endif()

			# TargetHost is found. but IP is defferent.
			# Check this record is only TargetHost.
			list(LENGTH HOSTLIST HOSTLIST_NUM)
			if(${HOSTLIST_NUM} GREATER 1)
				# another host is exist. remove target host.
				# and append TargetHost later.
				message("${HOSTNAME} is found. but differnt IP and another host exist. so delete ${HOSTNAME}")
				string(REPLACE "${TARGET_HOST}" "" HOST_RECORD ${HOST_RECORD})
				list(APPEND UPDATE_HOSTS_FILE ${HOST_RECORD})
				set(IS_UPDATE ON)
			else()
				# only TargetHost is replace IP.
				message("${HOSTNAME} is found. but differnt IP. so replace from ${TARGET_IP} to ${HOSTIP}")
				string(REPLACE "${TARGET_IP}" "${HOSTIP}" HOST_RECORD ${HOST_RECORD})
				list(APPEND UPDATE_HOSTS_FILE ${HOST_RECORD})
				set(FOUND_HOST ON)
				set(IS_UPDATE ON)
			endif()

		else()
			list(APPEND UPDATE_HOSTS_FILE ${HOST_RECORD})
		endif()
	endforeach()

	if(NOT FOUND_HOST)
		set(HOST_RECORD "${HOSTIP}\t\t${HOSTNAME}\n")
		message("${HOSTNAME}(${HOSTIP}) is not found. append record.")
		list(APPEND UPDATE_HOSTS_FILE ${HOST_RECORD})
		set(FOUND_HOST ON)
		set(IS_UPDATE ON)
	endif()
	
	if(IS_UPDATE)
		set(HOSTS_UPDATE ON PARENT_SCOPE)
		set(HOSTS_FILE "${UPDATE_HOSTS_FILE}" PARENT_SCOPE)
	endif()
endfunction()
