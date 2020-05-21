cmake_minimum_required(VERSION 3.13.4)

project(osxfuse)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
#        https://github.com/osxfuse/osxfuse/archive/osxfuse-3.8.3.zip
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/osxfuse.zip

    DOWNLOAD_NAME
        osxfuse-3.8.3.zip

    URL_HASH
         MD5=78b79b7bf67c823d734141d62e1b60d6

    #--Configure step-------------
    CONFIGURE_COMMAND
        cd fuse
        && ./makeconf.sh

    #--Build step-----------------
    BUILD_COMMAND
        ${CMAKE_COMMAND} -E copy_directory common fuse/lib
        && cd fuse
        && ./configure ${CONFIGURE_PARAMS_LIST}
        && make

    #--Install step---------------
    INSTALL_COMMAND
        ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/osxfuse.zip ${EXTERNAL_DOWNLOAD_PATH}/osxfuse-3.8.3.zip
        && cd fuse
        && make install
        && ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/FUSE_for_macOS_3.8.3.pkg ${INSTALL_DIR}/osxfuse.pkg
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "3.8.3 - last open source"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/osxfuse.pkg # должен быть только путь, но и так сойдет...
    external_inc_path       ${INSTALL_DIR}/include/osxfuse
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
