cmake_minimum_required(VERSION 3.13.4)

project(libvpx)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(CONFIGURE_COMMAND_VAL
        sed -i "s@v141@v140@g" build/make/gen_msvs_vcxproj.sh
        && sed -i "26s@^\\(.\\{10\\}\\)@\\1C:/tools/cygwin/bin/perl @" libs.mk
        && sed -i "s@cp -p@cp@" build/make/Makefile
        && if not exist _build mkdir _build
        && cd _build
        && bash ./../configure ${CONFIGURE_PARAMS_LIST}
    )

    set(BUILD_COMMAND_VAL
        cd _build
        && bash -c "make"
    )

    set(INSTALL_COMMAND_VAL
        cd _build
        && bash -c "make install"
    )

    set(LIB_SUFFIX "Win32")

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
    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://github.com/webmproject/libvpx/archive/v1.8.2.zip

    DOWNLOAD_NAME
        vpx-v1.8.2.zip

    URL_HASH
        MD5=41df1f8f0a34ed36636c13ae9e0d864e

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
    external_version        "1.8.2"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ""
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib/${LIB_SUFFIX}
)
ListingToExternals(${PROJECT_NAME})
