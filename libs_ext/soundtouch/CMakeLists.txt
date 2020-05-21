cmake_minimum_required(VERSION 3.13.4)

project(soundtouch)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    if (CLIENT_FOR_WINDOWS_32)
        set(PLATFORM Win32)
    else ()
        set(PLATFORM x64)
    endif ()

    set(CONFIGURE_COMMAND_VAL
        cd source/SoundTouchDll
        && ${CMAKE_COMMAND} -E remove_directory Backup
        && devenv SoundTouchDll.sln /Upgrade
        && cd ../../
        && sed -i -e "s@MultiThreaded<@MultiThreadedDLL<@g" -e "s@MultiThreadedDebug<@MultiThreadedDebugDLL<@g" source/SoundTouchDll/SoundTouchDLL.vcxproj
        && sed -i -e "s@MultiThreaded<@MultiThreadedDLL<@g" -e "s@MultiThreadedDebug<@MultiThreadedDebugDLL<@g" source/SoundTouch/SoundTouch.vcxproj
    )

    set(BUILD_COMMAND_VAL
        cd source/SoundTouchDll
        && msbuild SoundTouchDll.sln /p:Configuration=${CMAKE_BUILD_TYPE} /p:Platform=${PLATFORM}
    )

    set(INSTALL_COMMAND_VAL
        ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}/lib ${INSTALL_DIR}/include/soundtouch
        && ${CMAKE_COMMAND} -E copy_directory include ${INSTALL_DIR}/include/soundtouch
        && ${CMAKE_COMMAND} -E copy_directory lib ${INSTALL_DIR}/lib
    )

elseif (CLIENT_FOR_MACOS)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        gsed -i -e "s@source/SoundStretch/Makefile@@g" configure.ac
        && gsed -i -e "s@SoundStretch@@g" source/Makefile.am
        && ./bootstrap
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
        && ./bootstrap
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
        https://gitlab.com/soundtouch/soundtouch/-/archive/2.1.2/soundtouch-2.1.2.tar.gz

    DOWNLOAD_NAME
        soundtouch-2.1.2.tar.gz

    URL_HASH
        MD5=3537ad0e7e0ee77547b2127785eb904a

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
    external_version        "2.1.2"
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
