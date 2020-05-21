cmake_minimum_required(VERSION 3.13.4)


if (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)
    set(HOST_STRING "")
endif ()

if (CMAKE_BUILD_TYPE MATCHES Release)
    set(DEBUG "")
elseif (CMAKE_BUILD_TYPE MATCHES Debug)
    set(DEBUG "--enable-debug")
elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    set(DEBUG "")
    message(FATAL_ERROR "Not implemented yet")
endif ()

set(CONFIGURE_PARAMS_LIST
    # `configure' configures sqlcipher 3.28.0 to adapt to many kinds of systems.
    # 
    # Usage: ./configure [OPTION]... [VAR=VALUE]...
    # 
    # To assign environment variables (e.g., CC, CFLAGS...), specify them as
    # VAR=VALUE.  See below for descriptions of some of the useful variables.
    # 
    # Defaults for the options are specified in brackets.
    # 
    # Configuration:
    #   -h, --help              display this help and exit
    #       --help=short        display options specific to this package
    #       --help=recursive    display the short help of all the included packages
    #   -V, --version           display version information and exit
    #   -q, --quiet, --silent   do not print `checking ...' messages
    #       --cache-file=FILE   cache test results in FILE [disabled]
    #   -C, --config-cache      alias for `--cache-file=config.cache'
    #   -n, --no-create         do not create output files
    #       --srcdir=DIR        find the sources in DIR [configure dir or `..']
    # 
    # Installation directories:
    #   --prefix=PREFIX         install architecture-independent files in PREFIX
    #                           [/usr/local]
    "--prefix=${INSTALL_DIR}"

    #   --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
    #                           [PREFIX]
    # 
    # By default, `make install' will install all the files in
    # `/usr/local/bin', `/usr/local/lib' etc.  You can specify
    # an installation prefix other than `/usr/local' using `--prefix',
    # for instance `--prefix=$HOME'.
    # 
    # For better control, use the options below.
    # 
    # Fine tuning of the installation directories:
    #   --bindir=DIR            user executables [EPREFIX/bin]
    #   --sbindir=DIR           system admin executables [EPREFIX/sbin]
    #   --libexecdir=DIR        program executables [EPREFIX/libexec]
    #   --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
    #   --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
    #   --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
    #   --libdir=DIR            object code libraries [EPREFIX/lib]
    #   --includedir=DIR        C header files [PREFIX/include]
    #   --oldincludedir=DIR     C header files for non-gcc [/usr/include]
    #   --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
    #   --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
    #   --infodir=DIR           info documentation [DATAROOTDIR/info]
    #   --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
    #   --mandir=DIR            man documentation [DATAROOTDIR/man]
    #   --docdir=DIR            documentation root [DATAROOTDIR/doc/sqlcipher]
    #   --htmldir=DIR           html documentation [DOCDIR]
    #   --dvidir=DIR            dvi documentation [DOCDIR]
    #   --pdfdir=DIR            pdf documentation [DOCDIR]
    #   --psdir=DIR             ps documentation [DOCDIR]
    # 
    # System types:
    #   --build=BUILD     configure for building on BUILD [guessed]
    #   --host=HOST       cross-compile to build programs to run on HOST [BUILD]
    ${HOST_STRING}

    # 
    # Optional Features:
    #   --disable-option-checking  ignore unrecognized --enable/--with options
    #   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
    #   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
    #   --enable-shared[=PKGS]  build shared libraries [default=yes]
    "--enable-shared=yes"

    #   --enable-static[=PKGS]  build static libraries [default=yes]
    "--enable-static=no"

    #   --enable-fast-install[=PKGS]
    #                           optimize for fast installation [default=yes]
    #   --disable-libtool-lock  avoid locking (might break parallel builds)
    #   --disable-largefile     omit support for large files
    #   --disable-threadsafe    Disable mutexing
    #   --enable-cross-thread-connections
    #                           Allow connection sharing across threads
    #   --enable-releasemode    Support libtool link to release mode
    #   --enable-tempstore      Use an in-ram database for temporary tables
    #                           (never,no,yes,always)
    "--enable-tempstore=yes"

    #   --disable-tcl           do not build TCL extension
    "--disable-tcl"

    #   --enable-editline       enable BSD editline support
    #   --disable-readline      disable readline support
    #   --enable-debug          enable debugging & verbose explain
    ${DEBUG}

    #   --disable-amalgamation  Disable the amalgamation and instead build all files
    #                           separately
    #   --disable-load-extension
    #                           Disable loading of external extensions
    #   --enable-memsys5        Enable MEMSYS5
    #   --enable-memsys3        Enable MEMSYS3
    #   --enable-fts3           Enable the FTS3 extension
    #   --enable-fts4           Enable the FTS4 extension
    #   --enable-fts5           Enable the FTS5 extension
    #   --enable-json1          Enable the JSON1 extension
    #   --enable-update-limit   Enable the UPDATE/DELETE LIMIT clause
    #   --enable-geopoly        Enable the GEOPOLY extension
    #   --enable-rtree          Enable the RTREE extension
    #   --enable-session        Enable the SESSION extension
    #   --enable-gcov           Enable coverage testing using gcov
    # 
    # Optional Packages:
    #   --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
    #   --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
    #   --with-pic[=PKGS]       try to use only PIC/non-PIC objects [default=use
    #                           both]
    #   --with-aix-soname=aix|svr4|both
    #                           shared library versioning (aka "SONAME") variant to
    #                           provide on AIX, [default=aix].
    #   --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
    #   --with-sysroot[=DIR]    Search for dependent libraries within DIR (or the
    #                           compiler's sysroot if not specified).
    #   --with-crypto-lib       Specify which crypto library to use
    #   --with-tcl=DIR          directory containing tcl configuration
    #                           (tclConfig.sh)
    #   --with-readline-lib     specify readline library
    #   --with-readline-inc     specify readline include paths
    # 
    # Some influential environment variables:
    #   CC          C compiler command
    #   CFLAGS      C compiler flags
    #   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
    #               nonstandard directory <lib dir>
    "LDFLAGS=-L${LIB__OPENSSL__LIBRARY_DIR}"

    #   LIBS        libraries to pass to the linker, e.g. -l<library>
    #   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
    #               you have headers in a nonstandard directory <include dir>
    "CPPFLAGS=-DSQLITE_HAS_CODEC -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1 -I${LIB__OPENSSL__INCLUDE_DIR}"

    #   LT_SYS_LIBRARY_PATH
    #               User-defined run-time library search path.
    #   CPP         C preprocessor
    #   TCLLIBDIR   Where to install tcl plugin
    # 
    # Use these variables to override the choices made by `configure' or to help
    # it to find libraries and programs with nonstandard names/locations.
    # 
    # Report bugs to the package provider.
)
