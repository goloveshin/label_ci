cmake_minimum_required(VERSION 3.13.4)

project(libvorbis)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

get_target_property(LIB__OGG__INCLUDE_DIR libogg_interface external_inc_path)
get_target_property(LIB__OGG__LIBRARY_DIR libogg_interface external_lib_path)

if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    if (CLIENT_FOR_WINDOWS_32)
        set(PLATFORM Win32)
    else ()
        set(PLATFORM x64)
        message(FATAL_ERROR "Not implemented yet") 
    endif ()

    set(CONFIGURE_COMMAND_VAL
        ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/libogg.props win32/VS2010
    )

    set(BUILD_COMMAND_VAL
        cd win32/VS2010
        && ${CMAKE_COMMAND} -E remove_directory Backup
        && devenv vorbis_dynamic.sln /Upgrade
        && msbuild vorbis_dynamic.sln /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}
    )

    set(INSTALL_COMMAND_VAL ""
        ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}/bin ${INSTALL_DIR}/lib ${INSTALL_DIR}/include
        && ${CMAKE_COMMAND} -E copy_directory include ${INSTALL_DIR}/include
        && ${CMAKE_COMMAND} -E copy_directory win32/VS2010/${PLATFORM}/${CMAKE_BUILD_TYPE} ${INSTALL_DIR}/lib
        && ${CMAKE_COMMAND} -E copy_directory win32/VS2010/${PLATFORM}/${CMAKE_BUILD_TYPE} ${INSTALL_DIR}/bin
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
        libogg_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.6.tar.xz

    DOWNLOAD_NAME
        vorbis-1.3.6.tar.xz

    URL_HASH
        MD5=b7d1692f275c73e7833ed1cc2697cd65

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
    external_version        "1.3.6"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
