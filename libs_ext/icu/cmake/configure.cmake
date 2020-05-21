cmake_minimum_required(VERSION 3.13.4)

if (CMAKE_BUILD_TYPE MATCHES Release)
    set(DEBUG "--disable-debug")
    set(RELEASE "--enable-release")
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
    set(DEBUG "--enable-debug")
    set(RELEASE "--disable-release")
elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(DEBUG "--disable-debug")
    set(RELEASE "--enable-release")
endif ()

if (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)
    set(PLATFORM "Linux")
elseif (CLIENT_FOR_MACOS)
    set(PLATFORM "MacOSX")
elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)
    set(PLATFORM "Linux")
endif ()

set(CONFIGURE_PARAMS_LIST
    ${PLATFORM}
    "--prefix=${INSTALL_DIR}"
    "--disable-static"
    "--enable-shared"
    ${DEBUG}
    ${RELEASE}
    "--enable-rpath"
)
