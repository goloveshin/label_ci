cmake_minimum_required(VERSION 3.13.4)

project(qtwebkit)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

get_target_property(LIB__QT__BINARY_DIR     qt_interface external_bin_path)
get_target_property(LIB__QT__INCLUDE_DIR    qt_interface external_inc_path)
get_target_property(LIB__QT__LIBRARY_DIR    qt_interface external_lib_path)

if (CMAKE_BUILD_TYPE MATCHES Release)
    set(MODE_1  "--release")
    set(MODE_2  "Release")
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
    set(MODE_1  "--debug")
    set(MODE_2  "Debug")
elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(MODE_1  "--release")
    set(MODE_2  "Release")
    message(FATAL_ERROR "Not implemented yet")
endif ()

if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    ExternalProject_Get_Property("qt${EXTERNAL_PROJECT_SUFFIX}" BINARY_DIR)

    set(PATCH_COMMAND_VAL
        sed -i -e "s@win_flex@flex@g" -e "s@nmake@jom -j${EXTERNAL_BUILD_JOBS}@g" Tools/Scripts/webkitdirs.pm
        && sed -i -e "123,124{s@^@#@}" Tools/qmake/mkspecs/features/features.prf
        && sed -i -e "s@../../../qtbase/src/3rdparty/sqlite/@${BINARY_DIR}/qtbase/src/3rdparty/sqlite/@" Source/WebCore/WebCore.pri
        && patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/webkitgtk-1.10.x.patch
        && patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/icu65.patch
        && cp ${CMAKE_CURRENT_SOURCE_DIR}/cmake/icu.pro Tools/qmake/config.tests/icu/icu.pro
        && cp ${CMAKE_CURRENT_SOURCE_DIR}/cmake/WTF.pri Source/WTF/WTF.pri
    )

    set(CONFIGURE_COMMAND_VAL
        :
    )

    set(BUILD_COMMAND_VAL
        perl Tools/Scripts/build-webkit --qt ${MODE_1} --no-webkit2 --cmakeargs=-Wno-dev CONFIG+=production_build --qmake=${LIB__QT__BINARY_DIR}/qmake.exe --install-headers=${LIB__QT__INCLUDE_DIR} --install-libs=${LIB__QT__LIBRARY_DIR}
    )

    set(INSTALL_COMMAND_VAL
        cd WebKitBuild/${MODE_2}
        && jom install
    )

elseif (CLIENT_FOR_MACOS)

    set(PATCH_COMMAND_VAL
        patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/webkitgtk-1.10.x.patch
    )

    set(CONFIGURE_COMMAND_VAL
        echo ok
    )

    set(BUILD_COMMAND_VAL
        perl Tools/Scripts/build-webkit --qt ${MODE_1} --no-webkit2 --cmakeargs=-Wno-dev CONFIG+=production_build --qmake=${LIB__QT__BINARY_DIR}/qmake --install-headers=${LIB__QT__INCLUDE_DIR} --install-libs=${LIB__QT__LIBRARY_DIR}
    )

    set(INSTALL_COMMAND_VAL
        cd WebKitBuild/${MODE_2}
        && make install -j${EXTERNAL_BUILD_JOBS}
    )

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    ExternalProject_Get_Property("qt${EXTERNAL_PROJECT_SUFFIX}" BINARY_DIR)

    set(PATCH_COMMAND_VAL
        patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/webkitgtk-1.10.x.patch
        && patch -p1 < ${CMAKE_CURRENT_SOURCE_DIR}/cmake/icu65.patch
    )

    set(CONFIGURE_COMMAND_VAL
        echo ok
    )

    set(BUILD_COMMAND_VAL
        export SQLITE3SRCDIR=${BINARY_DIR}/qtbase/src/3rdparty/sqlite/
        && perl Tools/Scripts/build-webkit --qt ${MODE_1} --no-webkit2 --cmakeargs=-Wno-dev CONFIG+=production_build --qmake=${LIB__QT__BINARY_DIR}/qmake --install-headers=${LIB__QT__INCLUDE_DIR} --install-libs=${LIB__QT__LIBRARY_DIR}
        && cd WebKitBuild/${MODE_2}
        && make -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        cd WebKitBuild/${MODE_2}
        && make install -j${EXTERNAL_BUILD_JOBS}
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS
        qt_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        http://download.qt.io/community_releases/5.6/5.6.3/qtwebkit-opensource-src-5.6.3.tar.xz

    DOWNLOAD_NAME
        qtwebkit-opensource-src-5.6.3.tar.xz

    URL_HASH
        MD5=d99754a17c0afdda00b0684675a035ab

    LIST_SEPARATOR |

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
    external_version        "5.6.3" # именно такая
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ""
)
ListingToExternals(${PROJECT_NAME})
