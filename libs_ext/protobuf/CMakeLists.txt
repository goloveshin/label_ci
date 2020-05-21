cmake_minimum_required(VERSION 3.13.4)

project(protobuf)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64 OR
    CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    if (SERVER_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_32)
        set(PLATFORM Win32)
        set(MACHINE  86)
    else ()
        set(PLATFORM x64)
        set(MACHINE  64)
    endif ()

    set(CONFIGURE_COMMAND_VAL
        :
    )

    set(BUILD_COMMAND_VAL
        cd vsprojects
        && sed -i "s@Win32@${PLATFORM}@g" *.vcproj
        && sed -i "s@Win32@${PLATFORM}@g" protobuf.sln
        && ${CMAKE_COMMAND} -E remove_directory Backup
        && devenv protobuf.sln /Upgrade
        && sed -i "s@MachineX86@MachineX${MACHINE}@g" protoc.vcxproj
        && set CL=/D_SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS
        && msbuild protobuf.sln /t:protoc /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}
        && set CL=/D_SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS\ /DPROTOBUF_USE_DLLS
        && msbuild protobuf.sln /t:libprotobuf /p:Configuration=${CMAKE_BUILD_TYPE} /p:ConfigurationType=DynamicLibrary /p:Platform=${PLATFORM}
        && msbuild protobuf.sln /t:libprotobuf-lite /p:Configuration=${CMAKE_BUILD_TYPE} /p:ConfigurationType=DynamicLibrary /p:Platform=${PLATFORM}
    )

    set(INSTALL_COMMAND_VAL
        cd vsprojects
        && extract_includes.bat
        && ${CMAKE_COMMAND} -E copy ../src/google/protobuf/stubs/stl_util.h include/google/protobuf/stubs/stl_util.h
        && ${CMAKE_COMMAND} -E copy_directory include/ ${INSTALL_DIR}/include
        && ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}/bin ${INSTALL_DIR}/lib
        && ${CMAKE_COMMAND} -E copy ${CMAKE_BUILD_TYPE}/protoc.exe ${INSTALL_DIR}/bin
        && ${CMAKE_COMMAND} -E copy ${CMAKE_BUILD_TYPE}/libprotobuf.lib ${CMAKE_BUILD_TYPE}/libprotobuf.dll ${INSTALL_DIR}/lib
        && ${CMAKE_COMMAND} -E copy ${CMAKE_BUILD_TYPE}/libprotobuf-lite.lib ${CMAKE_BUILD_TYPE}/libprotobuf-lite.dll ${INSTALL_DIR}/lib
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
    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz

    DOWNLOAD_NAME
        protobuf-2.6.1.tar.gz

    URL_HASH
        MD5=f3916ce13b7fcb3072a1fa8cf02b2423

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
    external_version        "2.6.1" # именно такая
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
