cmake_minimum_required(VERSION 3.13.4)

project(qt)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

get_target_property(LIB__ICU__BINARY_DIR    icu_interface external_bin_path)
get_target_property(LIB__ICU__INCLUDE_DIR   icu_interface external_inc_path)
get_target_property(LIB__ICU__LIBRARY_DIR   icu_interface external_lib_path)

get_target_property(LIB__OPENSSL__INCLUDE_DIR libopenssl_1_0_x_interface external_inc_path)
get_target_property(LIB__OPENSSL__LIBRARY_DIR libopenssl_1_0_x_interface external_lib_path)

if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(PATCH_COMMAND_VAL
        # обход генерации qmake 'object_parallel_to_source' путей больше 260 символов
        # помогает в одном месте, но не помогает в другом
        # снятие ограничения на длинные имена в Windows 10 не затрагивает старые инструменты - в VS2015 все равно предел в 260 символов
        # пришлось использовать subst для радикального укорочения длины
        sed -i "s@dir += sourceRelativePath.leftRef(lastDirSepPosition + 1)@dir += QString::number(std::hash<std::string>()(sourceRelativePath.leftRef(lastDirSepPosition + 1).toUtf8().constData()))@g" qtbase/qmake/generators/makefile.cpp
        && cp ${CMAKE_CURRENT_SOURCE_DIR}/cmake/zlib.h qt3d/include/zlib.h
        && cp ${CMAKE_CURRENT_SOURCE_DIR}/cmake/icu_dependency.pri qtbase/src/3rdparty/icu_dependency.pri
    )

    set(CONFIGURE_COMMAND_VAL
        (if exist w: (echo 'drive w: exist, delete it' && subst w: /D) else (echo 'drive w: not exist'))
        && subst w: ${CMAKE_CURRENT_BINARY_DIR}/src
        && cd /D w:/qt_ext
        && if not exist _build mkdir _build
        && cd _build
        && call ../configure.bat ${CONFIGURE_PARAMS_LIST}
    )

    set(BUILD_COMMAND_VAL
        (if exist w: (echo 'drive w: exist, delete it' && subst w: /D) else (echo 'drive w: not exist'))
        && subst w: ${CMAKE_CURRENT_BINARY_DIR}/src
        && cd /D w:/qt_ext
        && cd _build
        && set PATH=${LIB__ICU__BINARY_DIR}|%PATH%
        && jom -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        cd /D w:/qt_ext
        && ${CMAKE_COMMAND} -E copy_directory gnuwin32/bin ${INSTALL_DIR}/../gnuwin32/bin
        && cd _build
        && jom install
    )

elseif (CLIENT_FOR_MACOS)

#    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)
#
#    set(PATCH_COMMAND_VAL
#        gsed -i -e "1iCONFIG += c++11" qtbase/config.tests/unix/icu/icu.pro
#        && gsed -i -e "s@10.7@10.9@g" qtbase/mkspecs/macx-clang/qmake.conf
#    )
#
#    set(CONFIGURE_COMMAND_VAL
#        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
#        && mkdir -p _build
#        && cd _build
#        && ./../configure ${CONFIGURE_PARAMS_LIST}
#    )
#
#    set(BUILD_COMMAND_VAL
#        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
#        && cd _build
#        && export DYLD_LIBRARY_PATH=${LIB__ICU__LIBRARY_DIR}
#        && export DYLD_FRAMEWORK_PATH=${LIB__ICU__LIBRARY_DIR}
#        && export DYLD_PRINT_LIBRARIES=y
#        && make -j${EXTERNAL_BUILD_JOBS}
#        && unset DYLD_PRINT_LIBRARIES
#    )
#
#    set(INSTALL_COMMAND_VAL
#        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
#        && cd _build
#        && make install -j${EXTERNAL_BUILD_JOBS}
#    )

    # TODO собрать пока не удалось - вал ошибок
    # используем предустановленную
    # http://download.qt.io/archive/qt/5.6/5.6.3/qt-opensource-mac-x64-clang-5.6.3.dmg

    # TODO FindQt
    set(INSTALL_DIR "/Users/jenkins/Qt5.6.3/5.6.3/clang_64")

    set(PATCH_COMMAND_VAL
    )

    set(CONFIGURE_COMMAND_VAL
        echo ok
    )

    set(BUILD_COMMAND_VAL
        echo ok
    )

    set(INSTALL_COMMAND_VAL
        echo ok
    )

    set(NO_EXTRACT TRUE)

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(PATCH_COMMAND_VAL
    )

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && mkdir -p _build
        && cd _build
        && ./../configure ${CONFIGURE_PARAMS_LIST}
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && cd _build
        && export LD_LIBRARY_PATH=${LIB__ICU__LIBRARY_DIR}
        && make -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && cd _build
        && make install -j${EXTERNAL_BUILD_JOBS}
        && cd ${INSTALL_DIR}/lib
        && patchelf --set-rpath $ORIGIN libQt5Core.so libQt5Core.so.5 libQt5Core.so.5.6 libQt5Core.so.5.6.3
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS
        icu_interface
        libopenssl_1_0_x_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        https://download.qt.io/archive/qt/5.6/5.6.3/single/qt-everywhere-opensource-src-5.6.3.tar.xz

    DOWNLOAD_NAME
        qt-everywhere-opensource-src-5.6.3.tar.xz

    URL_HASH
        MD5=010342d515b62ee1c0e709254f4ef9ab

    LIST_SEPARATOR |

    DOWNLOAD_NO_EXTRACT
        ${NO_EXTRACT}

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
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
