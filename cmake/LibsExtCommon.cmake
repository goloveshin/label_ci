cmake_minimum_required(VERSION 3.13.4)


function (ListingToExternals PROJECT_NAME)
    get_property(_LIST GLOBAL PROPERTY external_projects)
    list(APPEND _LIST ${PROJECT_NAME})
    set_property(GLOBAL PROPERTY external_projects ${_LIST})
endfunction ()

function (GenerateEnvWrapper)
	string(TOUPPER ${CMAKE_BUILD_TYPE} EXTERNAL_BUILD_TYPE)

	set(EXTERNAL_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_${EXTERNAL_BUILD_TYPE}}")
	set(EXTERNAL_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${EXTERNAL_BUILD_TYPE}}")
	set(EXTERNAL_CPP_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_${EXTERNAL_BUILD_TYPE}}")

    # we don't need pass COMPILE_DEFINITIONS of our project to external projects

	configure_file(
	    ${CMAKE_SOURCE_DIR}/cmake/${ENV_WRAPPER_IN_FILE}
	    ${CMAKE_BINARY_DIR}/env_wrapper.sh
	    @ONLY
	)
endfunction ()

function(ExternalProject_Get_PropertyHack name)
    foreach(var ${ARGN})
        string(TOUPPER "${var}" VAR)
        get_property(${var} TARGET ${name} PROPERTY _EP_${VAR})
        set(${var} "${${var}}" PARENT_SCOPE)
    endforeach()
endfunction()

function(FormatField FIELD)
    set(VALUE ${${FIELD}})
    if (VALUE)
        string(REPLACE ";" " " VALUE "${VALUE}")
        string(REPLACE "${CMAKE_COMMAND}" "cmake" VALUE "${VALUE}")
        string(REPLACE "${CMAKE_SOURCE_DIR}" "<CMAKE_SOURCE_DIR>" VALUE "${VALUE}")
        string(REPLACE "${CMAKE_BINARY_DIR}" "<BUILD_DIR>" VALUE "${VALUE}")
        string(REPLACE "${EXTERNAL_DOWNLOAD_PATH}" "<DOWNLOAD_PATH>" VALUE "${VALUE}")
        string(REPLACE "${EXTERNAL_INSTALL_PATH}" "<THIS_DIR>" VALUE "${VALUE}")
        string(REPLACE "&&" "\n${TAB}&& " VALUE "${VALUE}")
        string(REPLACE "--" "\n${TAB}    --" VALUE "${VALUE}")
        string(REPLACE "-D" "\n${TAB}-D" VALUE "${VALUE}")
        set(${FIELD} ${VALUE} PARENT_SCOPE)
    endif ()
endfunction()

function(FormatURL FIELD)
    set(VALUE ${${FIELD}})
    if (VALUE)
        string(REPLACE "${CMAKE_SOURCE_DIR}" "<CMAKE_SOURCE_DIR>" VALUE "${VALUE}")
        string(REPLACE "${CMAKE_BINARY_DIR}" "<BUILD_DIR>" VALUE "${VALUE}")
        string(REPLACE "${EXTERNAL_DOWNLOAD_PATH}" "<DOWNLOAD_PATH>" VALUE "${VALUE}")
        string(REPLACE "${EXTERNAL_INSTALL_PATH}" "<THIS_DIR>" VALUE "${VALUE}")
        set(${FIELD} ${VALUE} PARENT_SCOPE)
    endif ()
endfunction()

function (PrintExternalsInfo PATH)
    file(WRITE ${PATH} "${EXTERNAL_INSTALL_RELATIVE_PATH}\n\n")

    get_property(PROJECTS GLOBAL PROPERTY external_projects)

    foreach(_PROJECT ${PROJECTS})
        set(INTERFACE_NAME "${_PROJECT}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")
        set(EXTERNAL_NAME "${_PROJECT}${EXTERNAL_PROJECT_SUFFIX}")

        get_target_property(VERSION ${INTERFACE_NAME} external_version)

        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} URL)
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} DOWNLOAD_NAME)
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} DEPENDS)
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} PATCH_COMMAND)
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} CONFIGURE_COMMAND)
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} BUILD_COMMAND)
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} INSTALL_COMMAND)
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} CMAKE_ARGS)

        set(TAB "                         ")

            file(APPEND ${PATH} "--------------------\n")
            file(APPEND ${PATH} "${_PROJECT}\n")
            file(APPEND ${PATH} "--------------------\n")

            file(APPEND ${PATH} "    VERSION            : ${VERSION}\n\n")
            FormatURL(URL)
            file(APPEND ${PATH} "    URL                : ${URL}\n\n")
            file(APPEND ${PATH} "    DOWNLOAD_NAME      : ${DOWNLOAD_NAME}\n\n")
        if (DEPENDS)
            string(REPLACE ";" "\n${TAB}" DEPENDS "${DEPENDS}")
            string(REPLACE "_interface" "" DEPENDS "${DEPENDS}")
            file(APPEND ${PATH} "    DEPENDS            : ${DEPENDS}\n\n")
        endif ()
        if (PATCH_COMMAND)
            FormatField(PATCH_COMMAND)
            file(APPEND ${PATH} "    PATCH_COMMAND      : ${PATCH_COMMAND}\n\n")
        endif ()
        if (CONFIGURE_COMMAND)
            FormatField(CONFIGURE_COMMAND)
            file(APPEND ${PATH} "    CONFIGURE_COMMAND  : ${CONFIGURE_COMMAND}\n\n")
        endif ()
        if (BUILD_COMMAND)
            FormatField(BUILD_COMMAND)
            file(APPEND ${PATH} "    BUILD_COMMAND      : ${BUILD_COMMAND}\n\n")
        endif ()
        if (INSTALL_COMMAND)
            FormatField(INSTALL_COMMAND)
            file(APPEND ${PATH} "    INSTALL_COMMAND    : ${INSTALL_COMMAND}\n\n")
        endif ()
        if (CMAKE_ARGS)
            FormatField(CMAKE_ARGS)
            file(APPEND ${PATH} "    CMAKE_ARGS         : ${CMAKE_ARGS}\n\n")
        endif ()
    endforeach()
endfunction ()

function (PrintExternalsBinInfo PATH)
    file(WRITE ${PATH} "${EXTERNAL_INSTALL_RELATIVE_PATH}\n\n")

    get_property(PROJECTS GLOBAL PROPERTY external_projects)

    foreach(_PROJECT ${PROJECTS})
        set(INTERFACE_NAME "${_PROJECT}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")
        set(EXTERNAL_NAME "${_PROJECT}${EXTERNAL_PROJECT_SUFFIX}")

        get_target_property(BIN_PATH ${INTERFACE_NAME} external_bin_path)
        get_target_property(LIB_PATH ${INTERFACE_NAME} external_lib_path)

        set(TAB "                         ")

            file(APPEND ${PATH} "--------------------\n")
            file(APPEND ${PATH} "${_PROJECT}\n")
            file(APPEND ${PATH} "--------------------\n")

        if (LIB_PATH)
            if (APPLE)
                execute_process(COMMAND bash -c "for f in `find ${LIB_PATH} -name *.dylib` ; do otool -L $f ; done" OUTPUT_VARIABLE _OUT)
            elseif (UNIX AND NOT APPLE)
                execute_process(COMMAND bash -c "for f in `find ${LIB_PATH} -name *.so` ; do echo $f && readelf -d $f | grep NEEDED ; done" OUTPUT_VARIABLE _OUT)
            else ()
                set(_OUT "Not implemented yet")
            endif ()
            string(REPLACE "${LIB_PATH}/" "" _OUT "${_OUT}")
            file(APPEND ${PATH} "---------- IMPORT ----------\n${_OUT}\n")

            if (APPLE)
                execute_process(COMMAND bash -c "for f in `find ${LIB_PATH} -name *.dylib` ; do echo $f && otool -l $f | grep path ; done" OUTPUT_VARIABLE _OUT)
            elseif (UNIX AND NOT APPLE)
                execute_process(COMMAND bash -c "for f in `find ${LIB_PATH} -name *.so` ; do echo $f && readelf -d $f | grep path ; done" OUTPUT_VARIABLE _OUT)
            else ()
                set(_OUT "Not implemented yet")
            endif ()
            string(REPLACE "${LIB_PATH}/" "" _OUT "${_OUT}")
            file(APPEND ${PATH} "---------- RPATH ----------\n${_OUT}\n")

            if (APPLE)
                execute_process(COMMAND bash -c "for f in `find ${LIB_PATH} -name *.dylib` ; do echo $f && otool -l $f | grep -A 3 LC_VERSION_MIN_MACOSX ; done" OUTPUT_VARIABLE _OUT)
            elseif (UNIX AND NOT APPLE)
                execute_process(COMMAND bash -c "for f in `find ${LIB_PATH} -name *.so` ; do echo $f && readelf -p .comment $f ; done" OUTPUT_VARIABLE _OUT)
            else ()
                set(_OUT "Not implemented yet")
            endif ()
            string(REPLACE "${LIB_PATH}/" "" _OUT "${_OUT}")
            file(APPEND ${PATH} "---------- COMPILER ----------\n${_OUT}\n")

        endif ()
    endforeach()
endfunction ()

function (PrintExternalsDownloadsNames PATH)
    file(WRITE ${PATH} "")

    get_property(PROJECTS GLOBAL PROPERTY external_projects)

    foreach(_PROJECT ${PROJECTS})
        set(EXTERNAL_NAME "${_PROJECT}${EXTERNAL_PROJECT_SUFFIX}")
        ExternalProject_Get_PropertyHack(${EXTERNAL_NAME} DOWNLOAD_NAME)
        file(APPEND ${PATH} "${DOWNLOAD_NAME}\n")
    endforeach()
endfunction ()

function (ExportExternalsHelper PATH_SH PATH_BAT PATH_MAP VAR_NAME PATH EXTERNAL_INSTALL_PATH)
    string(FIND ${PATH} "${EXTERNAL_INSTALL_PATH}/" IS_EXTERNAL_INSTALL_PATH)

    if (${IS_EXTERNAL_INSTALL_PATH} STREQUAL "-1")
        file(APPEND ${PATH_SH} "${VAR_NAME}=${PATH}\n")
        file(APPEND ${PATH_BAT} "set ${VAR_NAME}=${PATH}\n")
        file(APPEND ${PATH_MAP} "${VAR_NAME}=${PATH}\n")
    else ()
        string(REPLACE "${EXTERNAL_INSTALL_PATH}/" "" PATH_2 ${PATH})

        file(APPEND ${PATH_SH} "${VAR_NAME}=\$DEP_ROOT_PATH/${PATH_2}\n")
        file(APPEND ${PATH_BAT} "set ${VAR_NAME}=%DEP_ROOT_PATH%/${PATH_2}\n")
        file(APPEND ${PATH_MAP} "${VAR_NAME}=@DEP_ROOT_PATH@/${PATH_2}\n")
    endif()
endfunction ()

function (ExportExternals PATH_SH PATH_BAT PATH_MAP)
    file(WRITE ${PATH_SH} "#!/bin/bash\n\n")
    file(WRITE ${PATH_BAT} "")
    file(WRITE ${PATH_MAP} "")

    file(APPEND ${PATH_SH} "# generated by CMake\n\n")
    file(APPEND ${PATH_BAT} ":: generated by CMake\n\n")

    file(APPEND ${PATH_SH} "DEP_ROOT_PATH=$1\n\n")
    file(APPEND ${PATH_BAT} "set DEP_ROOT_PATH=%1\n\n")

    get_property(PROJECTS GLOBAL PROPERTY external_projects)

    set(COMMON_INCLUDE_SH)
    set(COMMON_LIBRARY_SH)
    set(COMMON_PREFIX_SH)

    set(COMMON_INCLUDE_BAT)
    set(COMMON_LIBRARY_BAT)
    set(COMMON_PREFIX_BAT)

    foreach(_PROJECT ${PROJECTS})
        set(INTERFACE_NAME "${_PROJECT}${EXTERNAL_PROJECT_INTERFACE_SUFFIX}")

        string(TOUPPER ${_PROJECT} PROJECT_NAME_UPPER)

        get_target_property(ROOT_PATH ${INTERFACE_NAME} external_root_path)
        get_target_property(BIN_PATH ${INTERFACE_NAME} external_bin_path)
        get_target_property(INC_PATH ${INTERFACE_NAME} external_inc_path)
        get_target_property(LIB_PATH ${INTERFACE_NAME} external_lib_path)
        get_target_property(PREFIX_PATH ${INTERFACE_NAME} external_prefix_path)

        if (ROOT_PATH)
            set(VAR_NAME "${PROJECT_NAME_UPPER}_ROOT_PATH")
            ExportExternalsHelper(${PATH_SH} ${PATH_BAT} ${PATH_MAP} ${VAR_NAME} ${ROOT_PATH} ${EXTERNAL_INSTALL_PATH})
        endif ()

        if (BIN_PATH)
            set(VAR_NAME "${PROJECT_NAME_UPPER}_BINARY_PATH")
            ExportExternalsHelper(${PATH_SH} ${PATH_BAT} ${PATH_MAP} ${VAR_NAME} ${BIN_PATH} ${EXTERNAL_INSTALL_PATH})
        endif ()

        if (INC_PATH)
            set(VAR_NAME "${PROJECT_NAME_UPPER}_INCLUDE_PATH")
            ExportExternalsHelper(${PATH_SH} ${PATH_BAT} ${PATH_MAP} ${VAR_NAME} ${INC_PATH} ${EXTERNAL_INSTALL_PATH})

            set(COMMON_INCLUDE_SH "${COMMON_INCLUDE_SH}:\$${VAR_NAME}")
            set(COMMON_INCLUDE_BAT "${COMMON_INCLUDE_BAT}:%${VAR_NAME}%")
        endif ()

        if (LIB_PATH)
            set(VAR_NAME "${PROJECT_NAME_UPPER}_LIBRARY_PATH")
            ExportExternalsHelper(${PATH_SH} ${PATH_BAT} ${PATH_MAP} ${VAR_NAME} ${LIB_PATH} ${EXTERNAL_INSTALL_PATH})

            set(COMMON_LIBRARY_SH "${COMMON_LIBRARY_SH}:\$${VAR_NAME}")
            set(COMMON_LIBRARY_BAT "${COMMON_LIBRARY_BAT}:%${VAR_NAME}%")
        endif ()

        if (PREFIX_PATH)
            set(VAR_NAME "${PROJECT_NAME_UPPER}_PREFIX_PATH")
            ExportExternalsHelper(${PATH_SH} ${PATH_BAT} ${PATH_MAP} ${VAR_NAME} ${PREFIX_PATH} ${EXTERNAL_INSTALL_PATH})

            set(COMMON_PREFIX_SH "${COMMON_PREFIX_SH}:\$${VAR_NAME}")
            set(COMMON_PREFIX_BAT "${COMMON_PREFIX_BAT}:%${VAR_NAME}%")
        endif ()

        file(APPEND ${PATH_SH} "\n")
        file(APPEND ${PATH_BAT} "\n")
    endforeach()

    # sh
    string(REGEX REPLACE "^:" "" COMMON_INCLUDE_SH_2 "${COMMON_INCLUDE_SH}") # здесь и далее нужны ""
    string(REGEX REPLACE "^:" "" COMMON_LIBRARY_SH_2 "${COMMON_LIBRARY_SH}")
    string(REGEX REPLACE "^:" "" COMMON_PREFIX_SH_2 "${COMMON_PREFIX_SH}")

    file(APPEND ${PATH_SH} "COMMON_INCLUDE_SH=${COMMON_INCLUDE_SH_2}\n")
    file(APPEND ${PATH_SH} "COMMON_LIBRARY_SH=${COMMON_LIBRARY_SH_2}\n\n")

    string(REPLACE ":" ";" COMMON_INCLUDE_SH_3 "${COMMON_INCLUDE_SH_2}")
    string(REPLACE ":" ";" COMMON_LIBRARY_SH_3 "${COMMON_LIBRARY_SH_2}")
    string(REPLACE ":" ";" COMMON_PREFIX_SH_3 "${COMMON_PREFIX_SH_2}")

    file(APPEND ${PATH_SH} "CMAKE_INCLUDE_PATH=\"${COMMON_INCLUDE_SH_3}\"\n")
    file(APPEND ${PATH_SH} "CMAKE_LIBRARY_PATH=\"${COMMON_LIBRARY_SH_3}\"\n")
    file(APPEND ${PATH_SH} "CMAKE_PREFIX_PATH=\"${COMMON_PREFIX_SH_3}\"\n")

    # bat
    string(REGEX REPLACE "^:" "" COMMON_INCLUDE_BAT_2 "${COMMON_INCLUDE_BAT}")
    string(REGEX REPLACE "^:" "" COMMON_LIBRARY_BAT_2 "${COMMON_LIBRARY_BAT}")
    string(REGEX REPLACE "^:" "" COMMON_PREFIX_BAT_2 "${COMMON_PREFIX_BAT}")

    string(REPLACE ":" ";" COMMON_INCLUDE_BAT_3 "${COMMON_INCLUDE_BAT_2}")
    string(REPLACE ":" ";" COMMON_LIBRARY_BAT_3 "${COMMON_LIBRARY_BAT_2}")
    string(REPLACE ":" ";" COMMON_PREFIX_BAT_3 "${COMMON_PREFIX_BAT_2}")

    file(APPEND ${PATH_BAT} "set CMAKE_INCLUDE_PATH=\"${COMMON_INCLUDE_BAT_3}\"\n")
    file(APPEND ${PATH_BAT} "set CMAKE_LIBRARY_PATH=\"${COMMON_LIBRARY_BAT_3}\"\n")
    file(APPEND ${PATH_BAT} "set CMAKE_PREFIX_PATH=\"${COMMON_PREFIX_BAT_3}\"\n")
endfunction ()
