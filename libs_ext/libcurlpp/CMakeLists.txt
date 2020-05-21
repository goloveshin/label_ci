cmake_minimum_required(VERSION 3.13.4)

project(libcurlpp)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

get_target_property(LIB__CURL__INCLUDE_DIR libcurl_interface external_inc_path)
get_target_property(LIB__CURL__LIBRARY_DIR libcurl_interface external_lib_path)

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)

    set(PATCH_COMMAND_VAL
        sed -i "s@set(CMAKE_INSTALL_PREFIX \"winbuild\")@@g" CMakeLists.txt
    )

    set(CMAKE_ARGS_VAL
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
        -DCMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}
        -DCMAKE_CXX_FLAGS_DEBUG=${CMAKE_CXX_FLAGS_DEBUG}
        -DCMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}
        -DCMAKE_CXX_FLAGS_RELEASE=${CMAKE_CXX_FLAGS_RELEASE}
        -DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}
        -DPC_CURL_INCLUDE_DIRS=${LIB__CURL__INCLUDE_DIR}
        -DPC_CURL_LIBRARY_DIRS=${LIB__CURL__LIBRARY_DIR}
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    set(PATCH_COMMAND_VAL
        :
    )

    set(CMAKE_ARGS_VAL
        -G "Unix Makefiles"
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
        -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
        -DCMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}
        -DCMAKE_CXX_FLAGS_DEBUG=${CMAKE_CXX_FLAGS_DEBUG}
        -DCMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}
        -DCMAKE_CXX_FLAGS_RELEASE=${CMAKE_CXX_FLAGS_RELEASE}
        -DCMAKE_EXE_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}
        -DCMAKE_SHARED_LINKER_FLAGS=${CMAKE_EXE_LINKER_FLAGS}\ -Wl,-z,origin\ -Wl,-rpath,'\$ORIGIN'\ -Wl,--enable-new-dtags
        -DCURL_INCLUDE_DIR=${LIB__CURL__INCLUDE_DIR}
        -DCURL_LIBRARY=${LIB__CURL__LIBRARY_DIR}
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS
        libcurl_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://github.com/jpbarrette/curlpp/archive/v0.8.1.tar.gz

    DOWNLOAD_NAME
        curlpp-v0.8.1.tar.gz

    URL_HASH
        MD5=2fdd2fc2e577b7e76193018cac457e9c

    #--Patch step-----------------
    PATCH_COMMAND
        ${PATCH_COMMAND_VAL}

    #--Configure step-------------
    CMAKE_ARGS
        ${CMAKE_ARGS_VAL}
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "0.8.1"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
