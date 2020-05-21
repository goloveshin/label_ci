cmake_minimum_required(VERSION 3.13.4)

project(libzlib)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)

    if (SERVER_FOR_WINDOWS_32)
        set(PLATFORM      Win32)
        set(PLATFORM_PATH "")
    else ()
        set(PLATFORM      x64)
        set(PLATFORM_PATH x64)
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
            https://github.com/kiyolee/zlib-win-build/archive/v1.2.11.zip

        DOWNLOAD_NAME
            zlib-v1.2.11.zip

        URL_HASH
            MD5=10d891c62548570a7557192a5034062d

        #--Configure step-------------
        CONFIGURE_COMMAND
            cd build-VS2015-MT
            && sed -i "s@libz-static.vcxproj@zlibstat.vcxproj@g" zlib.sln
            && sed -i "s@libz.vcxproj@zlib.vcxproj@g" zlib.sln
            && mv libz-static/libz-static.vcxproj libz-static/zlibstat.vcxproj
            && mv libz-static/libz-static.vcxproj.filters libz-static/zlibstat.vcxproj.filters
            && mv libz/libz.vcxproj libz/zlib.vcxproj
            && mv libz/libz.vcxproj.filters libz/zlib.vcxproj.filters

        #--Build step-----------------
        BUILD_COMMAND
            cd build-VS2015-MT
            && msbuild zlib.sln /t:libz /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}
            && msbuild zlib.sln /t:libz-static /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}

        #--Install step---------------
        INSTALL_COMMAND
            ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}/include
            && ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}/lib
            && ${CMAKE_COMMAND} -E copy zlib.h zconf.h ${INSTALL_DIR}/include
            && cd build-VS2015-MT/${PLATFORM_PATH}/${CMAKE_BUILD_TYPE}
            && ${CMAKE_COMMAND} -E copy zlib.dll zlib.lib zlibstat.lib ${INSTALL_DIR}/lib
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

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
            https://www.zlib.net/zlib-1.2.11.tar.gz

        DOWNLOAD_NAME
            zlib_v1.2.11.zip

        URL_HASH
            MD5=1c9f62f0778697a09d36121ead88e08e

        #--Configure step-------------
        CONFIGURE_COMMAND
            export APPEND_LDFLAGS=-Wl,-z,origin\ -Wl,-rpath,'$$ORIGIN'\ -Wl,--enable-new-dtags
            && . ${CMAKE_BINARY_DIR}/env_wrapper.sh
            && ./configure ${CONFIGURE_PARAMS_LIST}

        #--Build step-----------------
        BUILD_COMMAND
            . ${CMAKE_BINARY_DIR}/env_wrapper.sh
            && make -j${EXTERNAL_BUILD_JOBS}

        #--Install step---------------
        INSTALL_COMMAND
            . ${CMAKE_BINARY_DIR}/env_wrapper.sh
            && make install -j${EXTERNAL_BUILD_JOBS}
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        "1.2.11"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ""
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
