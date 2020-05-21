cmake_minimum_required(VERSION 3.13.4)

project(MessangerCI)


set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

include(ExternalProject)

# external projects suffixes
set(EXTERNAL_PROJECT_SUFFIX "_ext")
set(EXTERNAL_PROJECT_INTERFACE_SUFFIX "_interface")


if (SERVER_FOR_DEBIAN_8_64)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_server.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Server Debian 8 x64 build!")
    message(STATUS "--------------------------------------------------")

    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lc++abi -lc++")
    endif()

elseif (SERVER_FOR_DEBIAN_9_64)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_server.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Server Debian 9 x64 build!")
    message(STATUS "--------------------------------------------------")

    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lc++abi -lc++")
    endif()

elseif (SERVER_FOR_WINDOWS_32)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_server.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Server Windows x86 build!")
    message(STATUS "--------------------------------------------------")

elseif (SERVER_FOR_WINDOWS_64)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_server.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Server Windows x64 build!")
    message(STATUS "--------------------------------------------------")

elseif (CLIENT_FOR_WINDOWS_32)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_server.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Client Windows x86 build!")
    message(STATUS "--------------------------------------------------")

elseif (CLIENT_FOR_MACOS)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_macos.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Client macOS build!")
    message(STATUS "--------------------------------------------------")

elseif (CLIENT_FOR_LINUX_32)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_linux.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Client Linux x86 build!")
    message(STATUS "--------------------------------------------------")

elseif (CLIENT_FOR_LINUX_64)

    set(ENV_WRAPPER_IN_FILE "env_wrapper_linux.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Client Linux x64 build!")
    message(STATUS "--------------------------------------------------")

elseif (CLIENT_FOR_ANDROID)

    message(FATAL_ERROR "Not implemented yet")

    set(ENV_WRAPPER_IN_FILE "env_wrapper_android.sh.in")

    message(STATUS "--------------------------------------------------")
    message(STATUS "Hello from Android build!")
    message(STATUS "--------------------------------------------------")
    message(STATUS "ANDROID_ABI                              : ${ANDROID_ABI}")
    message(STATUS "ANDROID_TOOLCHAIN                        : ${ANDROID_TOOLCHAIN}")
    message(STATUS "ANDROID_ARM_MODE                         : ${ANDROID_ARM_MODE}")
    message(STATUS "ANDROID_ARM_NEON                         : ${ANDROID_ARM_NEON}")
    message(STATUS "ANDROID_PLATFORM_LEVEL                   : ${ANDROID_PLATFORM_LEVEL}")
    message(STATUS "ANDROID_LLVM_TRIPLE                      : ${ANDROID_LLVM_TRIPLE}")
    message(STATUS "ANDROID_CPP_FEATURES                     : ${ANDROID_CPP_FEATURES}")
    message(STATUS "ANDROID_STL                              : ${ANDROID_STL}")

elseif (CLIENT_FOR_IOS)

    message(FATAL_ERROR "Not implemented yet")

    # message(STATUS "-------------------------")
    # message(STATUS "Hello from iOS build!")
    # message(STATUS "-------------------------")

    # # тулчейн выставляет arm7 armv7s arm64
    # # set(CMAKE_OSX_ARCHITECTURES arm7 armv7s arm64)

    # set(ENV_WRAPPER_IN_FILE "env_wrapper_ios.sh.in")

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

    message(STATUS "--------------------------------------------------")
    message(STATUS "Common CMake environment ")
    message(STATUS "--------------------------------------------------")
    message(STATUS "--- build system ---")
    message(STATUS "CMAKE_BUILD_TYPE                         : ${CMAKE_BUILD_TYPE}")
    message(STATUS "CMAKE_SYSROOT                            : ${CMAKE_SYSROOT}")
    message(STATUS "CMAKE_LIBRARY_ARCHITECTURE               : ${CMAKE_LIBRARY_ARCHITECTURE}")
    message(STATUS "--- compiler/linker ---")
    message(STATUS "CMAKE_C_COMPILER                         : ${CMAKE_C_COMPILER}")
    message(STATUS "CMAKE_C_COMPILER_TARGET                  : ${CMAKE_C_COMPILER_TARGET}")
    message(STATUS "CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN      : ${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN}")
    message(STATUS "CMAKE_CXX_COMPILER                       : ${CMAKE_CXX_COMPILER}")
    message(STATUS "CMAKE_CXX_COMPILER_TARGET                : ${CMAKE_CXX_COMPILER_TARGET}")
    message(STATUS "CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN    : ${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}")
    message(STATUS "CMAKE_LINKER                             : ${CMAKE_LINKER}")
    message(STATUS "CMAKE_OBJCOPY                            : ${CMAKE_OBJCOPY}")
    message(STATUS "CMAKE_OBJDUMP                            : ${CMAKE_OBJDUMP}")
    message(STATUS "CMAKE_RANLIB                             : ${CMAKE_RANLIB}")
    message(STATUS "CMAKE_AR                                 : ${CMAKE_AR}")
    message(STATUS "--- flags ---")
    message(STATUS "CMAKE_C_FLAGS                            : ${CMAKE_C_FLAGS}")
    message(STATUS "CMAKE_CXX_FLAGS                          : ${CMAKE_CXX_FLAGS}")
    message(STATUS "CMAKE_ASM_FLAGS                          : ${CMAKE_ASM_FLAGS}")
    message(STATUS "CMAKE_C_FLAGS_DEBUG                      : ${CMAKE_C_FLAGS_DEBUG}")
    message(STATUS "CMAKE_CXX_FLAGS_DEBUG                    : ${CMAKE_CXX_FLAGS_DEBUG}")
    message(STATUS "CMAKE_ASM_FLAGS_DEBUG                    : ${CMAKE_ASM_FLAGS_DEBUG}")
    message(STATUS "CMAKE_C_FLAGS_RELEASE                    : ${CMAKE_C_FLAGS_RELEASE}")
    message(STATUS "CMAKE_CXX_FLAGS_RELEASE                  : ${CMAKE_CXX_FLAGS_RELEASE}")
    message(STATUS "CMAKE_ASM_FLAGS_RELEASE                  : ${CMAKE_ASM_FLAGS_RELEASE}")
    message(STATUS "CMAKE_SHARED_LINKER_FLAGS                : ${CMAKE_SHARED_LINKER_FLAGS}")
    message(STATUS "CMAKE_MODULE_LINKER_FLAGS                : ${CMAKE_MODULE_LINKER_FLAGS}")
    message(STATUS "CMAKE_EXE_LINKER_FLAGS                   : ${CMAKE_EXE_LINKER_FLAGS}")
    message(STATUS "--- directories ---")
    message(STATUS "CMAKE_C_IMPLICIT_LINK_DIRECTORIES        : ${CMAKE_C_IMPLICIT_LINK_DIRECTORIES}")
    message(STATUS "CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES      : ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES}")
    message(STATUS "CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES     : ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}")
    message(STATUS "CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES   : ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES}")


# outputs
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}")
set(CMAKE_INSTALL_PREFIX "${EXTERNAL_INSTALL_PATH}")

# TODO not here
define_property(TARGET PROPERTY external_version
    BRIEF_DOCS "version for external"
    FULL_DOCS "version for external"
)
define_property(TARGET PROPERTY external_root_path
    BRIEF_DOCS "root dir for external"
    FULL_DOCS "root for external"
)
define_property(TARGET PROPERTY external_bin_path
    BRIEF_DOCS "bin dir for external"
    FULL_DOCS "bin for external"
)
define_property(TARGET PROPERTY external_inc_path
    BRIEF_DOCS "include dir for external"
    FULL_DOCS "include for external"
)
define_property(TARGET PROPERTY external_lib_path
    BRIEF_DOCS "lib dir for external"
    FULL_DOCS "lib dir for external"
)
define_property(GLOBAL PROPERTY external_projects
    BRIEF_DOCS "list of external"
    FULL_DOCS "list of external"
)
define_property(TARGET PROPERTY external_prefix_path
    BRIEF_DOCS "prefix dir for external for CMake"
    FULL_DOCS "prefix dir for external for CMake"
)

if (BUILD_LIBS_EXT_MODE)

    message(STATUS "--------------------------------------------------")
    message(STATUS "Dependencies build mode")
    message(STATUS "--------------------------------------------------")

    add_subdirectory(libs_ext)

else ()

    message(STATUS "--------------------------------------------------")
    message(STATUS "Project build mode")
    message(STATUS "--------------------------------------------------")

endif ()
