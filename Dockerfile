
FROM wpilib/roborio-cross-ubuntu:2020-18.04

RUN set -xe; \
    apt-get update; \
    apt-get install -y software-properties-common; \
    apt-add-repository -y ppa:deadsnakes/ppa; \
    apt-get update; \
    apt-get remove -y software-properties-common; apt-get autoremove -y; \
    apt-get install -y python3.8-dev python3.8-distutils python3.8-venv; \
    python3.8 -m pip install crossenv; \
    \
    mkdir -p /build/tmp; mkdir -p /build/robotpy; \
    curl http://tortall.net/~robotpy/feeds/2020/python38_3.8.1-r0_cortexa9-vfpv3.ipk > /build/tmp/python.ipk; \
    curl http://tortall.net/~robotpy/feeds/2020/python38-dev_3.8.1-r0_cortexa9-vfpv3.ipk > /build/tmp/python-dev.ipk; \
    \
    cd /build/tmp; \
    ar x python.ipk data.tar.gz; \
    tar -xf data.tar.gz -C /build/robotpy; \
    ar x python-dev.ipk data.tar.gz; \
    tar -xf data.tar.gz -C /build/robotpy; \
    cd /build; rm -rf /build/tmp; \
    \
    python3.8 -m crossenv /build/robotpy/usr/local/bin/python3.8 /build/venv \
        --sysroot=$(arm-frc2020-linux-gnueabi-gcc -print-sysroot); \
    rm -rf /var/lib/apt/lists/*
