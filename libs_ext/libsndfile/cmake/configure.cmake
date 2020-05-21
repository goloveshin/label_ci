cmake_minimum_required(VERSION 3.13.4)


if (TRUE)
    set(HOST_STRING "")
endif ()

set(CONFIGURE_PARAMS_LIST
    # `configure' configures libsndfile 1.0.28pre1 to adapt to many kinds of systems.
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
    #   --docdir=DIR            documentation root [DATAROOTDIR/doc/libsndfile]
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
    #   --target=TARGET   configure for building compilers for TARGET [HOST]
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
    #   --enable-shared[=PKGS]  build shared libraries [default=yes]
    "--enable-shared=yes"

    #   --enable-static[=PKGS]  build static libraries [default=yes]
    "--enable-static=no"

    #   --enable-fast-install[=PKGS]
    #                           optimize for fast installation [default=yes]
    #   --disable-libtool-lock  avoid locking (might break parallel builds)
    #   --enable-experimental   enable experimental code
    #   --enable-werror         enable -Werror in all Makefiles
    #   --enable-stack-smash-protection
    #                           Enable GNU GCC stack smash protection
    #   --disable-gcc-pipe      disable gcc -pipe option
    #   --disable-gcc-opt       disable gcc optimisations
    #   --disable-cpu-clip      disable tricky cpu specific clipper
    #   --enable-bow-docs       enable black-on-white html docs
    #   --disable-sqlite        disable use of sqlite
    "--disable-sqlite"

    #   --disable-alsa          disable use of ALSA
    #   --disable-external-libs disable use of FLAC, Ogg and Vorbis [[default=no]]
    #   --enable-octave         disable building of GNU Octave module
    #   --disable-full-suite    disable building and installing programs,
    #                           documentation, only build library [[default=no]]
    #   --enable-test-coverage  enable test coverage
    #   --disable-largefile     omit support for large files
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
    #   --with-octave           choose the octave version
    #   --with-mkoctfile        choose the mkoctfile version
    #   --with-octave-config    choose the octave-config version
    #   --with-pkgconfigdir     pkg-config installation directory
    #                           ['${libdir}/pkgconfig']
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
    #   CXX         C++ compiler command
    #   CXXFLAGS    C++ compiler flags
    #   LT_SYS_LIBRARY_PATH
    #               User-defined run-time library search path.
    #   CXXCPP      C++ preprocessor
    #   PKG_CONFIG  path to pkg-config utility
    #   PKG_CONFIG_PATH
    #               directories to add to pkg-config's search path
    "PKG_CONFIG_PATH=${LIB__FLAC__LIB_DIR}/pkgconfig:${LIB__OGG__LIB_DIR}/pkgconfig:${LIB__VORBIS__LIB_DIR}/pkgconfig"

    #   PKG_CONFIG_LIBDIR
    #               path overriding pkg-config's built-in search path
    #   FLAC_CFLAGS C compiler flags for FLAC, overriding pkg-config
    #   FLAC_LIBS   linker flags for FLAC, overriding pkg-config
    #   OGG_CFLAGS  C compiler flags for OGG, overriding pkg-config
    #   OGG_LIBS    linker flags for OGG, overriding pkg-config
    #   SPEEX_CFLAGS
    #               C compiler flags for SPEEX, overriding pkg-config
    #   SPEEX_LIBS  linker flags for SPEEX, overriding pkg-config
    #   VORBIS_CFLAGS
    #               C compiler flags for VORBIS, overriding pkg-config
    #   VORBIS_LIBS linker flags for VORBIS, overriding pkg-config
    #   VORBISENC_CFLAGS
    #               C compiler flags for VORBISENC, overriding pkg-config
    #   VORBISENC_LIBS
    #               linker flags for VORBISENC, overriding pkg-config
    #   SQLITE3_CFLAGS
    #               C compiler flags for SQLITE3, overriding pkg-config
    #   SQLITE3_LIBS
    #               linker flags for SQLITE3, overriding pkg-config
    # 
    # Use these variables to override the choices made by `configure' or to help
    # it to find libraries and programs with nonstandard names/locations.
    # 
    # Report bugs to <sndfile@mega-nerd.com>.
    # libsndfile home page: <http://www.mega-nerd.com/libsndfile/>.
)
