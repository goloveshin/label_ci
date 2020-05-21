cmake_minimum_required(VERSION 3.13.4)


set(CONFIGURE_PARAMS_LIST
    # usage:
    # configure
    # [--const]
    # [--zprefix]

    # [--prefix=PREFIX]
    "--prefix=${INSTALL_DIR}"

    # [--eprefix=EXPREFIX]
    # [--static]
    # [--64]
    # [--libdir=LIBDIR]
    # [--sharedlibdir=LIBDIR]
    # [--includedir=INCLUDEDIR]
    # [--archs="-arch i386 -arch x86_64"]
)
