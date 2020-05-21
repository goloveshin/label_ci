cmake_minimum_required(VERSION 3.13.4)


if (SERVER_FOR_DEBIAN_8_64 OR SERVER_FOR_DEBIAN_9_64)
    set(HOST_STRING "")
endif ()

# TARGET выбирается из набора (смотри в конце файла)

if (CLIENT_FOR_WINDOWS_32)

    set(TARGET x86-win32-vs15)
    set(SHARED_VAL "--disable-shared") # TODO проверить
    set(STATIC_VAL "--enable-static")

elseif (CLIENT_FOR_WINDOWS_64)

    set(TARGET x86_64-win64-vs15)
    set(SHARED_VAL "--disable-shared") # TODO проверить
    set(STATIC_VAL "--enable-static")

elseif (CLIENT_FOR_MACOS)

    set(TARGET x86_64-darwin17-gcc)
    set(SHARED_VAL "--enable-shared")
    set(STATIC_VAL "--disable-static")

elseif (CLIENT_FOR_LINUX_32)

    set(TARGET x86-linux-gcc)
    set(SHARED_VAL "--enable-shared")
    set(STATIC_VAL "--disable-static")

elseif (CLIENT_FOR_LINUX_64)

    set(TARGET x86_64-linux-gcc)
    set(SHARED_VAL "--enable-shared")
    set(STATIC_VAL "--disable-static")

endif ()

set(CONFIGURE_PARAMS_LIST
    "--prefix=${INSTALL_DIR}"

    # Usage: configure [options]
    # Options:
    # 
    #     Build options:
    #   --help                      print this message
    #   --log=yes|no|FILE           file configure log is written to [config.log]

    #   --target=TARGET             target platform tuple [generic-gnu]
    "--target=${TARGET}"

    #   --cpu=CPU                   optimize for a specific cpu rather than a family
    #   --extra-cflags=ECFLAGS      add ECFLAGS to CFLAGS []
    #   --extra-cxxflags=ECXXFLAGS  add ECXXFLAGS to CXXFLAGS []
    #   --enable-extra-warnings     emit harmless warnings (always non-fatal)
    #   --enable-werror             treat warnings as errors, if possible
    #                               (not available with all compilers)
    #   --disable-optimizations     turn on/off compiler optimization flags

    #   --enable-pic                turn on/off Position Independent Code
    "--enable-pic"

    #   --enable-ccache             turn on/off compiler cache
    #   --enable-debug              enable/disable debug mode
    #   --enable-gprof              enable/disable gprof profiling instrumentation
    #   --enable-gcov               enable/disable gcov coverage instrumentation
    #   --enable-thumb              enable/disable building arm assembly in thumb mode
    #   --disable-dependency-tracking
    #                               disable to speed up one-time build
    # 
    #     Install options:
    #   --enable-install-docs       control whether docs are installed
    #   --disable-install-bins      control whether binaries are installed
    #   --disable-install-libs      control whether libraries are installed
    #   --enable-install-srcs       control whether sources are installed
    # 
    # 
    #     Advanced options:
    #   --disable-libs                  libraries

    #   --disable-examples              examples
    "--disable-examples"

    #   --disable-tools                 tools
    "--disable-tools"

    #   --disable-docs                  documentation
    "--disable-docs"

    #   --enable-unit-tests             unit tests
    "--disable-unit-tests"

    #   --enable-decode-perf-tests      build decoder perf tests with unit tests
    #   --enable-encode-perf-tests      build encoder perf tests with unit tests
    #   --cpu=CPU                       tune for the specified CPU (ARM: cortex-a8, X86: sse3)
    #   --libc=PATH                     path to alternate libc
    #   --size-limit=WxH                max size to allow in the decoder
    #   --as={yasm|nasm|auto}           use specified assembler [auto, yasm preferred]
    #   --sdk-path=PATH                 path to root of sdk (android builds only)
    #   --enable-codec-srcs             in/exclude codec library source code
    #   --enable-debug-libs             in/exclude debug version of libraries

    #   --enable-static-msvcrt          use static MSVCRT (VS builds only)
    "--disable-static-msvcrt"

    #   --enable-vp9-highbitdepth       use VP9 high bit depth (10/12) profiles
    #   --enable-better-hw-compatibility 
    #                                   enable encoder to produce streams with better
    #                                   hardware decoder compatibility

    #   --enable-vp8                    VP8 codec support
    "--enable-vp8"

    #   --enable-vp9                    VP9 codec support
    "--enable-vp9"
    
    #   --enable-internal-stats         output of encoder internal stats for debug, if supported (encoders)
    #   --enable-postproc               postprocessing
    #   --enable-vp9-postproc           vp9 specific postprocessing
    #   --disable-multithread           multithreaded encoding and decoding
    #   --disable-spatial-resampling    spatial sampling (scaling) support
    #   --enable-realtime-only          enable this option while building for real-time encoding

    #   --enable-onthefly-bitpacking    enable on-the-fly bitpacking in real-time encoding
    "--enable-onthefly-bitpacking"

    #   --enable-error-concealment      enable this option to get a decoder which is able to conceal losses
    "--enable-error-concealment"

    #   --enable-coefficient-range-checking 
    #                                   enable decoder to check if intermediate
    #                                   transform coefficients are in valid range

    #   --enable-runtime-cpu-detect     runtime cpu detection
    "--enable-runtime-cpu-detect"

    #   --enable-shared                 shared library support
    ${SHARED_VAL}

    #   --disable-static                static library support
    ${STATIC_VAL}

    #   --enable-small                  favor smaller size over speed
    #   --enable-postproc-visualizer    macro block / block level visualizers
    #   --enable-multi-res-encoding     enable multiple-resolution encoding
    #   --disable-temporal-denoising    enable temporal denoising and disable the spatial denoiser
    #   --enable-vp9-temporal-denoising 
    #                                   enable vp9 temporal denoising
    #   --enable-webm-io                enable input from and output to WebM container
    #   --enable-libyuv                 enable libyuv
    # 
    #     Codecs:
    #   Codecs can be selectively enabled or disabled individually, or by family:
    #       --disable-<codec>
    #   is equivalent to:
    #       --disable-<codec>-encoder
    #       --disable-<codec>-decoder
    # 
    #   Codecs available in this distribution:
    #            vp8:    encoder    decoder
    #            vp9:    encoder    decoder
    # 
    # 
    #     NOTES:
    #     Object files are built at the place where configure is launched.
    # 
    #     All boolean options can be negated. The default value is the opposite
    #     of that shown above. If the option --disable-foo is listed, then
    #     the default value for foo is enabled.
    # 
    #     Supported targets:
    #     arm64-android-gcc        arm64-darwin-gcc         arm64-linux-gcc         
    #     arm64-win64-gcc          arm64-win64-vs15        
    #     armv7-android-gcc        armv7-darwin-gcc         armv7-linux-rvct        
    #     armv7-linux-gcc          armv7-none-rvct          armv7-win32-gcc         
    #     armv7-win32-vs14         armv7-win32-vs15        
    #     armv7s-darwin-gcc       
    #     armv8-linux-gcc         
    #     mips32-linux-gcc        
    #     mips64-linux-gcc        
    #     ppc64le-linux-gcc       
    #     sparc-solaris-gcc       
    #     x86-android-gcc          x86-darwin8-gcc          x86-darwin8-icc         
    #     x86-darwin9-gcc          x86-darwin9-icc          x86-darwin10-gcc        
    #     x86-darwin11-gcc         x86-darwin12-gcc         x86-darwin13-gcc        
    #     x86-darwin14-gcc         x86-darwin15-gcc         x86-darwin16-gcc        
    #     x86-darwin17-gcc         x86-iphonesimulator-gcc  x86-linux-gcc           
    #     x86-linux-icc            x86-os2-gcc              x86-solaris-gcc         
    #     x86-win32-gcc            x86-win32-vs14           x86-win32-vs15          
    #     x86_64-android-gcc       x86_64-darwin9-gcc       x86_64-darwin10-gcc     
    #     x86_64-darwin11-gcc      x86_64-darwin12-gcc      x86_64-darwin13-gcc     
    #     x86_64-darwin14-gcc      x86_64-darwin15-gcc      x86_64-darwin16-gcc     
    #     x86_64-darwin17-gcc      x86_64-iphonesimulator-gcc x86_64-linux-gcc        
    #     x86_64-linux-icc         x86_64-solaris-gcc       x86_64-win64-gcc        
    #     x86_64-win64-vs14        x86_64-win64-vs15       
    #     generic-gnu             
)
