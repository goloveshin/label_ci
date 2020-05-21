cmake_minimum_required(VERSION 3.13.4)


if (CMAKE_BUILD_TYPE MATCHES Release)
    set(VARIANT "release")
    set(SYMBOLS "off")
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
    set(VARIANT "debug")
    set(SYMBOLS "on")
elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(VARIANT "release")
    set(SYMBOLS "on")
endif ()

get_target_property(LIB__ICU__ROOT_DIR icu_interface external_root_path)

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64 OR
    CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    set(TOOLSET_BUILD "toolset=msvc-14.0")

    set(DEFINE
        "define=BOOST_USE_WINDOWS_H"
        "define=NOMINMAX"
    )

    if (SERVER_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_32)
        set(ADDRESS_MODEL 32)
    else ()
        set(ADDRESS_MODEL 64)
    endif ()

    if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)
        set(LAYOUT "--layout=system")
    endif ()
    
    set(IS_DLL_PATH "")
    set(DLL_PATH "")

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(TOOLSET_BOOTSTRAP "--with-toolset=clang")
        set(TOOLSET_BUILD "toolset=clang")
        set(LINK_FLAGS "linkflags=-stdlib=libc++ -Wl,--enable-new-dtags")
    else ()
        set(TOOLSET_BOOTSTRAP "--with-toolset=gcc")
        set(TOOLSET_BUILD "toolset=gcc")
        set(LINK_FLAGS "linkflags=-Wl,--enable-new-dtags")
    endif()

    set(ADDRESS_MODEL 64)

    set(CXX_FLAGS "cxxflags=-std=c++0x")

    set(CONFIGURE_PARAMS_LIST_B2
        # `./bootstrap.sh' creates minimal Boost.Build, which can install itself.
        # 
        # Usage: ./bootstrap.sh [OPTION]... 
        # 
        # Defaults for the options are specified in brackets.
        # 
        # Configuration:
        #   -h, --help                display this help and exit
        #   --with-b2=B2              use existing Boost.Build executable (b2)
        #                             [automatically built]
        #   --with-toolset=TOOLSET    use specific Boost.Build toolset
        #                             [automatically detected]
        "${TOOLSET_BOOTSTRAP}"
    )

    set(IS_DLL_PATH "hardcode-dll-paths=true")
    set(DLL_PATH "dll-path='\$ORIGIN'")

elseif (CLIENT_FOR_MACOS)

    set(TOOLSET_BOOTSTRAP "--with-toolset=clang")
    set(TOOLSET_BUILD "toolset=clang")
    set(LINK_FLAGS "")

    set(ADDRESS_MODEL 64)

    set(CXX_FLAGS "cxxflags=-std=c++0x")

    set(CONFIGURE_PARAMS_LIST_B2
        # `./bootstrap.sh' creates minimal Boost.Build, which can install itself.
        # 
        # Usage: ./bootstrap.sh [OPTION]... 
        # 
        # Defaults for the options are specified in brackets.
        # 
        # Configuration:
        #   -h, --help                display this help and exit
        #   --with-b2=B2              use existing Boost.Build executable (b2)
        #                             [automatically built]
        #   --with-toolset=TOOLSET    use specific Boost.Build toolset
        #                             [automatically detected]
        "${TOOLSET_BOOTSTRAP}"
    )

    set(IS_DLL_PATH "")
    set(DLL_PATH "")

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(TOOLSET_BOOTSTRAP "--with-toolset=clang")
        set(TOOLSET_BUILD "toolset=clang")
        set(LINK_FLAGS "linkflags=-stdlib=libc++ -Wl,--enable-new-dtags")
    else ()
        set(TOOLSET_BOOTSTRAP "--with-toolset=gcc")
        set(TOOLSET_BUILD "toolset=gcc")
        set(LINK_FLAGS "linkflags=-Wl,--enable-new-dtags")
    endif()

    if (CLIENT_FOR_LINUX_32)
        set(ADDRESS_MODEL 32)
    else ()
        set(ADDRESS_MODEL 64)
    endif ()

    set(LAYOUT "--layout=system")

    set(CXX_FLAGS "cxxflags=-std=c++0x")

    set(CONFIGURE_PARAMS_LIST_B2
        # `./bootstrap.sh' creates minimal Boost.Build, which can install itself.
        # 
        # Usage: ./bootstrap.sh [OPTION]... 
        # 
        # Defaults for the options are specified in brackets.
        # 
        # Configuration:
        #   -h, --help                display this help and exit
        #   --with-b2=B2              use existing Boost.Build executable (b2)
        #                             [automatically built]
        #   --with-toolset=TOOLSET    use specific Boost.Build toolset
        #                             [automatically detected]
        "${TOOLSET_BOOTSTRAP}"
    )

    set(IS_DLL_PATH "hardcode-dll-paths=true")
    set(DLL_PATH "dll-path='\$ORIGIN'")

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

# see 'https://boostorg.github.io/build/manual/develop/index.html#bbv2.overview.invocation.properties'
set(CONFIGURE_PARAMS_LIST
    "--prefix=${INSTALL_DIR}"

    "${TOOLSET_BUILD}"

    # [release,debug]
    "variant=${VARIANT}"

    # [on,off]
    "debug-symbols=${SYMBOLS}"

    # [single,multi]
    "threading=multi"

    # [32,64]
    "address-model=${ADDRESS_MODEL}"

    # [shared,static]
    "link=shared"

    # [shared,static]
    "runtime-link=shared"

    "--without-container" 
    "--without-context"
    "--without-coroutine"
    "--without-coroutine2"
    "--without-exception"
    "--without-graph"
    "--without-graph_parallel"
    "--without-log"
    "--without-math"
    "--without-mpi"
    "--without-python"
    "--without-serialization"
    "--without-type_erasure"
    "--without-wave"

    "boost.locale.iconv=off"
    "boost.locale.icu=on"
    
    "${CXX_FLAGS}"

    "${LINK_FLAGS}"

    "${DEFINE}"

    "${LAYOUT}"

    "${IS_DLL_PATH}"
    "${DLL_PATH}"

    "-sICU_PATH=${LIB__ICU__ROOT_DIR}"
)
