cmake_minimum_required(VERSION 3.13.4)

project(sqlcipher)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

get_target_property(LIB__OPENSSL__INCLUDE_DIR libopenssl_1_0_x_interface external_inc_path)
get_target_property(LIB__OPENSSL__LIBRARY_DIR libopenssl_1_0_x_interface external_lib_path)

if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    if (CLIENT_FOR_WINDOWS_32)
        set(PLATFORM x86)
    else ()
        set(PLATFORM x64)
        message(FATAL_ERROR "Not implemented yet") 
    endif ()

    set(CONFIGURE_COMMAND_VAL
        :
    )

    set(BUILD_COMMAND_VAL
        ${CMAKE_COMMAND} -E make_directory build
        && cd build
        && nmake /f ../Makefile.msc sqlite3.dll TOP=.. PLATFORM=${PLATFORM} "OPTS=-DSQLITE_HAS_CODEC -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1 -I${LIB__OPENSSL__INCLUDE_DIR}" "LDOPTS=/LIBPATH:${LIB__OPENSSL__LIBRARY_DIR} libeay32.lib"
    )

    set(INSTALL_COMMAND_VAL
        ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}/lib ${INSTALL_DIR}/include/sqlcipher
        && cd build
        && ${CMAKE_COMMAND} -E copy sqlite3.lib sqlite3.dll ${INSTALL_DIR}/lib
        && ${CMAKE_COMMAND} -E copy sqlite3.h sqlite3ext.h ${INSTALL_DIR}/include/sqlcipher
    )

elseif (CLIENT_FOR_MACOS)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
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

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(CONFIGURE_COMMAND_VAL
        export APPEND_LDFLAGS=-Wl,-z,origin\ -Wl,-rpath,'$$ORIGIN'\ -Wl,--enable-new-dtags
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
        libopenssl_1_0_x_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://github.com/sqlcipher/sqlcipher/archive/v4.3.0.zip

    DOWNLOAD_NAME
        sqlcipher-v4.3.0.zip

    URL_HASH
        MD5=ee3b668d6e560583a2b96ef18d7433a1

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
    external_version        "4.3.0"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ""
    external_inc_path       ${INSTALL_DIR}/include/sqlcipher
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
