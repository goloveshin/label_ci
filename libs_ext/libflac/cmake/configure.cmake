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
    # `configure' configures flac 1.3.2 to adapt to many kinds of systems.
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
    #   --runstatedir=DIR       modifiable per-process data [LOCALSTATEDIR/run]
    #   --libdir=DIR            object code libraries [EPREFIX/lib]
    #   --includedir=DIR        C header files [PREFIX/include]
    #   --oldincludedir=DIR     C header files for non-gcc [/usr/include]
    #   --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
    #   --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
    #   --infodir=DIR           info documentation [DATAROOTDIR/info]
    #   --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
    #   --mandir=DIR            man documentation [DATAROOTDIR/man]
    #   --docdir=DIR            documentation root [DATAROOTDIR/doc/flac]
    #   --htmldir=DIR           html documentation [DOCDIR]
    #   --dvidir=DIR            dvi documentation [DOCDIR]
    #   --pdfdir=DIR            pdf documentation [DOCDIR]
    #   --psdir=DIR             ps documentation [DOCDIR]
    # 
    # Program names:
    #   --program-prefix=PREFIX            prepend PREFIX to installed program names
    #   --program-suffix=SUFFIX            append SUFFIX to installed program names
    #   --program-transform-name=PROGRAM   run sed PROGRAM on installed program names
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
    #   --enable-silent-rules   less verbose build output (undo: "make V=1")
    #   --disable-silent-rules  verbose build output (undo: "make V=0")
    #   --enable-dependency-tracking
    #                           do not reject slow dependency extractors
    #   --disable-dependency-tracking
    #                           speeds up one-time build
    #   --enable-static[=PKGS]  build static libraries [default=no]
    "--enable-static=no"

    #   --enable-shared[=PKGS]  build shared libraries [default=yes]
    "--enable-shared=yes"

    #   --enable-fast-install[=PKGS]
    #                           optimize for fast installation [default=yes]
    #   --disable-libtool-lock  avoid locking (might break parallel builds)
    #   --disable-largefile     omit support for large files
    #   --disable-asm-optimizations
    #                           Don't use any assembly optimization routines
    #   --enable-debug          Turn on debugging
    ${DEBUG}

    #   --disable-sse           Disable passing of -msse2 to the compiler
    #   --disable-altivec       Disable Altivec optimizations
    #   --disable-avx           Disable AVX, AVX2 optimizations
    #   --disable-thorough-tests
    #                           Disable thorough (long) testing, do only basic tests
    #   --enable-exhaustive-tests
    #                           Enable exhaustive testing (VERY long)
    #   --enable-werror         Enable -Werror in all Makefiles
    #   --enable-stack-smash-protection
    #                           Enable GNU GCC stack smash protection
    #   --enable-64-bit-words   Set FLAC__BYTES_PER_WORD to 8 (4 is the default)
    #   --enable-valgrind-testing
    #                           Run all tests inside Valgrind
    #   --disable-doxygen-docs  Disable API documentation building via Doxygen
    #   --enable-local-xmms-plugin
    #                           Install XMMS plugin to ~/.xmms/Plugins instead of
    #                           system location
    #   --disable-xmms-plugin   Do not build XMMS plugin
    #   --disable-cpplibs       Do not build libFLAC++
    #   --disable-ogg           Disable ogg support (default: test for libogg)
    #   --disable-oggtest       Do not try to compile and run a test Ogg program
    #   --disable-rpath         do not hardcode runtime library paths
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
    #   --with-xmms-prefix=PFX  Prefix where XMMS is installed (optional)
    #   --with-xmms-exec-prefix=PFX Exec prefix where XMMS is installed (optional)
    #   --with-ogg=PFX          Prefix where libogg is installed (optional)
    #   --with-ogg-libraries=DIR
    #                           Directory where libogg library is installed
    #                           (optional)
    "--with-ogg-libraries=${LIB__OGG__LIBRARY_DIR}"

    #   --with-ogg-includes=DIR Directory where libogg header files are installed
    #                           (optional)
    "--with-ogg-includes=${LIB__OGG__INCLUDE_DIR}"

    #   --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
    #   --with-libiconv-prefix[=DIR]  search for libiconv in DIR/include and DIR/lib
    #   --without-libiconv-prefix     don't search for libiconv in includedir and libdir
    # 
    # Some influential environment variables:
    #   CC          C compiler command
    #   CFLAGS      C compiler flags
    #   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
    #               nonstandard directory <lib dir>
    #   LIBS        libraries to pass to the linker, e.g. -l<library>
    #   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
    #               you have headers in a nonstandard directory <include dir>
    #   CPP         C preprocessor
    #   LT_SYS_LIBRARY_PATH
    #               User-defined run-time library search path.
    #   CCAS        assembler compiler command (defaults to CC)
    #   CCASFLAGS   assembler compiler flags (defaults to CFLAGS)
    #   CXX         C++ compiler command
    #   CXXFLAGS    C++ compiler flags
    #   CXXCPP      C++ preprocessor
    # 
    # Use these variables to override the choices made by `configure' or to help
    # it to find libraries and programs with nonstandard names/locations.
    # 
    # Report bugs to <flac-dev@xiph.org>.
    # flac home page: <https://www.xiph.org/flac/>.
)
