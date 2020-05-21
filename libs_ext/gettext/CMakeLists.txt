cmake_minimum_required(VERSION 3.13.4)

project(gettext)


# from: http://mlocati.github.io/articles/gettext-iconv-windows.html

if (SERVER_FOR_WINDOWS_32)

    set(URL             https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.20.1-v1.16/gettext0.20.1-iconv1.16-static-32.zip)
    set(DOWNLOAD_NAME   gettext0.20.1-iconv1.16-static-32.zip)
    set(URL_HASH        ba11885580103ab45dfe6337a3fe56e5)

elseif (SERVER_FOR_WINDOWS_64)

    set(URL             https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.20.1-v1.16/gettext0.20.1-iconv1.16-static-64.zip)
    set(DOWNLOAD_NAME   gettext0.20.1-iconv1.16-static-64.zip)
    set(URL_HASH        cff2994c78d421d8a3afdc9231ed8aa9)

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        ${URL}

    DOWNLOAD_NAME
        ${DOWNLOAD_NAME}

    URL_HASH
        MD5=${URL_HASH}

    #--Configure step-------------
    CONFIGURE_COMMAND ""

    #--Build step-----------------
    BUILD_COMMAND ""

    #--Install step---------------
    INSTALL_COMMAND
        ${CMAKE_COMMAND} -E copy_directory bin ${INSTALL_DIR}
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "gettext 0.20.1 / iconv 1.16"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}
#    external_inc_path      ${INSTALL_DIR}/include
#    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
