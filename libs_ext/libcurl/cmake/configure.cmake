cmake_minimum_required(VERSION 3.13.4)


if (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)
    set(HOST_STRING "")
endif ()

get_target_property(LIB__OPENSSL__ROOT_DIR libopenssl_1_0_x_interface external_root_path)
get_target_property(LIB__OPENLDAP__LIBRARY_DIR libopenldap_interface external_lib_path)

if (SERVER_FOR_WINDOWS_32 OR SERVER_FOR_WINDOWS_64)

    if (SERVER_FOR_WINDOWS_32)
        set(PLATFORM x86)
    else ()
        set(PLATFORM x64)
    endif ()

    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(GEN_PDB "no")
        set(DEBUG "no")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(GEN_PDB "yes")
        set(DEBUG "yes")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(GEN_PDB "yes")
        set(DEBUG "no")
    endif ()

    set(CONFIGURE_PARAMS_LIST
        # Building with Visual C++, prerequisites
        # =======================================
        # 
        #    This document describes how to compile, build and install curl and libcurl
        #    from sources using the Visual C++ build tool. To build with VC++, you will
        #    of course have to first install VC++. The minimum required version of
        #    VC is 6 (part of Visual Studio 6). However using a more recent version is
        #    strongly recommended.
        # 
        #    VC++ is also part of the Windows Platform SDK. You do not have to install
        #    the full Visual Studio or Visual C++ if all you want is to build curl.
        # 
        #    The latest Platform SDK can be downloaded freely from:
        # 
        #     https://developer.microsoft.com/en-us/windows/downloads/sdk-archive
        # 
        #    If you are building with VC6 then you will also need the February 2003
        #    Edition of the Platform SDK which can be downloaded from:
        # 
        #     https://www.microsoft.com/en-us/download/details.aspx?id=12261
        # 
        #    If you wish to support zlib, openssl, c-ares, ssh2, you will have to download
        #    them separately and copy them to the deps directory as shown below:
        # 
        #    somedirectory\
        #     |_curl-src
        #     | |_winbuild
        #     |
        #     |_deps
        #       |_ lib
        #       |_ include
        #       |_ bin
        # 
        #    It is also possible to create the deps directory in some other random
        #    places and tell the Makefile its location using the WITH_DEVEL option.
        # 
        # Building straight from git
        # ==========================
        # 
        #  When you check out code git and build it, as opposed from a released source
        #  code archive, you need to first run the "buildconf.bat" batch file (present
        #  in the source code root directory) to set things up.
        # 
        # Building with Visual C++
        # ========================
        # 
        # Open a Visual Studio Command prompt:
        # 
        #      Using the 'Developer Command Prompt for VS <version>' menu entry:
        #        where version is the Visual Studio version. The developer prompt at default
        #        uses the x86 mode. It is required to call Vcvarsall.bat to setup the prompt
        #        for the machine type you want, using Vcvarsall.bat.
        #        This type of command prompt may not exist in all Visual Studio versions.
        # 
        #        For more information, check:
        #          https://docs.microsoft.com/en-us/dotnet/framework/tools/developer-command-prompt-for-vs
        #          https://docs.microsoft.com/en-us/cpp/build/how-to-enable-a-64-bit-visual-cpp-toolset-on-the-command-line
        # 
        #      Using the 'VS <version> <platform> <type> Command Prompt' menu entry:
        #        where version is the Visual Studio version, platform is e.g. x64
        #        and type Native of Cross platform build.  This type of command prompt
        #        may not exist in all Visual Studio versions.
        # 
        #        See also:
        #          https://msdn.microsoft.com/en-us/library/f2ccy3wt.aspx
        # 
        # Once you are in the console, go to the winbuild directory in the Curl
        # sources:
        #     cd curl-src\winbuild
        # 
        # Then you can call nmake /f Makefile.vc with the desired options (see below).
        # The builds will be in the top src directory, builds\ directory, in
        # a directory named using the options given to the nmake call.
        # 
        # nmake /f Makefile.vc mode=<static or dll> <options>
        # 
        # where <options> is one or many of:
        #   VC=<6,7,8,9,10,11,12,14,15>    - VC versions
        "VC=15"

        #   WITH_DEVEL=<path>              - Paths for the development files (SSL, zlib, etc.)
        #                                    Defaults to sibbling directory deps: ../deps
        #                                    Libraries can be fetched at https://windows.php.net/downloads/php-sdk/deps/
        #                                    Uncompress them into the deps folder.
        #   WITH_SSL=<dll or static>       - Enable OpenSSL support, DLL or static
        "WITH_SSL=static"

        #   WITH_NGHTTP2=<dll or static>   - Enable HTTP/2 support, DLL or static
        #   WITH_MBEDTLS=<dll or static>   - Enable mbedTLS support, DLL or static
        #   WITH_CARES=<dll or static>     - Enable c-ares support, DLL or static
        #   WITH_ZLIB=<dll or static>      - Enable zlib support, DLL or static
        #   WITH_SSH2=<dll or static>      - Enable libSSH2 support, DLL or static
        #   ENABLE_SSPI=<yes or no>        - Enable SSPI support, defaults to yes
        #   ENABLE_IPV6=<yes or no>        - Enable IPv6, defaults to yes
        #   ENABLE_IDN=<yes or no>         - Enable use of Windows IDN APIs, defaults to yes
        #                                    Requires Windows Vista or later
        #   ENABLE_WINSSL=<yes or no>      - Enable native Windows SSL support, defaults to yes
        #   GEN_PDB=<yes or no>            - Generate Program Database (debug symbols for release build)
        "GEN_PDB=${GEN_PDB}"

        #   DEBUG=<yes or no>              - Debug builds
        "DEBUG=${DEBUG}"

        #   MACHINE=<x86 or x64>           - Target architecture (default is x86)
        "MACHINE=${PLATFORM}"

        #   CARES_PATH=<path to cares>     - Custom path for c-ares
        #   MBEDTLS_PATH=<path to mbedTLS> - Custom path for mbedTLS
        #   NGHTTP2_PATH=<path to HTTP/2>  - Custom path for nghttp2
        #   SSH2_PATH=<path to libSSH2>    - Custom path for libSSH2
        #   SSL_PATH=<path to OpenSSL>     - Custom path for OpenSSL
        "SSL_PATH=${LIB__OPENSSL__ROOT_DIR}"

        #   ZLIB_PATH=<path to zlib>       - Custom path for zlib

        # 
        # 
        # Static linking of Microsoft's C RunTime (CRT):
        # ==============================================
        # If you are using mode=static nmake will create and link to the static build of
        # libcurl but *not* the static CRT. If you must you can force nmake to link in
        # the static CRT by passing RTLIBCFG=static. Typically you shouldn't use that
        # option, and nmake will default to the DLL CRT. RTLIBCFG is rarely used and
        # therefore rarely tested. When passing RTLIBCFG for a configuration that was
        # already built but not with that option, or if the option was specified
        # differently, you must destroy the build directory containing the configuration
        # so that nmake can build it from scratch.
        # 
        # Legacy Windows and SSL
        # ======================
        # When you build curl using the build files in this directory the default SSL
        # backend will be WinSSL (Windows SSPI, more specifically Schannel), the native
        # SSL library that comes with the Windows OS. WinSSL in Windows <= XP is not able
        # to connect to servers that no longer support the legacy handshakes and
        # algorithms used by those versions. If you will be using curl in one of those
        # earlier versions of Windows you should choose another SSL backend like OpenSSL.
    )

elseif (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)

    if (CMAKE_BUILD_TYPE MATCHES Release)
        set(DEBUG   "--disable-debug" "--enable-optimize")
    elseif (CMAKE_BUILD_TYPE MATCHES Debug)
        set(DEBUG    "--enable-debug" "--disable-optimize")
    elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        set(DEBUG    "--enable-debug" "--enable-optimize")
    endif ()

    get_target_property(LIB__ZLIB__ROOT_DIR libzlib_interface external_root_path)

    set(CONFIGURE_PARAMS_LIST
        # `configure' configures curl - to adapt to many kinds of systems.
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
        #   --docdir=DIR            documentation root [DATAROOTDIR/doc/curl]
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

        # Optional Features:
        #   --disable-option-checking  ignore unrecognized --enable/--with options
        #   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
        #   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
        #   --enable-maintainer-mode
        #                           enable make rules and dependencies not useful (and
        #                           sometimes confusing) to the casual installer
        #   --enable-silent-rules   less verbose build output (undo: "make V=1")
        #   --disable-silent-rules  verbose build output (undo: "make V=0")

        #   --enable-debug          Enable debug build options
        #   --disable-debug         Disable debug build options
        #   --enable-optimize       Enable compiler optimizations
        #   --disable-optimize      Disable compiler optimizations
        ${DEBUG}

        #   --enable-warnings       Enable strict compiler warnings
        #   --disable-warnings      Disable strict compiler warnings
        #   --enable-werror         Enable compiler warnings as errors
        #   --disable-werror        Disable compiler warnings as errors
        #   --enable-curldebug      Enable curl debug memory tracking
        #   --disable-curldebug     Disable curl debug memory tracking
        #   --enable-symbol-hiding  Enable hiding of library internal symbols
        #   --disable-symbol-hiding Disable hiding of library internal symbols
        #   --enable-hidden-symbols To be deprecated, use --enable-symbol-hiding
        #   --disable-hidden-symbols
        #                           To be deprecated, use --disable-symbol-hiding
        #   --enable-ares[=PATH]    Enable c-ares for DNS lookups
        #   --disable-ares          Disable c-ares for DNS lookups
        #   --disable-rt            disable dependency on -lrt
        #   --enable-code-coverage  Provide code coverage
        #   --enable-dependency-tracking
        #                           do not reject slow dependency extractors
        #   --disable-dependency-tracking
        #                           speeds up one-time build
        #   --disable-largefile     omit support for large files
        #   --enable-shared[=PKGS]  build shared libraries [default=yes]
        "--enable-shared=yes"

        #   --enable-static[=PKGS]  build static libraries [default=yes]
        "--enable-static=yes"

        #   --enable-fast-install[=PKGS]
        #                           optimize for fast installation [default=yes]
        #   --disable-libtool-lock  avoid locking (might break parallel builds)
        #   --enable-http           Enable HTTP support
        #   --disable-http          Disable HTTP support
        #   --enable-ftp            Enable FTP support
        #   --disable-ftp           Disable FTP support
        #   --enable-file           Enable FILE support
        #   --disable-file          Disable FILE support
        #   --enable-ldap           Enable LDAP support
        "--enable-ldap"

        #   --disable-ldap          Disable LDAP support
        #   --enable-ldaps          Enable LDAPS support
        #   --disable-ldaps         Disable LDAPS support
        #   --enable-rtsp           Enable RTSP support
        #   --disable-rtsp          Disable RTSP support
        #   --enable-proxy          Enable proxy support
        #   --disable-proxy         Disable proxy support
        #   --enable-dict           Enable DICT support
        #   --disable-dict          Disable DICT support
        #   --enable-telnet         Enable TELNET support
        #   --disable-telnet        Disable TELNET support
        #   --enable-tftp           Enable TFTP support
        #   --disable-tftp          Disable TFTP support
        #   --enable-pop3           Enable POP3 support
        #   --disable-pop3          Disable POP3 support
        #   --enable-imap           Enable IMAP support
        #   --disable-imap          Disable IMAP support
        #   --enable-smb            Enable SMB/CIFS support
        #   --disable-smb           Disable SMB/CIFS support
        #   --enable-smtp           Enable SMTP support
        #   --disable-smtp          Disable SMTP support
        #   --enable-gopher         Enable Gopher support
        #   --disable-gopher        Disable Gopher support
        #   --enable-manual         Enable built-in manual
        #   --disable-manual        Disable built-in manual
        #   --enable-libcurl-option Enable --libcurl C code generation support
        #   --disable-libcurl-option
        #                           Disable --libcurl C code generation support
        #   --enable-libgcc         use libgcc when linking
        #   --enable-ipv6           Enable IPv6 (with IPv4) support
        #   --disable-ipv6          Disable IPv6 support
        #   --enable-openssl-auto-load-config
        #                           Enable automatic loading of OpenSSL configuration
        #   --disable-openssl-auto-load-config
        #                           Disable automatic loading of OpenSSL configuration
        #   --enable-versioned-symbols
        #                           Enable versioned symbols in shared library
        #   --disable-versioned-symbols
        #                           Disable versioned symbols in shared library
        #   --enable-threaded-resolver
        #                           Enable threaded resolver
        #   --disable-threaded-resolver
        #                           Disable threaded resolver
        #   --enable-pthreads       Enable POSIX threads (default for threaded resolver)
        #   --disable-pthreads      Disable POSIX threads
        #   --enable-verbose        Enable verbose strings
        #   --disable-verbose       Disable verbose strings
        #   --enable-sspi           Enable SSPI
        #   --disable-sspi          Disable SSPI
        #   --enable-crypto-auth    Enable cryptographic authentication
        #   --disable-crypto-auth   Disable cryptographic authentication
        #   --enable-ntlm-wb[=FILE] Enable NTLM delegation to winbind's ntlm_auth
        #                           helper, where FILE is ntlm_auth's absolute filename
        #                           (default: /usr/bin/ntlm_auth)
        #   --disable-ntlm-wb       Disable NTLM delegation to winbind's ntlm_auth
        #                           helper
        #   --enable-tls-srp        Enable TLS-SRP authentication
        #   --disable-tls-srp       Disable TLS-SRP authentication
        #   --enable-unix-sockets   Enable Unix domain sockets
        #   --disable-unix-sockets  Disable Unix domain sockets
        #   --enable-cookies        Enable cookies support
        #   --disable-cookies       Disable cookies support
        #   --enable-alt-svc        Enable alt-svc support
        #   --disable-alt-svc       Disable alt-svc support
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

        #   --with-zlib=PATH        search for zlib in PATH
        "--with-zlib=${LIB__ZLIB__ROOT_DIR}"

        #   --without-zlib          disable use of zlib
        #   --with-brotli=PATH      Where to look for brotli, PATH points to the BROTLI
        #                           installation; when possible, set the PKG_CONFIG_PATH
        #                           environment variable instead of using this option
        #   --without-brotli        disable BROTLI
        #   --with-ldap-lib=libname Specify name of ldap lib file
        "--with-ldap-lib=${LIB__OPENLDAP__LIBRARY_DIR}/libldap.so"

        #   --with-lber-lib=libname Specify name of lber lib file
        "--with-lber-lib=${LIB__OPENLDAP__LIBRARY_DIR}/liblber.so"

        #   --with-gssapi-includes=DIR
        #                           Specify location of GSS-API headers
        #   --with-gssapi-libs=DIR  Specify location of GSS-API libs
        #   --with-gssapi=DIR       Where to look for GSS-API
        #   --with-default-ssl-backend=NAME
        #                           Use NAME as default SSL backend
        #   --without-default-ssl-backend
        #                           Use implicit default SSL backend
        #   --with-winssl           enable Windows native SSL/TLS
        #   --without-winssl        disable Windows native SSL/TLS
        #   --with-schannel         enable Windows native SSL/TLS
        #   --without-schannel      disable Windows native SSL/TLS
        #   --with-darwinssl        enable Apple OS native SSL/TLS
        #   --without-darwinssl     disable Apple OS native SSL/TLS
        #   --with-secure-transport enable Apple OS native SSL/TLS
        #   --without-secure-transport
        #                           disable Apple OS native SSL/TLS
        #   --with-amissl           enable Amiga native SSL/TLS (AmiSSL)
        #   --without-amissl        disable Amiga native SSL/TLS (AmiSSL)
        #   --with-ssl=PATH         Where to look for OpenSSL, PATH points to the SSL
        #                           installation (default: /usr/local/ssl); when
        #                           possible, set the PKG_CONFIG_PATH environment
        #                           variable instead of using this option
        "--with-ssl=${LIB__OPENSSL__ROOT_DIR}"

        #   --without-ssl           disable OpenSSL
        #   --with-egd-socket=FILE  Entropy Gathering Daemon socket pathname
        #   --with-random=FILE      read randomness from FILE (default=/dev/urandom)
        #   --with-gnutls=PATH      where to look for GnuTLS, PATH points to the
        #                           installation root
        #   --without-gnutls        disable GnuTLS detection
        #   --with-polarssl=PATH    where to look for PolarSSL, PATH points to the
        #                           installation root
        #   --without-polarssl      disable PolarSSL detection
        #   --with-mbedtls=PATH     where to look for mbedTLS, PATH points to the
        #                           installation root
        #   --without-mbedtls       disable mbedTLS detection
        #   --with-cyassl=PATH      where to look for CyaSSL, PATH points to the
        #                           installation root (default: system lib default)
        #   --without-cyassl        disable CyaSSL detection
        #   --with-wolfssl=PATH     where to look for WolfSSL, PATH points to the
        #                           installation root (default: system lib default)
        #   --without-wolfssl       disable WolfSSL detection
        #   --with-mesalink=PATH    where to look for MesaLink, PATH points to the
        #                           installation root
        #   --without-mesalink      disable MesaLink detection
        #   --with-nss=PATH         where to look for NSS, PATH points to the
        #                           installation root
        #   --without-nss           disable NSS detection
        #   --with-ca-bundle=FILE   Path to a file containing CA certificates (example:
        #                           /etc/ca-bundle.crt)
        #   --without-ca-bundle     Don't use a default CA bundle
        #   --with-ca-path=DIRECTORY
        #                           Path to a directory containing CA certificates
        #                           stored individually, with their filenames in a hash
        #                           format. This option can be used with OpenSSL, GnuTLS
        #                           and PolarSSL backends. Refer to OpenSSL c_rehash for
        #                           details. (example: /etc/certificates)
        #   --without-ca-path       Don't use a default CA path
        #   --with-ca-fallback      Use the built in CA store of the SSL library
        #   --without-ca-fallback   Don't use the built in CA store of the SSL library
        #   --without-libpsl        disable support for libpsl cookie checking
        #   --with-libmetalink=PATH where to look for libmetalink, PATH points to the
        #                           installation root
        #   --without-libmetalink   disable libmetalink detection
        #   --with-libssh2=PATH     Where to look for libssh2, PATH points to the
        #                           LIBSSH2 installation; when possible, set the
        #                           PKG_CONFIG_PATH environment variable instead of
        #                           using this option
        #   --with-libssh2          enable LIBSSH2
        #   --with-libssh=PATH      Where to look for libssh, PATH points to the LIBSSH
        #                           installation; when possible, set the PKG_CONFIG_PATH
        #                           environment variable instead of using this option
        #   --with-libssh           enable LIBSSH
        #   --with-librtmp=PATH     Where to look for librtmp, PATH points to the
        #                           LIBRTMP installation; when possible, set the
        #                           PKG_CONFIG_PATH environment variable instead of
        #                           using this option
        #   --without-librtmp       disable LIBRTMP
        #   --with-winidn=PATH      enable Windows native IDN
        #   --without-winidn        disable Windows native IDN
        #   --with-libidn2=PATH     Enable libidn2 usage
        #   --without-libidn2       Disable libidn2 usage
        #   --with-nghttp2=PATH     Enable nghttp2 usage
        #   --without-nghttp2       Disable nghttp2 usage
        #   --with-zsh-functions-dir=PATH
        #                           Install zsh completions to PATH
        #   --without-zsh-functions-dir
        #                           Do not install zsh completions
        #   --with-fish-functions-dir=PATH
        #                           Install fish completions to PATH
        #   --without-fish-functions-dir
        #                           Do not install fish completions
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
        # 
        # Use these variables to override the choices made by `configure' or to help
        # it to find libraries and programs with nonstandard names/locations.
        # 
        # Report bugs to <a suitable curl mailing list: https://curl.haxx.se/mail/>.
        #    
    )

else ()

    message(FATAL_ERROR "Not implemented yet")

endif ()
