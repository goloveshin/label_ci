cmake_minimum_required(VERSION 3.13.4)

project(qtifw)


if (CLIENT_FOR_LINUX_32 OR CLIENT_FOR_LINUX_64)

    message(STATUS "QtIFW: using pre-installed http://download.qt.io/official_releases/qt-installer-framework/2.0.3/")

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()
