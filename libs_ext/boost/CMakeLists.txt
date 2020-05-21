cmake_minimum_required(VERSION 3.13.4)

project(boost)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64 OR
    CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    set(CONFIGURE_COMMAND_VAL
        (if exist x: (echo 'drive x: exist, delete it' && subst x: /D) else (echo 'drive x: not exist'))
        && subst x: ${CMAKE_CURRENT_BINARY_DIR}/src
        && cd /D x:/boost_ext
        && call bootstrap.bat
    )

    set(BUILD_COMMAND_VAL
        (if exist x: (echo 'drive x: exist, delete it' && subst x: /D) else (echo 'drive x: not exist'))
        && subst x: ${CMAKE_CURRENT_BINARY_DIR}/src
        && cd /D x:/boost_ext
        && b2 -j${EXTERNAL_BUILD_JOBS} ${CONFIGURE_PARAMS_LIST} install
    )

    if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)
        set(INCLUDE_SUFFIX "boost-1_62")
    endif ()

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    set(CONFIGURE_COMMAND_VAL
        cd tools/build
        && ./bootstrap.sh ${CONFIGURE_PARAMS_LIST_B2}
        && ./b2 install --prefix=${CMAKE_CURRENT_BINARY_DIR}/b2
    )

    set(BUILD_COMMAND_VAL
        ${CMAKE_CURRENT_BINARY_DIR}/b2/bin/b2 -j${EXTERNAL_BUILD_JOBS} ${CONFIGURE_PARAMS_LIST} install
    )

elseif (CLIENT_FOR_MACOS)

    set(CONFIGURE_COMMAND_VAL
        cd tools/build
        && ./bootstrap.sh ${CONFIGURE_PARAMS_LIST_B2}
        && ./b2 install --prefix=${CMAKE_CURRENT_BINARY_DIR}/b2
    )

    set(BUILD_COMMAND_VAL
        ${CMAKE_CURRENT_BINARY_DIR}/b2/bin/b2 -j${EXTERNAL_BUILD_JOBS} ${CONFIGURE_PARAMS_LIST} install
    )

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    set(CONFIGURE_COMMAND_VAL
        cd tools/build
        && ./bootstrap.sh ${CONFIGURE_PARAMS_LIST_B2}
        && ./b2 install --prefix=${CMAKE_CURRENT_BINARY_DIR}/b2
    )

    set(BUILD_COMMAND_VAL
        ${CMAKE_CURRENT_BINARY_DIR}/b2/bin/b2 -j${EXTERNAL_BUILD_JOBS} ${CONFIGURE_PARAMS_LIST} install
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS
        icu_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.bz2/download

    DOWNLOAD_NAME
        boost_1_62_0.tar.bz2

    URL_HASH
        MD5=5fb94629535c19e48703bdb2b2e9490f

    #--Configure step-------------
    CONFIGURE_COMMAND
        ${CONFIGURE_COMMAND_VAL}

    #--Build step-----------------
    BUILD_COMMAND
        ${BUILD_COMMAND_VAL}

    #--Install step---------------
    INSTALL_COMMAND ""
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "1.62.0" # именно такая
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ""
    external_inc_path       ${INSTALL_DIR}/include/${INCLUDE_SUFFIX} # суффикс зависит от --layout
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
