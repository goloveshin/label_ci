cmake_minimum_required(VERSION 3.13.4)

if (SERVER_FOR_WINDOWS_32)
    set(PLATFORM "--32")
else ()
    set(PLATFORM "--64")
endif ()

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)
    set(DYNAMIC_WINDOWS "--dynamic-windows")
    set(DYNAMIC_BOOST "--dynamic-boost")
    set(SHARED_CLIENT "--sharedclient")
endif ()

if (CMAKE_BUILD_TYPE MATCHES Release)
    set(DBG "off")
    set(OPT "on")
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
    set(DBG "on")
    set(OPT "off")
elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(DBG "on")
    set(OPT "on")
endif ()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(FLAGS "--libc++")
endif()

get_target_property(LIB__BOOST__ROOT_DIR boost_interface external_root_path)
get_target_property(LIB__BOOST__INCLUDE_DIR boost_interface external_inc_path)
get_target_property(LIB__BOOST__LIBRARY_DIR boost_interface external_lib_path)

set(CONFIGURE_PARAMS_LIST
    # --prefix=<path> The directory prefix for the installation directory.
    "--prefix=${INSTALL_DIR}"

    # --cpppath=<path-to-headers> Specifies path to additional headers.
    "--cpppath=${LIB__BOOST__INCLUDE_DIR}"

    # --libpath=<path-to-libs> Specifies path to additional libraries.
    "--libpath=${LIB__BOOST__LIBRARY_DIR}"

    # --dbg=[on|off] Enables runtime debugging checks. Defaults to off. Specifying --dbg=on implies --opt=off unless explicitly overridden with --opt=on.
    "--dbg=${DBG}"

    # --opt=[on|off] Enables compile-time optimization. Defaults to on. Can be freely mixed with the values for the --dbg flag.
    "--opt=${OPT}"

    # --extrapath=<path-to-boost> Specifies the path to your Boost libraries if they are not in a standard search path for your toolchain.
    "--extrapath=${LIB__BOOST__ROOT_DIR}"

    # --c++11=[on|off] Builds the driver in C++11 mode. Defaults to off. Please see the note above about requirements for using C++11.
    "--c++11=on"

    # -j N Compile with N cores
    "-j${EXTERNAL_BUILD_JOBS}"

    # --cc The compiler to use for C. Use the following syntax: --cc=<path-to-c-compiler>

    # --cxx The compiler to use for C++. Use the following syntax: --cxx=<path-to-c++-compiler>

    "--disable-warnings-as-errors"

    # --libc++ Builds the driver against the libc++ C++ runtime library. Please see the note above about requirements for the C++ runtime library.
    ${FLAGS}
    
    ${PLATFORM}

    # dynamically link on Windows
    ${DYNAMIC_WINDOWS}

    # dynamically link boost libraries on Windows
    ${DYNAMIC_BOOST}

    ${SHARED_CLIENT}
    
    # Linux use static
    # TODO check Darwin
    # "--runtime-library-search-path=-Wl,-z,origin -Wl,-rpath,'\$ORIGIN'" -Wl,--enable-new-dtags
)
