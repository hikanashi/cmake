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
# 2020-03-23, hikanashi
# - initial version
#
# USAGE:
#
# 1. Copy this file into your cmake modules path.
#
# 2. Add the following line to your CMakeLists.txt:
#      include(vcpkgtoolchain)
#
# 3. Append vcpkg_init()
#
# EXSAMPLE:
# include(vcpkgtoolchain)
# vcpkg_init(pthread pcre openssl curl[tool,non-http,http2,openssl] jansson libevent[core,openssl,thread] protobuf grpc)
#

# find script
if(WIN32)
	find_file(
		VCPKG_INSTALL vcpkg_install.bat
		PATHS ${CMAKE_CURRENT_LIST_DIR}/scripts
		DOC "Find install script..."
		NO_DEFAULT_PATH
		NO_CMAKE_ENVIRONMENT_PATH
		NO_CMAKE_PATH
		NO_SYSTEM_ENVIRONMENT_PATH
		NO_CMAKE_SYSTEM_PATH
	)
else()
	find_file(
		VCPKG_INSTALL vcpkg_install.sh
		PATHS ${CMAKE_CURRENT_LIST_DIR}/scripts
		DOC "Find install script..."
		NO_DEFAULT_PATH
		NO_CMAKE_ENVIRONMENT_PATH
		NO_CMAKE_PATH
		NO_SYSTEM_ENVIRONMENT_PATH
		NO_CMAKE_SYSTEM_PATH
	)
endif()

if(NOT VCPKG_INSTALL)
	message(FATAL_ERROR "Not Found vcpkg_install script")
endif()


# Setting toolchain for vckpg.
# If the environment variable VCPKG_ROOT is set, set the toolchain under VCPKG_ROOT.
# If the vcpkg directory already exists under $ {CMAKE_SOURCE_DIR}, set that toolchain.
# If the vcpkg directory does not exist, install vcpkg and necessary packages under $ {CMAKE_SOURCE_DIR}.
#
# vcpkg_init(arg)
#     arg : packagename
macro(vcpkg_init)
	string(REPLACE ";" " " PACKAGELIST "${ARGN}")

	execute_process(
			COMMAND /bin/bash -x ${VCPKG_INSTALL} ${PACKAGELIST}
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			ENCODING AUTO)

	if(DEFINED CMAKE_TOOLCHAIN_FILE)
		message("already toolchain file ${CMAKE_TOOLCHAIN_FILE}")
	elseif(DEFINED ENV{VCPKG_ROOT})
		set(CMAKE_TOOLCHAIN_FILE $ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake CACHE STRING "")
		message("set VCPKG_ROOT. so set toolchain file ${CMAKE_TOOLCHAIN_FILE}")
	elseif(EXISTS "${CMAKE_SOURCE_DIR}/vcpkg")
		set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake CACHE STRING "")
		message("exist vcpkg dir. so set toolchain file ${CMAKE_TOOLCHAIN_FILE}")
	else()
		message(ERROR "not exist vcpkg dir. so install vcpkg.(${PACKAGELIST})")
	endif()

	include(${CMAKE_TOOLCHAIN_FILE})

endmacro() 
