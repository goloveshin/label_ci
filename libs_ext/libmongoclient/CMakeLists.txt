cmake_minimum_required(VERSION 3.13.4)

project(libmongoclient)

# TODO need port: https://www.freshports.org/devel/mongo-cxx-driver/

set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS
        boost_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.1.2.tar.gz

    DOWNLOAD_NAME
        mongo-cxx-driver-legacy-1.1.2.tar.gz

    URL_HASH
        MD5=4667f28eb7e3de5ba725748266b0f768

    #--Configure step-------------
    CONFIGURE_COMMAND
        sed -i "1795s/.*/#&/" ./SConstruct
        && sed -i "1796s/.*/#&/" ./SConstruct

    #--Build step-----------------
    BUILD_COMMAND
       scons ${CONFIGURE_PARAMS_LIST} install

    #--Install step---------------
    INSTALL_COMMAND ""
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "1.1.2" # именно такая
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ""
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
