cmake_minimum_required(VERSION 3.13.4)

project(libspeex)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64 OR
    CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    # ВНИМАНИЕ! 
    # используется, но не линкуется к серверам, собираем только как x86, т.к. этого достаточно
    # x64 в проектах нет

    if (True)
        set(PLATFORM x86)
    else ()
        set(PLATFORM x64)
    endif ()

    set(CONFIGURE_COMMAND_VAL
        :
    )

    set(BUILD_COMMAND_VAL
        ${CMAKE_COMMAND} -E make_directory libspeex
        && ${CMAKE_COMMAND} -E copy_directory libspeexdsp libspeex
        && cd win32/libspeexdsp

        # upgrade per-project, using solution cause 'cannot create backup' error...
        && ${CMAKE_COMMAND} -E remove -f libspeexdsp.vcxproj
        && ${CMAKE_COMMAND} -E remove_directory Backup
        && devenv libspeexdsp.dsp /Upgrade
        && ${CMAKE_COMMAND} -E remove -f libspeexdsp_dynamic.vcxproj
        && ${CMAKE_COMMAND} -E remove_directory Backup
        && devenv libspeexdsp_dynamic.dsp /Upgrade
        && sed -i "s@<DebugInformationFormat>EditAndContinue@<DebugInformationFormat>ProgramDatabase@g" libspeexdsp.vcxproj
        && sed -i "s@<DebugInformationFormat>EditAndContinue@<DebugInformationFormat>ProgramDatabase@g" libspeexdsp_dynamic.vcxproj
        && msbuild libspeexdsp.vcxproj /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}
        && msbuild libspeexdsp_dynamic.vcxproj /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}

        # not working...
#        && devenv libspeexdsp.dsw /Upgrade
#        && msbuild libspeexdsp.sln /t:libspeexdsp /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}
#        && msbuild libspeexdsp.sln /t:libspeexdsp_dynamic /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}
    )

    set(INSTALL_COMMAND_VAL
        ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}/lib ${INSTALL_DIR}/include
        && ${CMAKE_COMMAND} -E copy_directory include ${INSTALL_DIR}/include
        && ${CMAKE_COMMAND} -E copy ${INSTALL_DIR}/include/speex/speexdsp_types.h ${INSTALL_DIR}/include/speex/speex_types.h
        && ${CMAKE_COMMAND} -E copy lib/libspeexdsp.lib bin/libspeexdsp.dll ${INSTALL_DIR}/lib
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

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
        && ${CMAKE_COMMAND} -E copy ${INSTALL_DIR}/include/speex/speexdsp_types.h ${INSTALL_DIR}/include/speex/speex_types.h
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
        && ${CMAKE_COMMAND} -E copy ${INSTALL_DIR}/include/speex/speexdsp_types.h ${INSTALL_DIR}/include/speex/speex_types.h
        && ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdsp_config_types.h ${INSTALL_DIR}/include/speex/
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
        http://downloads.xiph.org/releases/speex/speexdsp-1.2rc3.tar.gz

    DOWNLOAD_NAME
        speexdsp-1.2rc3.tar.gz

    URL_HASH
        MD5=70d9d31184f7eb761192fd1ef0b73333

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
    external_version        "1.2rc3" # именно такая
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ""
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
