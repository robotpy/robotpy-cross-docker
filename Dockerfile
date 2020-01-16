
FROM wpilib/roborio-cross-ubuntu:2020-18.04

ENV TARGET_HOST="arm-frc2020-linux-gnueabi"
ENV BUILD_HOST="x86_64"
ENV WORKING_DIRECTORY="/python_xcompile"
ENV INSTALL_DIRECTORY="$WORKING_DIRECTORY/_install"
ENV PYTHON_VERSION="3.8.1"
ENV SOURCE_DIRECTORY="Python-$PYTHON_VERSION"
ENV PYTHON_ARCHIVE="Python-$PYTHON_VERSION.tar.xz"
ENV PREFIX="$INSTALL_DIRECTORY"

# Preparing compile environment
RUN set -xe; \
    mkdir -p "$INSTALL_DIRECTORY"; \
    # python prereqs
    apt update; apt install -y build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev \
        libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev; \
    # Download
    cd $WORKING_DIRECTORY; \
    wget -c http://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_ARCHIVE; \
    rm -rf $SOURCE_DIRECTORY; \
    tar -xf $PYTHON_ARCHIVE; \
    cd $SOURCE_DIRECTORY; \
    # Build 3.8 for host
    cd $WORKING_DIRECTORY;cd $SOURCE_DIRECTORY; ./configure --enable-optimizations --with-ensurepip=install; \
    make -j8 altinstall; \
    # cross-compile for frc2020
    cd $WORKING_DIRECTORY;cd $SOURCE_DIRECTORY; make distclean; \
    ./configure --host=$TARGET_HOST --build=$BUILD_HOST --prefix=$INSTALL_DIRECTORY \
        --disable-ipv6 --enable-unicode=ucs4 \
        ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no \
        ac_cv_have_long_long_format=yes; \
    make -j8; \
    # make install here is fine because we include --prefix in the configure statement
    make install; \
    mkdir /build; \
    python3.8 -m pip install crossenv; \
    python3.8 -m crossenv /python_xcompile/_install/bin/python3.8 /build/venv --sysroot=$(arm-frc2020-linux-gnueabi-gcc -print-sysroot); \
    rm -rf /var/lib/apt/lists/*
COPY crossenv.cfg /build/venv/crossenv.cfg