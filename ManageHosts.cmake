# Copyright (c) 2020 hikanashi
# 
# Permission is hereby granted, free of charge, to any person obtaining a 
# copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to 
# permit persons to whom the Software is furnished to do so, subject to 
# the following conditions:
# 
# The above copyright notice and this permission notice shall be 
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# CHANGES:
#
# 2020-03-16, hikanashi
# - append hosts update.
#
# USAGE:
#
# 1. Copy this file into your cmake modules path.
#
# 2. Add the following line to your CMakeLists.txt:
#      include(ManageHosts)
#
# 3. Append hosts setting:
#       UPDATE_HOSTS(
#           HOSTIP "exsample.com 127.0.0.1"
#		    HOSTIP "exsample2.com 127.0.0.1"
#       )
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
