
ARG VERSION=invalid-version
FROM robotpy/roborio-cross-ubuntu:${VERSION}-base AS pycompile

ENV TARGET_HOST="arm-frc2023-linux-gnueabi"
ENV AC_TARGET_HOST="armv7l-frc2023-linux-gnueabi"
ENV BUILD_HOST="x86_64"
ENV WORKING_DIRECTORY="/build"
ENV INSTALL_DIRECTORY="/build/crosspy"
ENV PYTHON_VERSION="3.11.1"
ENV PYTHON_FTP_VERSION="3.11.1"
ENV PYTHON_EXE="python3.11"
ENV SOURCE_DIRECTORY="Python-$PYTHON_VERSION"
ENV PYTHON_ARCHIVE="Python-$PYTHON_VERSION.tar.xz"
ENV PREFIX="$INSTALL_DIRECTORY"

#
# Python compilation prereqs
#

RUN set -xe; \
    apt-get update; \
    apt-get install -y build-essential checkinstall g++ libreadline-dev libncursesw5-dev libssl-dev \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev liblzma-dev lzma-dev libffi-dev zlib1g-dev; \
    # cleanup
    rm -rf /var/lib/apt/lists/*

#
# Python cross-compilation
#

COPY 0001-bpo-41916-allow-cross-compiled-python-to-have-pthrea.patch /
COPY 0001-Use-specified-host_cpu-when-cross-compiling-for-Linu.patch /

RUN set -xe; \
    mkdir -p "$PREFIX"; \
    # Download
    cd $WORKING_DIRECTORY; \
    wget -c https://www.python.org/ftp/python/$PYTHON_FTP_VERSION/$PYTHON_ARCHIVE; \
    rm -rf $SOURCE_DIRECTORY; \
    tar -xf $PYTHON_ARCHIVE; \
    cd $SOURCE_DIRECTORY; \
    # patch -pthread CXX issue
    patch -p1 < /0001-bpo-41916-allow-cross-compiled-python-to-have-pthrea.patch; \
    # patch arm cpu hardcoding
    patch -p1 < /0001-Use-specified-host_cpu-when-cross-compiling-for-Linu.patch; \
    # Build python for host
    cd $WORKING_DIRECTORY;cd $SOURCE_DIRECTORY; \
    ./configure --enable-optimizations --with-ensurepip=install; \
    make -j8; \
    make -j8 altinstall; \
    # cross-compile for frc
    cd $WORKING_DIRECTORY;cd $SOURCE_DIRECTORY; make distclean; \
    ./configure --host=$TARGET_HOST --build=$BUILD_HOST --prefix=$PREFIX \
        --with-build-python=$(which $PYTHON_EXE) \
        --disable-ipv6 \
        ac_cv_host=$AC_TARGET_HOST \
        ac_cv_buggy_getaddrinfo=no \
        ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
        ac_cv_have_long_long_format=yes \
        ac_cv_pthread_is_default=no ac_cv_pthread=yes ac_cv_cxx_thread=yes; \
    make -j8; \
    # make install here is fine because we include --prefix in the configure statement
    make install
    

#
# Minimal cross-compilation environment
#

FROM robotpy/roborio-cross-ubuntu:${VERSION}-base AS crossenv

RUN set -xe; \
    apt-get update; \
    apt-get install -y \
        binutils libreadline8 libncursesw5 libssl3 \
        libsqlite3-0 libgdbm6 libbz2-1.0 liblzma5 libffi7 zlib1g; \
    rm -rf /var/lib/apt/lists/*

COPY --from=pycompile /usr/local /usr/local
COPY --from=pycompile /build/crosspy /build/crosspy

RUN set -xe; \
    ldconfig; \
    python3.11 -m pip install https://tortall.net/~robotpy/wheels/2023/misc/crossenv-1.3.0%2Bg86d44f0-py3-none-any.whl; \
    python3.11 -m crossenv /build/crosspy/bin/python3.11 /build/venv --sysroot=$(arm-frc2023-linux-gnueabi-gcc -print-sysroot) --env UNIXCONFDIR=/build/venv/cross/etc; \
    /build/venv/bin/cross-pip install wheel;

COPY pip.conf /build/venv/cross/pip.conf
COPY os-release /build/venv/cross/etc/os-release

ENV RPYBUILD_PARALLEL=1

