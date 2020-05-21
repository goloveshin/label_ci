cmake_minimum_required(VERSION 3.13.4)

project(libopenssl_1_0_x)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64 OR
    CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    if (SERVER_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_32)
        set(PLATFORM VC-WIN32)
        set(UPLINK   uplink-x86)
        set(BAT      do_ms)
    else ()
        set(PLATFORM VC-WIN64A)
        set(UPLINK   uplink-x86_64)
        set(BAT      do_win64a)
    endif ()

    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(DEBUG "")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(DEBUG "debug-")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(DEBUG "")
        message(FATAL_ERROR "Not implemented yet")
    endif ()

    set(CONFIGURE_COMMAND_VAL
        perl Configure ${DEBUG}${PLATFORM} --prefix=${INSTALL_DIR} --openssldir=${INSTALL_DIR} no-asm
        && sed -i "s@[.][.]@/..@g" ms/${UPLINK}.pl
    )

    set(BUILD_COMMAND_VAL
        .\\ms\\${BAT}.bat
        && nmake -f ms/ntdll.mak
    )

    set(INSTALL_COMMAND_VAL
        .\\ms\\${BAT}.bat
        && nmake -f ms/ntdll.mak install
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(DEBUG "")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(DEBUG "no-asm -g3 -O0 -ggdb -gdwarf-4 -fno-omit-frame-pointer -fno-inline -DDEBUG_SAFESTACK")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(DEBUG "")
        message(FATAL_ERROR "Not implemented yet")
    endif ()

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && sed -i "s@-shared -Wl,-Bsymbolic@-shared -Wl,-Bsymbolic -Wl,-z,origin -Wl,-rpath,\"$$\"ORIGIN -Wl,--enable-new-dtags@g" Makefile.shared
        && ./config shared ${DEBUG} --prefix=${INSTALL_DIR} --openssldir=${INSTALL_DIR}
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make depend -j${EXTERNAL_BUILD_JOBS}
        && make all -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make install -j1
    )

elseif (CLIENT_FOR_MACOS)

    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(DEBUG_PRE "")
        set(DEBUG_SUF "")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(DEBUG_PRE "-g3 -O0 -ggdb -gdwarf-4 -fno-omit-frame-pointer -fno-inline-functions -DDEBUG_SAFESTACK")
        set(DEBUG_SUF "no-asm")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(DEBUG_PRE "")
        set(DEBUG_SUF "")
        message(FATAL_ERROR "Not implemented yet")
    endif ()

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./Configure ${DEBUG_PRE} darwin64-x86_64-cc shared enable-ec_nistp_64_gcc_128 no-ssl2 no-ssl3 no-comp ${DEBUG_SUF} --prefix=${INSTALL_DIR} --openssldir=${INSTALL_DIR}
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make depend -j${EXTERNAL_BUILD_JOBS}
        && make all -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make install -j1
    )

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(DEBUG "")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(DEBUG "no-asm -g3 -O0 -ggdb -gdwarf-4 -fno-omit-frame-pointer -fno-inline -DDEBUG_SAFESTACK")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(DEBUG "")
    endif ()

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && sed -i "s@-shared -Wl,-Bsymbolic@-shared -Wl,-Bsymbolic -Wl,-z,origin -Wl,-rpath,\"$$\"ORIGIN -Wl,--enable-new-dtags@g" Makefile.shared
        && ./config shared ${DEBUG} --prefix=${INSTALL_DIR} --openssldir=${INSTALL_DIR} 
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make depend -j${EXTERNAL_BUILD_JOBS}
        && make all -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make install -j1
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz

    DOWNLOAD_NAME
        openssl-1.0.2u.tar.gz

    URL_HASH
        MD5=cdc2638f789ecc2db2c91488265686c1

    #--Configure step-------------
    CONFIGURE_COMMAND
        ${CONFIGURE_COMMAND_VAL}

    #--Build step-----------------
    BUILD_COMMAND
        ${BUILD_COMMAND_VAL}

    #--Install step---------------
    INSTALL_COMMAND
        ${INSTALL_COMMAND_VAL}
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "1.0.2u"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
