# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# CHANGES:
#
# 2019-11-14, hikanashi
# - Enable Sanitizer Option
#
# USAGE:
#
# 1. Copy this file into your cmake modules path.
# 1a.Add CMAKE_MODULE_PATH if necessary
#    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
#
# 2. Add the following line to your CMakeLists.txt:
#      include (SanitizerOption)
#
# 3. Use the functions described below to set sanitizer compile option.
#
# 4. Build a Debug build:
#      cmake -DCMAKE_BUILD_TYPE=Debug ..
#      make
#
# 5. set sanitizer option in test enviroment.
#    ex)
#      set_tests_properties(testPyMyproj PROPERTIES
#          ENVIRONMENT ASAN_OPTIONS=log_path=$<TARGET_FILE_DIR:myproject>/asan)
#    AddressSanitizer(ASAN_OPTIONS)
#        https://github.com/google/sanitizers/wiki/AddressSanitizerFlags
#    LeakSanitizer(LSAN_OPTIONS) 
#        https://github.com/google/sanitizers/wiki/AddressSanitizerLeakSanitizer
#    UndefinedBehaviorSanitizer(UBSAN_OPTIONS)
#        https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
#    ThreadSanitizer(TSAN_OPTIONS)
#        https://github.com/google/sanitizers/wiki/ThreadSanitizerFlags

include(CMakeParseArguments)

# APPEND_SANITIZER_COMPILER_FLAGS(
#     [ASAN ON]    # Enable AddressSanitizer
#     [LSAN ON]    # Enable LeakSanitizer
#     [UBSAN ON]   # Enable UndefinedBehaviorSanitizer
#     [TSAN ON]    # Enable ThreadSanitizer (can't be used with other Sanitizers)
# )
function(APPEND_SANITIZER_COMPILER_FLAGS)

    set(options NONE)
    set(oneValueArgs NONE2)
    set(multiValueArgs ASAN LSAN UBSAN TSAN)
    cmake_parse_arguments(Sanitize "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(MSVC)
        message(FATAL_ERROR "Compiler is not GNU gcc or clang! Aborting...")
    endif()

	set(SANITIZER_COMPILER_FLAGS "")

    if("${Sanitize_ASAN}" STREQUAL "ON")
        set(SANITIZER_COMPILER_FLAGS "${SANITIZER_COMPILER_FLAGS} -fsanitize=address")
    endif()

    if("${Sanitize_LSAN}" STREQUAL "ON")
        set(SANITIZER_COMPILER_FLAGS "${SANITIZER_COMPILER_FLAGS} -fsanitize=leak")
    endif()

    if("${Sanitize_UBSAN}" STREQUAL "ON")
        set(SANITIZER_COMPILER_FLAGS "${SANITIZER_COMPILER_FLAGS} -fsanitize=undefined")
    endif()

    if("${Sanitize_TSAN}" STREQUAL "ON")
        if(NOT ${SANITIZER_COMPILER_FLAGS} STREQUAL "")
            message(FATAL_ERROR "ThreadSanitizer cannot be used simultaneously with other Sanitizers")
        endif()
        set(SANITIZER_COMPILER_FLAGS "${SANITIZER_COMPILER_FLAGS} -fsanitize=thread")
    endif()

    if(NOT ${SANITIZER_COMPILER_FLAGS} STREQUAL "")
        set(SANITIZER_COMPILER_FLAGS "${SANITIZER_COMPILER_FLAGS} -fno-omit-frame-pointer")
    endif()

    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SANITIZER_COMPILER_FLAGS}" PARENT_SCOPE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SANITIZER_COMPILER_FLAGS}" PARENT_SCOPE)

    message(STATUS "Appending sanitizer compiler flags: ${SANITIZER_COMPILER_FLAGS}")
endfunction() # APPEND_SANITIZER_COMPILER_FLAGS

