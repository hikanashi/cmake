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
# - Enable Relative Path
#   https://stackoverflow.com/questions/237542/getting-base-name-of-the-source-file-at-compile-time
#
#
# USAGE:
#
# 1. Copy this file into your cmake modules path.
# 1a.Add CMAKE_MODULE_PATH if necessary
#    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})
#
# 2. Add the following line to your CMakeLists.txt:
#      include (DefineRelativeFilePaths)
#
# 3. Append necessary compiler flags:
#      cmake_append_nobuiltin_macro_compiler_flags()
#
# 4. Use the functions set source files properties
#      cmake_define_relative_file_paths ("${SOURCES}")
#
# 5. That's it. Now you can make pretty log messages.
#    #define ..._LOG_HEADER(target) \
#    fprintf(target, "%s %s:%u - ", __func__, __RELATIVE_FILE_PATH__, __LINE__);
#
# 5a. PS It is better to declear in config.h.in -> config.h
#    #ifndef __RELATIVE_FILE_PATH__
#    #define __RELATIVE_FILE_PATH__ __FILE__
#    #endif
#
# 6. Build a Debug build:
#      cmake -DCMAKE_BUILD_TYPE=Debug ..
#      make
#

function (cmake_define_relative_file_paths BASESOURCES)
  foreach (SOURCE IN LISTS BASESOURCES)
    file (
      RELATIVE_PATH RELATIVE_SOURCE_PATH
      ${PROJECT_SOURCE_DIR} ${SOURCE}
    )

    set_source_files_properties (
      ${SOURCE} PROPERTIES
      COMPILE_DEFINITIONS __RELATIVE_FILE_PATH__="${RELATIVE_SOURCE_PATH}"
    )
  endforeach ()
endfunction () # cmake_define_relative_file_paths

function(cmake_append_nobuiltin_macro_compiler_flags)
    if(NOT MSVC)
        add_compile_options(-Wno-builtin-macro-redefined)
    endif()
endfunction() # cmake_append_nobuiltin_macro_compiler_flags

