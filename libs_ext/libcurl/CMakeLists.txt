cmake_minimum_required(VERSION 3.13.4)

project(libcurl)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)

    if (SERVER_FOR_WINDOWS_32)
        set(PLATFORM x86)
    else ()
        set(PLATFORM x64)
    endif ()

    # must match DEBUG at cmake/configure.cmake
    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(DEBUG "release")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(DEBUG "debug")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(DEBUG "release")
    endif ()

    set(DEPENDS_VAL
        libopenssl_1_0_x_interface
        libopenldap_interface
    )

    set(CONFIGURE_COMMAND_VAL
        :
    )

    set(BUILD_COMMAND_VAL
        cd winbuild
        && sed -i "s@_debug@@g" MakefileBuild.vc
        && nmake /f Makefile.vc mode=dll ${CONFIGURE_PARAMS_LIST}
    )

    set(INSTALL_COMMAND_VAL
        ${CMAKE_COMMAND} -E copy_directory builds/libcurl-vc15-${PLATFORM}-${DEBUG}-dll-ssl-static-ipv6-sspi ${INSTALL_DIR}
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    get_target_property(LIB__OPENSSL__LIBRARY_DIR libopenssl_1_0_x_interface external_lib_path)

    set(DEPENDS_VAL
        libopenssl_1_0_x_interface
        libopenldap_interface
        libzlib_interface
    )

    set(CONFIGURE_COMMAND_VAL
        export APPEND_LDFLAGS=-Wl,-z,origin\ -Wl,-rpath,'$$ORIGIN'\ -Wl,--enable-new-dtags\ -Wl,-rpath-link,${LIB__OPENSSL__LIBRARY_DIR}
        && . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./configure ${CONFIGURE_PARAMS_LIST}
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make install -j${EXTERNAL_BUILD_JOBS}
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS
        ${DEPENDS_VAL}

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://curl.haxx.se/download/curl-7.68.0.tar.gz

    DOWNLOAD_NAME
        curl-7.68.0.tar.gz

    URL_HASH
        MD5=f68d6f716ff06d357f476ea4ea57a3d6

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
    external_version        "7.68.0"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
