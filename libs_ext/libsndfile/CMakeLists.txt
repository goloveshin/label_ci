cmake_minimum_required(VERSION 3.13.4)

project(libsndfile)


set(INSTALL_DIR ${EXTERNAL_INSTALL_PATH}/${PROJECT_NAME})
set(EXTERNAL_PROJECT_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_SUFFIX}")
set(EXTERNAL_PROJECT_INTERFACE_NAME "${PROJECT_NAME}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

get_target_property(LIB__OGG__INC_DIR libogg_interface external_inc_path)
get_target_property(LIB__OGG__LIB_DIR libogg_interface external_lib_path)

get_target_property(LIB__VORBIS__INC_DIR libvorbis_interface external_inc_path)
get_target_property(LIB__VORBIS__LIB_DIR libvorbis_interface external_lib_path)

get_target_property(LIB__FLAC__INC_DIR libflac_interface external_inc_path)
get_target_property(LIB__FLAC__LIB_DIR libflac_interface external_lib_path)

if (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    set(URL             https://github.com/erikd/libsndfile/archive/v1.0.28pre1.zip)
    set(DOWNLOAD_NAME   sndfile-1.0.28pre1.zip)
    set(URL_HASH        74c59d975712ead45e5b1090da2ef1ce)
    set(LIB_VERSION     1.0.28pre1)

    set(PATCH_COMMAND_VAL
        sed -i "326iset_target_properties(\${SNDFILE_SHARED_TARGET} PROPERTIES PUBLIC_HEADER \"\${libsndfile_PUBLIC_HEADERS}\")" CMakeLists.txt
    )

    set(CONFIGURE_COMMAND_VAL
    )

    set(BUILD_COMMAND_VAL
    )

    set(INSTALL_COMMAND_VAL
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
        -DDISABLE_EXTERNAL_LIBS=OFF
        -DOGG_INCLUDE_DIR=${LIB__OGG__INC_DIR}
        -DOGG_LIBRARY=${LIB__OGG__LIB_DIR}/libogg_static.lib
        -DVORBIS_INCLUDE_DIR=${LIB__VORBIS__INC_DIR}
        -DVORBIS_LIBRARY=${LIB__VORBIS__LIB_DIR}/libvorbis.lib
        -DVORBISFILE_LIBRARY=${LIB__VORBIS__LIB_DIR}/libvorbisfile.lib
        -DVORBISENC_LIBRARY=${LIB__VORBIS__LIB_DIR}
        -DFLAC_INCLUDE_DIR=${LIB__FLAC__INC_DIR}
        -DFLAC_LIBRARY=${LIB__FLAC__LIB_DIR}/libFLAC_static.lib
    )

elseif (CLIENT_FOR_MACOS)

    set(URL             https://github.com/erikd/libsndfile/archive/v1.0.28pre1.zip)
    set(DOWNLOAD_NAME   sndfile-1.0.28pre1.zip)
    set(URL_HASH        74c59d975712ead45e5b1090da2ef1ce)
    set(LIB_VERSION     1.0.28pre1)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(PATCH_COMMAND_VAL
    )

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./autogen.sh
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

    set(CMAKE_ARGS_VAL
    )

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    set(URL             https://github.com/erikd/libsndfile/archive/1.0.28.zip)
    set(DOWNLOAD_NAME   sndfile-1.0.28.zip)
    set(URL_HASH        54e5a79263a120cb54e8ede2b3f47530)
    set(LIB_VERSION     1.0.28)

    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/configure.cmake)

    set(PATCH_COMMAND_VAL
    )

    set(CONFIGURE_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && ./autogen.sh
        && ./configure ${CONFIGURE_PARAMS_LIST}
        && bash ${CMAKE_CURRENT_SOURCE_DIR}/cmake/patch_linux.sh
    )

    set(BUILD_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make -j${EXTERNAL_BUILD_JOBS}
    )

    set(INSTALL_COMMAND_VAL
        . ${CMAKE_BINARY_DIR}/env_wrapper.sh
        && make install -j${EXTERNAL_BUILD_JOBS}
        && cd ${INSTALL_DIR}/lib
        && patchelf --set-rpath $ORIGIN libsndfile.so libsndfile.so.1 libsndfile.so.1.0.28
    )

    set(CMAKE_ARGS_VAL
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExternalProject_Add(${EXTERNAL_PROJECT_NAME}
    DEPENDS
        libogg_interface
        libvorbis_interface
        libflac_interface

    PREFIX
        ${CMAKE_CURRENT_BINARY_DIR}

    BINARY_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/src/${EXTERNAL_PROJECT_NAME}

    DOWNLOAD_DIR
        ${EXTERNAL_DOWNLOAD_PATH}

    #--Download step--------------
    URL
        ${URL}

    DOWNLOAD_NAME
        ${DOWNLOAD_NAME}

    URL_HASH
        MD5=${URL_HASH}

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

    #--Configure step-------------
    CMAKE_ARGS
        ${CMAKE_ARGS_VAL}
)

add_library(${EXTERNAL_PROJECT_INTERFACE_NAME} INTERFACE)

add_dependencies(${EXTERNAL_PROJECT_INTERFACE_NAME} ${EXTERNAL_PROJECT_NAME})

set_target_properties(${EXTERNAL_PROJECT_INTERFACE_NAME} PROPERTIES
    external_version        ${LIB_VERSION}
    external_root_path      ${INSTALL_DIR}
    external_bin_path       ${INSTALL_DIR}/bin
    external_inc_path       ${INSTALL_DIR}/include
    external_lib_path       ${INSTALL_DIR}/lib
)
ListingToExternals(${PROJECT_NAME})
