cmake_minimum_required(VERSION 3.13.4)


if (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)
    set(HOST_STRING "")
endif ()

set(CONFIGURE_PARAMS_LIST
    # `configure' configures SoundTouch 2.1.2 to adapt to many kinds of systems.
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
    #   --docdir=DIR            documentation root [DATAROOTDIR/doc/soundtouch]
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

    ${HOST_STRING}
    "--enable-shared=yes"
    "--disable-static"

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
    #   --enable-integer-samples
    #                           use integer samples instead of floats [default=no]
    "--enable-integer-samples"

    #   --enable-openmp         use parallel multicore calculation through OpenMP
    #                           [default=no]
    #   --enable-x86-optimizations
    #                           use MMX or SSE optimization [default=yes]
    # 
    # Some influential environment variables:
    #   CXX         C++ compiler command
    #   CXXFLAGS    C++ compiler flags
    #   LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
    #               nonstandard directory <lib dir>
    #   LIBS        libraries to pass to the linker, e.g. -l<library>
    #   CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
    #               you have headers in a nonstandard directory <include dir>
    #   CC          C compiler command
    #   CFLAGS      C compiler flags
    #   CPP         C preprocessor
    #   CXXCPP      C++ preprocessor
    # 
    # Use these variables to override the choices made by `configure' or to help
    # it to find libraries and programs with nonstandard names/locations.
)