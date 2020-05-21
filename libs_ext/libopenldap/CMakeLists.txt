cmake_minimum_required(VERSION 3.13.4)

project(libopenldap)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

get_target_property(LIB__OPENSSL__INCLUDE_DIR libopenssl_1_0_x_interface external_inc_path)
get_target_property(LIB__OPENSSL__LIBRARY_DIR libopenssl_1_0_x_interface external_lib_path)

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)

    if (SERVER_FOR_WINDOWS_32)
        set(PLATFORM Win32)
    else ()
        set(PLATFORM x64)
    endif ()

    set(BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME})

    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(VARIANT "Release")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(VARIANT "Debug")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(VARIANT "Release")
        message(FATAL_ERROR "Not implemented yet")
    endif ()

    set(CONFIGURE_COMMAND_VAL
        cd ${CMAKE_CURRENT_SOURCE_DIR}/cmake/openldap_winpatch
        && ${CMAKE_COMMAND} -E copy Makefile.win ${BINARY_DIR}
        && ${CMAKE_COMMAND} -E copy_directory include ${BINARY_DIR}/include
        && ${CMAKE_COMMAND} -E copy_directory libraries ${BINARY_DIR}/libraries
        && cd ${BINARY_DIR}/include
        && cp lber_types.nt lber_types.h
        && cp ldap_config.nt ldap_config.h
        && cp ldap_features.nt ldap_features.h
        && cp portable.nt portable.h
        && sed -i "s@#define vsnprintf _vsnprintf@@g" portable.h
        && sed -i "s@#define snprintf _snprintf@@g" portable.h
    )

    set(BUILD_COMMAND_VAL
        nmake -f Makefile.win ARCH=${PLATFORM}\ ${VARIANT} PREFIX=${INSTALL_DIR} APPEND_CPPFLAGS=-I\"${LIB__OPENSSL__INCLUDE_DIR}\" APPEND_LDFLAGS=/LIBPATH:\"${LIB__OPENSSL__LIBRARY_DIR}\" buildall
    )

    set(INSTALL_COMMAND_VAL
        nmake -f Makefile.win ARCH=${PLATFORM}\ ${VARIANT} PREFIX=${INSTALL_DIR} installall
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(CONFIGURE_COMMAND_VAL
        export APPEND_CFLAGS=-I${LIB__OPENSSL__INCLUDE_DIR}
        && export APPEND_CXXFLAGS=-I${LIB__OPENSSL__INCLUDE_DIR}
        && export APPEND_CPPFLAGS=-I${LIB__OPENSSL__INCLUDE_DIR}
        && export APPEND_LDFLAGS=-L${LIB__OPENSSL__LIBRARY_DIR}\ -Wl,-z,origin\ -Wl,-rpath,'$$ORIGIN'\ -Wl,--enable-new-dtags
        && . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./configure ${CONFIGURE_PARAMS_LIST}
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make depend -j${EXTERNAL_BUILD_JOBS}
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
        libopenssl_1_0_x_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.48.tgz

    DOWNLOAD_NAME
        openldap-2.4.48.tgz

    URL_HASH
        MD5=0729a0711fe096831dedc159e0bbe73f

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
    external_version        "2.4.48"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
