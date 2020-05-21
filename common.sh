#!/bin/bash

set -e
#set -x

#----------------------------------------
# How to use
#----------------------------------------

function print_help
{
echo "
Usage: common.sh OPERATION [TARGET] [OPTIONS]

    OPERATION: must be one of

        help                        Print this help

        long-term-env=PASSWORD      Long-term environment: automake, autotool, cmake and etc.
                                    Need PASSWORD for 'sudo make install'
                                    Depends: [target, host]

        short-term-env=PASSWORD     Short-term environment: compiler and other per build/combination
                                    Depends: [target, host, compiler, and other params]

        build-libs                  Build external dependencies (aka 'superbuild' in CMake terms).
                                    It will NOT DELETE tmp build/install dirs.
                                    Depends: [target, host, compiler, code version]
                                    For example, result dir name are: server_debian_8_64_gcc-4.9_v001

        build-project               Call CMake for configure and build project

        get-libs                    Get path to dependencies and its version through --out-file

    OPTIONS

        --target=                   [MUST]
            server-for-debian-8-64  Server for Debian 8 64
            server-for-debian-9-64  Server for Debian 9 64
            server-for-windows-64   Server for Windows 64
            server-for-windows-32   Server for Windows 32
            client-for-macos        Client for macOS
            client-for-linux-32     Client for Linux 32
            client-for-linux-64     Client for Linux 64
            client-for-windows-32   Client for Windows 32
            client-for-windows-64   Client for Windows 64
            client-for-android      Client for Android
            client-for-ios          Client for iOS

        --compiler=
            default                 Use default compiler (by target)
            gcc-4.9                 (default for Debian 8)
            gcc-6                   (default for Debian 9)
            gcc-7.4                 (default for Ubuntu 18.04)
            clang-8
            clang-11                (default for macOS)
            xcode-10                (default for iOS)
            xcode-11                (experimantal for iOS)
            vs-2015                 (default for Windows-7/10)

        --build-type=               CMake-like build type
            Release                 (default)
            Debug
            RelWithDebInfo

        --env-path                  Point to environment dir (temporary for bootstraping, downloading etc.)
        --dep-path                  Point to dependencies
        --pro-path                  Point to project sources
        --arg-file                  Point to file with per-target arguments for build
        --out-file                  Point to file with returned data (for Jenkins only)

        --build-jobs                Number of build jobs for project build
        --external-build-jobs       Number of build jobs for external dependencies

Example: prepare build machine for build at all

    bash common.sh long-term-env=PASSWORD --target=

Example: prepare build machine before the build

    bash common.sh short-term-env=PASSWORD --target=

Example: build libraries

    bash common.sh build-libs --target=server-for-debian-8-64 --env-path= --dep-path=

Example: build project

    bash common.sh build-project --target=server-for-debian-8-64 --dep-path= --pro-path= --arg-file=

Example: get project dependencies through --out-file

    bash common.sh get-libs --target=server-for-debian-8-64 --dep-path= --out-file=

"
}

#----------------------------------------
# Fixed vars
#----------------------------------------

# версия зависимостей для сборки их самих и версия зависимостей для сборки проекта
# могут отличатся, например, для предварительной сборки новой версии зависимостей при использовании старой
DEP_VERSION_NUM=7
PRO_VERSION_NUM=7

#----------------------------------------
# Incoming vars
#----------------------------------------

OPERATION=
TARGET=
COMPILER=
BUILD_TYPE=

ENV_ROOT_PATH=
DEP_ROOT_PATH=
PRO_ROOT_PATH=
ARG_FILE=
OUT_FILE=

SUDO_PASSWORD=
BUILD_JOBS=             # default value at discover_host()
EXTERNAL_BUILD_JOBS=    # default value at discover_host()

#----------------------------------------
# Produced vars
#----------------------------------------

HOST=                   # LINUX / DARWIN / WINDOWS
HOST_DETAIL=            # UBUNTU / DEBIAN / WINDOWS
HOST_VERSION=           # 8 / 9 / 7 / 10
HOST_ARCH=              # 32 / 64
DEFAULT_COMPILER=
TARGET_ARCH=
ENV_DOWNLOAD_PATH=
DEP_VERSIONS_ROOT_PATH=
THIS_SCRIPT_PATH=

#----------------------------------------
# Directory Structure
#----------------------------------------

#    
#  ENV_ROOT_PATH
#      ...
#      download
#
#  DEP_ROOT_PATH
#      build
#          server_debian_8_64_v001
#              gcc64
#                  Release
#          ...
#
#      versions (DEP_VERSIONS_ROOT_PATH)
#          server_debian_8_64_v001
#              gcc64
#                  Release
#              clang8
#                  Debug
#          server_windows_7_32_v004
#              vc-2015
#                  Release
#          ...
#
#    _build_scripts 
#         new_build
#             cmake_new_build (THIS_SCRIPT_PATH)
#                 common.sh
#
# PRO_ROOT_PATH
#    ...
#

function define_common_dirs
{
    THIS_SCRIPT_PATH=$(dirname "$(readlink -f "$0")")
    ENV_DOWNLOAD_PATH=$ENV_ROOT_PATH/download
    DEP_VERSIONS_ROOT_PATH=$DEP_ROOT_PATH/versions

    echo "THIS_SCRIPT_PATH : '$THIS_SCRIPT_PATH'"
    echo "ENV_ROOT_PATH    : '$ENV_ROOT_PATH'"
    echo "DEP_ROOT_PATH    : '$DEP_ROOT_PATH'"
    echo "PRO_ROOT_PATH    : '$PRO_ROOT_PATH'"
    echo "ARG_FILE         : '$ARG_FILE'"
    echo "OUT_FILE         : '$OUT_FILE'"
}

#----------------------------------------
# Host and Target Combination
#----------------------------------------

function discover_host
{
    # Linux, Darwin, Windows
    local LOCAL_HOST=$(uname -s)
    local LOCAL_HOST_DETAIL=
    local LOCAL_HOST_ARCH=

    if [[ $LOCAL_HOST == "Linux" ]]; then
        HOST=LINUX
    elif [[ $LOCAL_HOST == "Darwin" ]]; then
        HOST=DARWIN
    elif [[ $LOCAL_HOST == *"CYGWIN"* ]]; then
        HOST=WINDOWS
    fi

    if [[ $HOST == "LINUX" ]]; then

        LOCAL_HOST_DETAIL=$(lsb_release -a)

        if [[ $LOCAL_HOST_DETAIL == *"Ubuntu"* ]] ; then
            HOST_DETAIL=UBUNTU
            HOST_VERSION=18
        elif [[ $LOCAL_HOST_DETAIL == *"jessie"* ]] ; then
            HOST_DETAIL=DEBIAN
            HOST_VERSION=8
        elif [[ $LOCAL_HOST_DETAIL == *"stretch"* ]] ; then
            HOST_DETAIL=DEBIAN
            HOST_VERSION=9
        fi

        LOCAL_HOST_ARCH=$(getconf LONG_BIT)
        HOST_ARCH=$([ $LOCAL_HOST_ARCH -eq 64 ] && echo 64 || echo 32)

        BUILD_JOBS=$(nproc)
        EXTERNAL_BUILD_JOBS=$BUILD_JOBS

    elif [[ $HOST == "DARWIN" ]]; then

        HOST_DETAIL="DARWIN"
        HOST_VERSION=10

        LOCAL_HOST_ARCH=$(getconf LONG_BIT)
        HOST_ARCH=$([ $LOCAL_HOST_ARCH -eq 64 ] && echo 64 || echo 32)

        BUILD_JOBS=$(sysctl -n hw.ncpu)
        EXTERNAL_BUILD_JOBS=$BUILD_JOBS
        
        source /etc/profile

    elif [[ $HOST == "WINDOWS" ]]; then

        LOCAL_HOST_DETAIL=$(wmic os get Caption)

        if [[ $LOCAL_HOST_DETAIL == *"Windows 7"* ]]; then
            HOST_DETAIL=WINDOWS
            HOST_VERSION=7
        elif [[ $LOCAL_HOST_DETAIL == *"Windows 10"* ]]; then
            HOST_DETAIL=WINDOWS
            HOST_VERSION=10
        fi

        LOCAL_HOST_ARCH=$(wmic os get osarchitecture)
        HOST_ARCH=$([[ $LOCAL_HOST_ARCH == *"64-"* ]] && echo 64 || echo 32)

        BUILD_JOBS=$(nproc)
        EXTERNAL_BUILD_JOBS=$BUILD_JOBS
    fi

    if [[ -z $HOST ]]; then
        echo "'uname -a' get '$LOCAL_HOST', but HOST is not selected, see 'help'"
        exit 1
    fi

    if [[ -z $HOST_DETAIL ]]; then
        echo "get '$LOCAL_HOST_DETAIL', but HOST_DETAIL is not selected, see 'help'"
        exit 1
    fi

    if [[ -z $HOST_VERSION ]]; then
        echo "HOST_VERSION is not selected, see 'help'"
        exit 1
    fi

    if [[ -z $HOST_ARCH ]]; then
        echo "get '$LOCAL_HOST_ARCH', but HOST_ARCH is not selected, see 'help'"
        exit 1
    fi
}

function check_host_target_combination
{
    if [[ -z $TARGET ]]; then
        echo "TARGET is not selected, see 'help'"
        exit 1
    fi

    local IS_HOST_TARGET_CORRECT=
    local COMBINATION_MESSAGE=

    if [[ $TARGET == CLIENT_FOR_ANDROID && $HOST == LINUX && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=default
        COMBINATION_MESSAGE="Client for Android (build on Linux x64)"

    elif [[ $TARGET == CLIENT_FOR_IOS && $HOST == DARWIN && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=xcode-10
        COMBINATION_MESSAGE="Client for iOS (build on macOS Catalina 10.15)"

    elif [[ $TARGET == SERVER_FOR_DEBIAN_8_64 && $HOST_DETAIL == DEBIAN && $HOST_VERSION == 8 && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=gcc-4.9
        COMBINATION_MESSAGE="Server for Debian 8 x64 (build on Debian 8 x64)"

    elif [[ $TARGET == SERVER_FOR_DEBIAN_9_64 && $HOST_DETAIL == DEBIAN && $HOST_VERSION == 9 && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=gcc-6
        COMBINATION_MESSAGE="Server for Debian 9 x64 (build on Debian 9 x64)"

    elif [[ $TARGET == SERVER_FOR_WINDOWS_32 && $HOST == WINDOWS && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=vs-2015
        COMBINATION_MESSAGE="Server for Windows x86 (build on Windows 10 x64)"

    elif [[ $TARGET == SERVER_FOR_WINDOWS_64 && $HOST == WINDOWS && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=vs-2015
        COMBINATION_MESSAGE="Server for Windows x64 (build on Windows 10 x64)"

    elif [[ $TARGET == CLIENT_FOR_WINDOWS_32 && $HOST == WINDOWS && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=vs-2015
        COMBINATION_MESSAGE="Client for Windows x86 (build on Windows 10 x64)"

    elif [[ $TARGET == CLIENT_FOR_WINDOWS_64 && $HOST == WINDOWS && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=vs-2015
        COMBINATION_MESSAGE="Client for Windows x64 (build on Windows 10 x64)"

    elif [[ $TARGET == CLIENT_FOR_MACOS && $HOST == DARWIN && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=clang-11
        COMBINATION_MESSAGE="Client for macOS (build on macOS Catalina 10.15)"

    elif [[ $TARGET == CLIENT_FOR_LINUX_32 && $HOST == LINUX && $HOST_ARCH == 32 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=gcc-7.4
        COMBINATION_MESSAGE="Client for Linux x86 (build on Ubuntu 18.04 LTS x32)"

    elif [[ $TARGET == CLIENT_FOR_LINUX_64 && $HOST == LINUX && $HOST_ARCH == 64 ]]; then

        IS_HOST_TARGET_CORRECT=1
        DEFAULT_COMPILER=gcc-7.4
        COMBINATION_MESSAGE="Client for Linux x64 (build on Ubuntu 18.04 LTS x64)"

    fi

    if [[ -z $IS_HOST_TARGET_CORRECT ]]; then
        echo "Select: $TARGET on $HOST / $HOST_DETAIL / $HOST_VERSION/ $HOST_ARCH in NOT correct or NOT supported yet, see 'help'"
        exit 1
    fi

    if [[ -z $DEFAULT_COMPILER ]]; then
        echo "unknown default compiler, see 'help'"
        exit 1
    fi

    local COMPILER_MESSAGE=
   
    if [[ -n $COMPILER ]]; then

        if [[ $COMPILER == default ]]; then
            COMPILER=$DEFAULT_COMPILER
        fi

        COMPILER_MESSAGE="compiler '$COMPILER' by user (default is '$DEFAULT_COMPILER')"
    else
        COMPILER=$DEFAULT_COMPILER
        COMPILER_MESSAGE="compiler '$COMPILER' by default"
    fi

    echo "Select: $COMBINATION_MESSAGE, $COMPILER_MESSAGE"
}

function check_redefine_and_set_target
{
    if [[ -n $TARGET ]]; then
        echo "TARGET is already set to '$TARGET', redefinition to '$1' is not possible"
        exit 1
    fi

    if [[ $1 == server-for-debian-8-64 ]]; then
        TARGET=SERVER_FOR_DEBIAN_8_64
        TARGET_ARCH=64
    elif [[ $1 == server-for-debian-9-64 ]]; then
        TARGET=SERVER_FOR_DEBIAN_9_64
        TARGET_ARCH=64
    elif [[ $1 == server-for-windows-32 ]]; then
        TARGET=SERVER_FOR_WINDOWS_32
        TARGET_ARCH=32
    elif [[ $1 == server-for-windows-64 ]]; then
        TARGET=SERVER_FOR_WINDOWS_64
        TARGET_ARCH=64
    elif [[ $1 == client-for-macos ]]; then
        TARGET=CLIENT_FOR_MACOS
        TARGET_ARCH=64
    elif [[ $1 == client-for-linux-32 ]]; then
        TARGET=CLIENT_FOR_LINUX_32
        TARGET_ARCH=32
    elif [[ $1 == client-for-linux-64 ]]; then
        TARGET=CLIENT_FOR_LINUX_64
        TARGET_ARCH=64
    elif [[ $1 == client-for-windows-32 ]]; then
        TARGET=CLIENT_FOR_WINDOWS_32
        TARGET_ARCH=32
    elif [[ $1 == client-for-windows-64 ]]; then
        TARGET=CLIENT_FOR_WINDOWS_64
        TARGET_ARCH=64
    elif [[ $1 == client-for-android ]]; then
        TARGET=CLIENT_FOR_ANDROID
        TARGET_ARCH=64
    elif [[ $1 == client-for-ios ]]; then
        TARGET=CLIENT_FOR_IOS
        TARGET_ARCH=64
    else
        echo "unknown target '$1', see 'help'"
        exit 1
    fi
}

function check_redefine_and_set_compiler
{
    if [[ -n $COMPILER ]]; then
        echo "COMPILER is already set to '$COMPILER', redefinition to '$1' is not possible"
        exit 1
    fi

    if [[ $1 == default || $1 == gcc-4.9 || $1 == gcc-6 ||
          $1 == clang-8 || $1 == clang-11 ||
          $1 == xcode-10 || $1 == xcode-11 ||
          $1 == vc-2015 ]]; then
        :
    else
        echo "unknown compiler '$1', see 'help'"
        exit 1
    fi

    COMPILER=$1
}

function check_redefine_and_set_build_type
{
    if [[ -n $BUILD_TYPE ]]; then
        echo "BUILD_TYPE is already set to '$BUILD_TYPE', redefinition to '$1' is not possible"
        exit 1
    fi

    if [[ $1 == Release || $1 == Debug || $1 == RelWithDebInfo ]]; then
        :
    else
        echo "unknown build type '$1', see 'help'"
        exit 1
    fi

    BUILD_TYPE=$1
}

#----------------------------------------
# Warm-up environment
#----------------------------------------

function environment_cmake_check
{
    if [[ -n $(which cmake) ]]; then
        local VERSION_STR=$(cmake --version)
        local VERSION=$(echo "$VERSION_STR" | grep -Po '(?<=cmake version )[^;]+')
        echo $(dpkg --compare-versions "$VERSION" "ge" "3.13.4" && echo $?)
    fi
}

function environment_cmake_install
{
    if [[ -z $(environment_cmake_check) ]]; then

        local CMAKE_VERSION=3.13.4 # we want

        # remove any installed cmake
        echo $SUDO_PASSWORD | sudo -S apt remove -y --purge --auto-remove cmake

        # temporary using g++ and ssl for build
        echo $SUDO_PASSWORD | sudo -S apt install -y libssl-dev

        local TEMP_PATH=$ENV_ROOT_PATH/bootstrap_cmake

        mkdir -p $TEMP_PATH

        cd $TEMP_PATH

        local NAME=cmake-$CMAKE_VERSION

        if [[ ! -f $NAME.tar.gz ]]; then
            wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/$NAME.tar.gz
        fi

        tar -xzvf $NAME.tar.gz

        cd $NAME

        ./bootstrap --no-system-libs --parallel=$(nproc) -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_USE_OPENSSL=ON
        make -j8
        echo $SUDO_PASSWORD | sudo -S make install

        # remove temporaries
        echo $SUDO_PASSWORD | sudo -S apt remove -y libssl-dev

        cd ..

        rm -rf $NAME
    fi
}

function environment_compilers_install
{
    echo $SUDO_PASSWORD | sudo -S apt-add-repository "deb http://ftp.us.debian.org/debian/ jessie main contrib non-free"
    echo $SUDO_PASSWORD | sudo -S apt-add-repository "deb http://ftp.us.debian.org/debian/ stretch main contrib non-free"

    local TEMP_PATH=$ENV_ROOT_PATH/bootstrap_clang

    mkdir -p $TEMP_PATH

    cd $TEMP_PATH

    if [[ ! -f llvm-snapshot.gpg.key ]]; then
        wget https://apt.llvm.org/llvm-snapshot.gpg.key
    fi

    echo $SUDO_PASSWORD | sudo -S apt-key add llvm-snapshot.gpg.key

    if  [[ $TARGET == SERVER_FOR_DEBIAN_8_64 ]]; then
        echo $SUDO_PASSWORD | sudo -S apt-add-repository "deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-8 main"
    elif [[ $TARGET == SERVER_FOR_DEBIAN_9_64 ]]; then
        echo $SUDO_PASSWORD | sudo -S apt-add-repository "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-8 main"
    else
        echo "'environment_clang8_install' not implemented yet"
        exit 1
    fi

    set +e
    echo $SUDO_PASSWORD | sudo -S apt update
    set -e
    echo $SUDO_PASSWORD | sudo -S apt install -y gcc-4.9 g++-4.9 gcc-6 g++-6 clang-8 clang-tools-8 lld-8 libc++-8-dev libc++abi-8-dev
}

function environment_compilers_alternatives
{
    # from: https://gist.github.com/ArseniyShestakov/a458b96a354014f80ab8d95676100c03

    # Cleanup old alternatives
    set +e
    echo $SUDO_PASSWORD | sudo -S update-alternatives --remove-all cc
    echo $SUDO_PASSWORD | sudo -S update-alternatives --remove-all c++

    echo $SUDO_PASSWORD | sudo -S update-alternatives --remove-all gcc 
    echo $SUDO_PASSWORD | sudo -S update-alternatives --remove-all g++

    echo $SUDO_PASSWORD | sudo -S update-alternatives --remove-all clang
    echo $SUDO_PASSWORD | sudo -S update-alternatives --remove-all clang++
    
    echo $SUDO_PASSWORD | sudo -S update-alternatives --remove-all ld
    set -e

    # Add GCC versions
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 10
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 20

    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 10
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 20

    # Add Clang versions
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/clang clang /usr/bin/clang-8 10
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-8 10

    # Add compilers
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-4.9 10
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-6 20
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/cc cc /usr/bin/clang-8 30

    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-4.9 10
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-6 20
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-8 30

    # Add linkers
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/ld ld /usr/bin/ld.bfd 10
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/ld ld /usr/bin/ld.gold 20
    echo $SUDO_PASSWORD | sudo -S update-alternatives --install /usr/bin/ld ld /usr/bin/lld-8 30
}

function environment_gcc49_select
{
    echo "Select: gcc-4.9 / g++-4.9"

    echo $SUDO_PASSWORD | sudo -S update-alternatives --set gcc /usr/bin/gcc-4.9
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set g++ /usr/bin/g++-4.9
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set cc /usr/bin/gcc-4.9
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set c++ /usr/bin/g++-4.9
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set ld /usr/bin/ld.bfd
}

function environment_gcc63_select
{
    echo "Select: gcc-6 / g++-6"
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set gcc /usr/bin/gcc-6
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set g++ /usr/bin/g++-6
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set cc /usr/bin/gcc-6
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set c++ /usr/bin/g++-6
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set ld /usr/bin/ld.bfd
}

function environment_clang_select
{
    echo "Select: clang-8 / clang++-8"
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set cc /usr/bin/clang-8
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set c++ /usr/bin/clang++-8
    echo $SUDO_PASSWORD | sudo -S update-alternatives --set ld /usr/bin/lld-8
}

function long_term_environment
{
    if  [[ $TARGET == SERVER_FOR_DEBIAN_8_64 || $TARGET == SERVER_FOR_DEBIAN_9_64 ]]; then

        export DEBIAN_FRONTEND=noninteractive

        echo $SUDO_PASSWORD | sudo -S apt install -y software-properties-common rsync libbz2-dev scons build-essential ncftp gettext 

        environment_compilers_install
        environment_compilers_alternatives

        environment_cmake_install

    elif [[ $TARGET == SERVER_FOR_WINDOWS_32 || $TARGET == SERVER_FOR_WINDOWS_64 ||
            $TARGET == CLIENT_FOR_WINDOWS_32 || $TARGET == CLIENT_FOR_WINDOWS_64 ]]; then

        # на данный момент выполнить руками, т.к. возможно отсутствие пакетов/нужны ручные манипуляции и т.п.

        choco install -y python2 # используется в общем
        choco install -y python3 # используется для сборки icu
        choco install -y pip
        # после чего убрать из Path пути к c:/Python37, удалить все PYTHONHOME и PYTHONPATH (пользователя и глобальные)
        # должно быть: c:/Python27;c:/Python27/Scripts
        pip install scons
        choco install -y activeperl jom rsync 7zip.install ncftp
        choco install -y wget --version 1.20 # last ver had SSL problem
        choco install -y cmake --force --installargs 'ADD_CMAKE_TO_PATH=System'
        # BuildTools не подходят, т.к. апгрейд солюшенов выполняет только devenv.exe
        # в Студии зайти под каким-нить аккаунтом, чтобы она могла скачать лицензию, а потом выйти из аккаунта
        # TODO не ставит C++ :))) - нужно через Изменить доставить руками
        choco install -y visualstudio2015community --timeout 5400 

        if [[ $TARGET == CLIENT_FOR_WINDOWS_32 || $TARGET == CLIENT_FOR_WINDOWS_64 ]]; then

            choco install -y nasm # добавить в PATH 'C:\Program Files\NASM' (на 4.7.2019)
            choco install -y yasm activetcl ruby wixtoolset
            # в cygwin доставить (C:\tools\cygwin\cygwinsetup): make, autoconf (который враппер, он поставит остальное), perl, patch

            # DirectShow
            # установить https://www.microsoft.com/en-us/download/confirmation.aspx?id=8279
            # собрать C:\Program Files\Microsoft SDKs\Windows\v7.1\Samples\multimedia\directshow\baseclasses\baseclasses.sln

            # установить DW в C:\dependency_walker\
            # TODO можно через choco
        fi

    elif  [[ $TARGET == CLIENT_FOR_MACOS ]]; then

        brew install coreutils # ln -s /usr/local/bin/greadlink /usr/local/bin/readlink
        brew install autoconf automake autogen libtool makedepend gettext yasm p7zip ncftp cmake
        brew link --force gettext
        pip install dmgbuild

    elif [[ $TARGET == CLIENT_FOR_LINUX_32 || $TARGET == CLIENT_FOR_LINUX_64 ]]; then

        echo $SUDO_PASSWORD | sudo -S apt install -y autoconf automake autogen libtool build-essential g++ ncftp \
        python3-distutils tcl-dev libasound2-dev libpulse-dev yasm python libgl1-mesa-dev libglu1-mesa-dev \
        libxrender-dev libxcomposite-dev libxss-dev libfuse-dev bison flex gperf ruby p7zip-full patchelf \
        libfreetype6-dev gtk2.0

        environment_cmake_install

    elif  [[ $TARGET == CLIENT_FOR_IOS ]]; then

        # TODO path to Qt5.5.0
        local PATH_TO_QT=

        # patch Qt5.5.0
        source /etc/profile
        gsed -i 's@xcrun -find xcrun 2@xcrun -find xcodebuild 2@g' ${PATH_TO_QT}/5.5/ios/mkspecs/features/mac/default_pre.prf
        gsed -i 's@QMAKE_XCODE_VERSION = @QMAKE_XCODE_VERSION = 9.9 # @g' ${PATH_TO_QT}/5.5/ios/mkspecs/features/mac/default_pre.prf
        gsed -i 's@8.0@12.1@g' ${PATH_TO_QT}/5.5/ios/mkspecs/macx-ios-clang/features/sdk.prf

    elif  [[ $TARGET == CLIENT_FOR_ANDROID ]]; then
        :
    else
        echo "'long_term_environment' not implemented yet"
        exit 1
    fi
}

function short_term_environment
{
    if  [[ $TARGET == SERVER_FOR_DEBIAN_8_64 || $TARGET == SERVER_FOR_DEBIAN_9_64 ]]; then

        if [[ $COMPILER == gcc-4.9 ]]; then
            environment_gcc49_select
        elif [[ $COMPILER == gcc-6 ]]; then
            environment_gcc63_select
        elif [[ $COMPILER == clang-8 ]]; then
            environment_clang_select
        fi

    elif [[ $TARGET == SERVER_FOR_WINDOWS_32 || $TARGET == SERVER_FOR_WINDOWS_64 ||
            $TARGET == CLIENT_FOR_WINDOWS_32 || $TARGET == CLIENT_FOR_WINDOWS_64 ]]; then
        :
    elif [[ $TARGET == CLIENT_FOR_MACOS ]]; then
        :
    elif [[ $TARGET == CLIENT_FOR_LINUX_32 || $TARGET == CLIENT_FOR_LINUX_64 ]]; then
        :
    elif [[ $TARGET == CLIENT_FOR_IOS ]]; then
        :
    elif [[ $TARGET == CLIENT_FOR_ANDROID ]]; then
        :
    else
        echo "'short_term_environment' not implemented yet"
        exit 1
    fi
}

#----------------------------------------
# Dependencies versions/directory
#----------------------------------------

# input dependencies version

function find_dependencies_data
{
    local VERSION_NUM=$1

    local PREFIX_STR=

    if [[ $TARGET == SERVER_FOR_DEBIAN_8_64 || $TARGET == SERVER_FOR_DEBIAN_9_64 ]]; then
        PREFIX_STR="server_debian"
    elif [[ $TARGET == SERVER_FOR_WINDOWS_32 || $TARGET == SERVER_FOR_WINDOWS_64 ]]; then
        PREFIX_STR="server_windows"
    elif [[ $TARGET == CLIENT_FOR_WINDOWS_32 || $TARGET == CLIENT_FOR_WINDOWS_64 ]]; then
        PREFIX_STR="client_windows"
    elif [[ $TARGET == CLIENT_FOR_MACOS ]]; then
        PREFIX_STR="client_macos"
    elif [[ $TARGET == CLIENT_FOR_LINUX_32 || $TARGET == CLIENT_FOR_LINUX_64 ]]; then
        PREFIX_STR="client_linux"
    elif [[ $TARGET == CLIENT_FOR_IOS ]]; then
        PREFIX_STR="client_ios"
    elif [[ $TARGET == CLIENT_FOR_ANDROID ]]; then
        PREFIX_STR="client_android"
    else
        echo "'find_dependencies_data' not implemented yet"
        exit 1
    fi

    local VERSION_STR_DECORATED=$(printf "%03d" $VERSION_NUM)
    local COMPILER_STR=$COMPILER
    local BUILD_TYPE_STR=$BUILD_TYPE

    local VERSION_RELATIVE_PATH="${PREFIX_STR}_${HOST_VERSION}_${TARGET_ARCH}_v${VERSION_STR_DECORATED}/$COMPILER_STR/$BUILD_TYPE_STR"

    local VERSION_PATH="$DEP_VERSIONS_ROOT_PATH/$VERSION_RELATIVE_PATH"

    local IS_BUILD_OK=$([ -f $VERSION_PATH/dependencies_build.ok ] && echo 1 || echo 0)

    echo $VERSION_PATH $VERSION_RELATIVE_PATH $VERSION_NUM $IS_BUILD_OK
}

#----------------------------------------
# Build dependencies
#----------------------------------------

function cyg_to_win
{
    echo $(cygpath -w $1 | sed 's@\\@\/@g')
}

function build_libs
{
    local VERSION_PATH=
    local VERSION_RELATIVE_PATH=
    local IS_BUILD_OK=

    read VERSION_PATH VERSION_RELATIVE_PATH VERSION_NUM IS_BUILD_OK < <(find_dependencies_data $DEP_VERSION_NUM)

    if [[ $IS_BUILD_OK == 1 ]]; then
        echo "Dependencies root was found at, start INCREMENTAL build: '$VERSION_PATH'"
    else
        echo "Dependencies root was NOT found or incorrect at, start INCREMENTAL build: '$VERSION_PATH'"
    fi

    local TEMP_ROOT_PATH=$DEP_ROOT_PATH/build
    local BUILD_PATH=$TEMP_ROOT_PATH/$VERSION_RELATIVE_PATH

    mkdir -p $BUILD_PATH
    mkdir -p $VERSION_PATH

    cd $BUILD_PATH

    if [[ $TARGET == SERVER_FOR_DEBIAN_8_64 || $TARGET == SERVER_FOR_DEBIAN_9_64 ]]; then

        source $THIS_SCRIPT_PATH/dependencies_linux.sh

    elif [[ $TARGET == SERVER_FOR_WINDOWS_32 || $TARGET == SERVER_FOR_WINDOWS_64 ||
            $TARGET == CLIENT_FOR_WINDOWS_32 || $TARGET == CLIENT_FOR_WINDOWS_64 ]]; then

        # redirect to native 'cmd'
        local BAT=$THIS_SCRIPT_PATH/dependencies_windows.bat

        # требует запуск Jenkins agent.jar из-под Администратора
        # (https://www.techgainer.com/create-batch-file-automatically-run-administrator/)
        chmod +x $BAT

        $BAT \
            $(cyg_to_win $THIS_SCRIPT_PATH) \
            $BUILD_TYPE \
            $(cyg_to_win $VERSION_PATH) \
            $(cyg_to_win $VERSION_RELATIVE_PATH) \
            $EXTERNAL_BUILD_JOBS \
            $(cyg_to_win $ENV_DOWNLOAD_PATH) \
            $TARGET_ARCH \
            $TARGET

    elif [[ $TARGET == CLIENT_FOR_MACOS ]]; then

        source $THIS_SCRIPT_PATH/dependencies_linux.sh

    elif [[ $TARGET == CLIENT_FOR_LINUX_32 || $TARGET == CLIENT_FOR_LINUX_64 ]]; then

        source $THIS_SCRIPT_PATH/dependencies_linux.sh

    elif [[ $TARGET == CLIENT_FOR_IOS ]]; then
        : # TODO
    elif [[ $TARGET == CLIENT_FOR_ANDROID ]]; then
        : # TODO
    else
        echo "'build_libs' not implemented yet"
        exit 1
    fi

    echo "write file 'dependencies_build.ok' to '$VERSION_PATH' as flag of success build"
    echo OK > $VERSION_PATH/dependencies_build.ok
}

#----------------------------------------
# Build projects
#----------------------------------------

function build_project
{
    local VERSION_PATH=
    local VERSION_RELATIVE_PATH=
    local IS_BUILD_OK=

    read VERSION_PATH VERSION_RELATIVE_PATH VERSION_NUM IS_BUILD_OK < <(find_dependencies_data $PRO_VERSION_NUM)

    if [[ $IS_BUILD_OK == 1 ]]; then
        echo "Dependencies root was found at: '$VERSION_PATH'"
    else
        echo "Dependencies root was NOT found at: '$VERSION_PATH'"
        exit 1
    fi

    if [[ $TARGET == SERVER_FOR_DEBIAN_8_64 || $TARGET == SERVER_FOR_DEBIAN_9_64 ]]; then

        source project_server_linux.sh

    elif [[ $TARGET == SERVER_FOR_WINDOWS_32 || $TARGET == SERVER_FOR_WINDOWS_64 ]]; then

        # redirect to native 'cmd'
        local BAT=$THIS_SCRIPT_PATH/project_server_windows.bat

        # требует запуск Jenkins agent.jar из-под Администратора
        # (https://www.techgainer.com/create-batch-file-automatically-run-administrator/)
        chmod +x $BAT 

        $BAT \
            $(cyg_to_win $VERSION_PATH) \
            $(cyg_to_win $PRO_ROOT_PATH) \
            $BUILD_TYPE \
            $TARGET_ARCH \
            $ARG_FILE

    elif [[ $TARGET == CLIENT_FOR_WINDOWS_32 || $TARGET == CLIENT_FOR_WINDOWS_64 ]]; then

        # redirect to native 'cmd'
        local BAT=$THIS_SCRIPT_PATH/project_client_windows.bat

        # требует запуск Jenkins agent.jar из-под Администратора
        # (https://www.techgainer.com/create-batch-file-automatically-run-administrator/)
        chmod +x $BAT

        $BAT \
            $(cyg_to_win $VERSION_PATH) \
            $(cyg_to_win $PRO_ROOT_PATH) \
            $BUILD_TYPE \
            $TARGET_ARCH \
            $ARG_FILE

    elif [[ $TARGET == CLIENT_FOR_MACOS ]]; then

        source project_client_macos.sh

    elif [[ $TARGET == CLIENT_FOR_LINUX_32 || $TARGET == CLIENT_FOR_LINUX_64 ]]; then

        source project_client_linux.sh

    elif [[ $TARGET == CLIENT_FOR_IOS ]]; then

        source project_client_ios.sh

    elif [[ $TARGET == CLIENT_FOR_ANDROID ]]; then

        source project_client_android.sh

    else
        echo "'build_project' not implemented yet"
        exit 1
    fi
}

#----------------------------------------
# Get dependencies
#----------------------------------------

function get_libs
{
    if [[ -n $OUT_FILE ]]; then
        read VERSION_PATH VERSION_RELATIVE_PATH VERSION_NUM IS_BUILD_OK < <(find_dependencies_data $DEP_VERSION_NUM)
        echo $VERSION_RELATIVE_PATH > $OUT_FILE
        echo $VERSION_NUM >> $OUT_FILE

        read VERSION_PATH VERSION_RELATIVE_PATH VERSION_NUM IS_BUILD_OK < <(find_dependencies_data $PRO_VERSION_NUM)
        echo $VERSION_RELATIVE_PATH >> $OUT_FILE
        echo $VERSION_NUM >> $OUT_FILE
    fi
}

#----------------------------------------
# Some functions
#----------------------------------------

function check_redefine_and_set_operation
{
    if [[ -n $OPERATION ]]; then
        echo "OPERATION is already set to '$OPERATION', redefinition to '$1' is not possible"
        exit 1
    fi

    OPERATION=$1
}

#----------------------------------------
# Print Help
#----------------------------------------

for i in "$@"; do
    case $i in
        help)
            print_help
            exit 0
            ;;
    esac
done

#----------------------------------------
# Discovering HOST, OPERATION and a lot of OPTIONS
#----------------------------------------

discover_host

# then discover OPERATION and a lot of OPTIONS
for i in "$@"; do
    case $i in

        # operations

        long-term-env=*)
            check_redefine_and_set_operation long-term-env
            SUDO_PASSWORD="${i#*=}"
            ;;

        short-term-env=*)
            check_redefine_and_set_operation short-term-env
            SUDO_PASSWORD="${i#*=}"
            ;;

        build-libs)
            check_redefine_and_set_operation build-libs
            ;;

        build-project)
            check_redefine_and_set_operation build-project
            ;;

        get-libs)
            check_redefine_and_set_operation get-libs
            ;;

        # options

        --target=*)
            check_redefine_and_set_target "${i#*=}"
            ;;

        --compiler=*)
            check_redefine_and_set_compiler "${i#*=}"
            ;;

        --build-type=*)
            check_redefine_and_set_build_type "${i#*=}"
            ;;

        --pro-path=*)
            PRO_ROOT_PATH="${i#*=}"
            ;;

        --env-path=*)
            ENV_ROOT_PATH="${i#*=}"
            ;;

        --dep-path=*)
            DEP_ROOT_PATH="${i#*=}"
            ;;

        --arg-file=*)
            ARG_FILE="${i#*=}"
            ;;

        --out-file=*)
            OUT_FILE="${i#*=}"
            ;;

        --build-jobs=*)
            BUILD_JOBS="${i#*=}"
            ;;

        --external-build-jobs=*)
            EXTERNAL_BUILD_JOBS="${i#*=}"
            ;;

        *)
            echo "unknown OPERATION/OPTION and/or without param: ${i}, see 'help'"
            exit 0
            ;;
    esac
done

if [ -z $OPERATION ]; then
    echo "OPERATION is not selected, see 'help'"
    exit 1
fi

#----------------------------------------
# Doing OPERATION
#----------------------------------------

# default values if not set by user
BUILD_TYPE=${BUILD_TYPE:-Release}

# now we can define common dirs
define_common_dirs

case "$OPERATION" in

    long-term-env)
        check_host_target_combination
        long_term_environment
        ;;

    short-term-env)
        check_host_target_combination
        short_term_environment
        ;;

    build-libs)
        check_host_target_combination
        build_libs
        ;;

    build-project)
        check_host_target_combination
        build_project
        ;;

    get-libs)
        check_host_target_combination
        get_libs
        ;;

    *)
        print_help
        ;;
esac
