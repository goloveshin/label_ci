cmake_minimum_required(VERSION 3.13.4)

project(dokany)

# интерфейсная часть dokany
# не собираем, копируем "как есть"
# версия должна совпадать с инсталлятором в scripts/client/dist/dokany/

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
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/dokany.zip

    DOWNLOAD_NAME
        dokany.zip

    URL_HASH
         MD5=c1694747cc6b4db9d6f9e620017f9284

    #--Configure step-------------
    CONFIGURE_COMMAND ""

    #--Build step-----------------
    BUILD_COMMAND ""

    #--Install step---------------
    INSTALL_COMMAND
        ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/dokany.zip ${EXTERNAL_DOWNLOAD_PATH}
        && ${CMAKE_COMMAND} -E copy_directory bin/ ${INSTALL_DIR}/bin
        && ${CMAKE_COMMAND} -E copy_directory include/ ${INSTALL_DIR}/include
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "1.3.1.1000"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/bin # именно так
)
ListingToExternals(${PROJECT_NAME})
