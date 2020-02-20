
FROM robotpy/roborio-cross-ubuntu:2020-18.04-base AS pycompile

ENV TARGET_HOST="arm-frc2020-linux-gnueabi"
ENV BUILD_HOST="x86_64"
ENV WORKING_DIRECTORY="/build"
ENV INSTALL_DIRECTORY="/build/crosspy"
ENV PYTHON_VERSION="3.8.1"
ENV SOURCE_DIRECTORY="Python-$PYTHON_VERSION"
ENV PYTHON_ARCHIVE="Python-$PYTHON_VERSION.tar.xz"
ENV PREFIX="$INSTALL_DIRECTORY"

#
# Python cross-compilation
#

RUN set -xe; \
    mkdir -p "$PREFIX"; \
    # python prereqs
    apt-get update; \
    apt-get install -y build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev; \
    # Download
    cd $WORKING_DIRECTORY; \
    wget -c http://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_ARCHIVE; \
    rm -rf $SOURCE_DIRECTORY; \
    tar -xf $PYTHON_ARCHIVE; \
    cd $SOURCE_DIRECTORY; \
    # Build python for host
    cd $WORKING_DIRECTORY;cd $SOURCE_DIRECTORY; \
    ./configure --enable-optimizations --with-ensurepip=install; \
    make -j8 altinstall; \
    # cross-compile for frc2020
    cd $WORKING_DIRECTORY;cd $SOURCE_DIRECTORY; make distclean; \
    ./configure --host=$TARGET_HOST --build=$BUILD_HOST --prefix=$PREFIX \
        --disable-ipv6 --enable-unicode=ucs4 \
        ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
        ac_cv_have_long_long_format=yes; \
    make -j8; \
    # make install here is fine because we include --prefix in the configure statement
    make install; \
    # cleanup
    rm -rf /var/lib/apt/lists/*

#
# Minimal cross-compilation environment
#

FROM robotpy/roborio-cross-ubuntu:2020-18.04-base AS crossenv

RUN set -xe; \
    apt-get update; \
    apt-get install -y \
        binutils libreadline5 libncursesw5 libssl1.1 \
        libsqlite3-0 libgdbm5 libbz2-1.0 libffi6 zlib1g; \
    rm -rf /var/lib/apt/lists/*

COPY --from=pycompile /usr/local /usr/local
COPY --from=pycompile /build/crosspy /build/crosspy
COPY opkg-venv /usr/local/bin

RUN set -xe; \
    chmod a+x /usr/local/bin/opkg-venv; \
    ldconfig; \
    python3.8 -m pip install crossenv; \
    python3.8 -m crossenv /build/crosspy/bin/python3.8 /build/venv --sysroot=$(arm-frc2020-linux-gnueabi-gcc -print-sysroot); \
    /build/venv/bin/cross-pip install wheel;

ENV LDSHARED="arm-frc2020-linux-gnueabi-gcc -pthread -shared"
ENV CC="arm-frc2020-linux-gnueabi-gcc -pthread"
ENV RPYBUILD_PARALLEL=1

COPY crossenv.cfg /build/venv/crossenv.cfg
