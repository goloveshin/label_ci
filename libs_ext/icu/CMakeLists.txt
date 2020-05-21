cmake_minimum_required(VERSION 3.13.4)

project(icu)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64 OR
    CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    if (SERVER_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_32)
        set(PLATFORM Win32)
        set(COPY_EXT "")
    else ()
        set(PLATFORM x64)
        set(COPY_EXT 64)
    endif ()

    set(DEPENDS_VAL
    )

    set(PATCH_COMMAND_VAL
        sed -i "s@py -3@c:/python37/python@g" source/data/makedata.mak
        && sed -i "s@py -3@c:/python37/python@g" source/test/testdata/testdata.mak
        && sed -i "45s@^@#@" source/test/testdata/testdata.mak
    )

    set(CONFIGURE_COMMAND_VAL
        :
    )

    set(BUILD_COMMAND_VAL
        set PATH=c:/Python37;c:/Python37/Lib;c:/Python37/Scripts;%PATH%
        && set CL=/DU_USING_ICU_NAMESPACE\ /DU_CHARSET_IS_UTF8\ /DU_NO_DEFAULT_INCLUDE_UTF_HEADERS
        && msbuild source/allinone/allinone.sln /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM} /p:SkipUWP=true
    )

    set(INSTALL_COMMAND_VAL
        ${CMAKE_COMMAND} -E copy_directory bin${COPY_EXT}/ ${INSTALL_DIR}/bin
        && ${CMAKE_COMMAND} -E copy_directory include/ ${INSTALL_DIR}/include
        && ${CMAKE_COMMAND} -E copy_directory lib${COPY_EXT}/ ${INSTALL_DIR}/lib
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    get_target_property(LIB__OPENSSL__INCLUDE_DIR libopenssl_1_0_x_interface external_inc_path)
    get_target_property(LIB__OPENSSL__LIBRARY_DIR libopenssl_1_0_x_interface external_lib_path)

    set(DEPENDS_VAL
        libopenssl_1_0_x_interface
    )

    set(PATCH_COMMAND_VAL
    )

    set(CONFIGURE_COMMAND_VAL
        export APPEND_CFLAGS=-I${LIB__OPENSSL__INCLUDE_DIR}
        && export APPEND_CXXFLAGS=-DU_USING_ICU_NAMESPACE=1\ -DU_CHARSET_IS_UTF8=1
        && export APPEND_CPPFLAGS=-DU_NO_DEFAULT_INCLUDE_UTF_HEADERS=1
        && export APPEND_LDFLAGS=-L${LIB__OPENSSL__LIBRARY_DIR}\ -Wl,-z,origin\ -Wl,-rpath,'$$ORIGIN'\ -Wl,--enable-new-dtags
        && . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./source/runConfigureICU ${CONFIGURE_PARAMS_LIST}
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make install -j${EXTERNAL_BUILD_JOBS}
    )

elseif (CLIENT_FOR_MACOS)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    get_target_property(LIB__OPENSSL__INCLUDE_DIR libopenssl_1_0_x_interface external_inc_path)
    get_target_property(LIB__OPENSSL__LIBRARY_DIR libopenssl_1_0_x_interface external_lib_path)

    set(DEPENDS_VAL
        libopenssl_1_0_x_interface
    )

    set(PATCH_COMMAND_VAL
    )

    set(CONFIGURE_COMMAND_VAL
        export APPEND_CFLAGS=-I${LIB__OPENSSL__INCLUDE_DIR}
        && export APPEND_CXXFLAGS=-DU_USING_ICU_NAMESPACE=1\ -DU_CHARSET_IS_UTF8=1
        && export APPEND_CPPFLAGS=-DU_NO_DEFAULT_INCLUDE_UTF_HEADERS=1
        && export APPEND_LDFLAGS=-L${LIB__OPENSSL__LIBRARY_DIR}
        && . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./source/runConfigureICU ${CONFIGURE_PARAMS_LIST}
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

    get_target_property(LIB__OPENSSL__INCLUDE_DIR libopenssl_1_0_x_interface external_inc_path)
    get_target_property(LIB__OPENSSL__LIBRARY_DIR libopenssl_1_0_x_interface external_lib_path)

    set(DEPENDS_VAL
        libopenssl_1_0_x_interface
    )

    set(PATCH_COMMAND_VAL
    )

    set(CONFIGURE_COMMAND_VAL
        export APPEND_CFLAGS=-I${LIB__OPENSSL__INCLUDE_DIR}
        && export APPEND_CXXFLAGS=-DU_USING_ICU_NAMESPACE=1\ -DU_CHARSET_IS_UTF8=1
        && export APPEND_CPPFLAGS=-DU_NO_DEFAULT_INCLUDE_UTF_HEADERS=1
        && export APPEND_LDFLAGS=-L${LIB__OPENSSL__LIBRARY_DIR}\ -Wl,-z,origin\ -Wl,-rpath,'$$ORIGIN'\ -Wl,--enable-new-dtags
        && . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./source/runConfigureICU ${CONFIGURE_PARAMS_LIST}
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
        ${DEPENDS_VAL}

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
        https://github.com/unicode-org/icu/releases/download/release-65-1/icu4c-65_1-src.tgz

    DOWNLOAD_NAME
        icu4c-65_1-src.tgz

    URL_HASH
        MD5=d1ff436e26cabcb28e6cb383d32d1339

    #--Patch step-----------------
    PATCH_COMMAND
        ${PATCH_COMMAND_VAL}

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
    external_version        "65.1"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
