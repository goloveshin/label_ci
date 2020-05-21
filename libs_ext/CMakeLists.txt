cmake_minimum_required(VERSION 3.13.4)

include(LibsExtCommon)


GenerateEnvWrapper()

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)

    add_subdirectory(libzlib)
    add_subdirectory(libopenssl_1_0_x)
    add_subdirectory(libopenldap)
    add_subdirectory(libcurl)
    add_subdirectory(libcurlpp)
    add_subdirectory(icu)
    add_subdirectory(libopus)
    add_subdirectory(libspeex) # TODO линкуется в relay, но не используется - в зависимостях нет
    add_subdirectory(boost)
    add_subdirectory(libmongoclient)
    add_subdirectory(protobuf)
    add_subdirectory(websocketpp)
    add_subdirectory(gettext)   # TODO собирать

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    add_subdirectory(libzlib)
    add_subdirectory(libopenssl_1_0_x)
    add_subdirectory(libopenldap)
    add_subdirectory(libcurl)
    add_subdirectory(libcurlpp)
    add_subdirectory(icu)
    add_subdirectory(libopus)
    add_subdirectory(libspeex)
    add_subdirectory(boost)
    add_subdirectory(libmongoclient)
    add_subdirectory(protobuf)
    add_subdirectory(websocketpp)
    # add_subdirectory(gettext)   # TODO собирать

    add_subdirectory(gtest)

elseif (CLIENT_FOR_WINDOWS_32 OR CLIENT_FOR_WINDOWS_64)

    add_subdirectory(libopenssl_1_0_x)
    add_subdirectory(icu)
    add_subdirectory(libopus)
    add_subdirectory(libspeex)
    add_subdirectory(boost)
    add_subdirectory(protobuf)
    add_subdirectory(libogg)
    add_subdirectory(libflac)
    add_subdirectory(libvorbis)
    add_subdirectory(sqlcipher)
    add_subdirectory(soundtouch)
    add_subdirectory(rtaudio)
    add_subdirectory(libyuv)
    add_subdirectory(libvpx)
    add_subdirectory(libsndfile)
    add_subdirectory(cm256)
    add_subdirectory(qt)
    add_subdirectory(qtwebkit)
    add_subdirectory(dokany) # TODO собирать

elseif (CLIENT_FOR_MACOS)

    add_subdirectory(libopenssl_1_0_x)
    add_subdirectory(icu)
    add_subdirectory(libopus)
    add_subdirectory(libspeex)
    add_subdirectory(boost)
    add_subdirectory(protobuf)
    add_subdirectory(libogg)
    add_subdirectory(libflac)
    add_subdirectory(libvorbis)
    add_subdirectory(sqlcipher)
    add_subdirectory(soundtouch)
    add_subdirectory(rtaudio)
    add_subdirectory(libyuv)
    add_subdirectory(libvpx)
    add_subdirectory(libsndfile)
    add_subdirectory(cm256)
    add_subdirectory(qt)# TODO собрать пока не удалось - вал ошибок
    add_subdirectory(qtwebkit)
    add_subdirectory(osxfuse)

elseif (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    add_subdirectory(libopenssl_1_0_x)
    add_subdirectory(icu)
    add_subdirectory(libopus)
    add_subdirectory(libspeex)
    add_subdirectory(boost)
    add_subdirectory(protobuf)
    add_subdirectory(libogg)
    add_subdirectory(libflac)
    add_subdirectory(libvorbis)
    add_subdirectory(sqlcipher)
    add_subdirectory(soundtouch)
    add_subdirectory(rtaudio)
    add_subdirectory(libyuv)
    add_subdirectory(libvpx)
    add_subdirectory(libsndfile)
#    add_subdirectory(cm256)
    add_subdirectory(qt)
    add_subdirectory(qtwebkit)
    add_subdirectory(qtifw) # используем pre-installed, TOD для сборки нужна static Qt

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()

ExportExternals(
    ${EXTERNAL_INSTALL_PATH}/environment.sh
    ${EXTERNAL_INSTALL_PATH}/environment.bat
    ${EXTERNAL_INSTALL_PATH}/environment.map
)

PrintExternalsInfo(${EXTERNAL_INSTALL_PATH}/dependencies_info.txt)
PrintExternalsDownloadsNames(${EXTERNAL_INSTALL_PATH}/dependencies_sources.txt)

if (BUILD_LIBS_EXT_POST_BUILD_MODE)
    PrintExternalsBinInfo(${EXTERNAL_INSTALL_PATH}/dependencies_bin_info.txt)
endif()
