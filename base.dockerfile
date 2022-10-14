FROM ubuntu:22.04

RUN set -xe; \
    apt-get update; \
    apt-get install -y tzdata; \
    apt-get install -y \
        ca-certificates \
        curl \
        git \
        make \
        unzip \
        wget \
        zip; \
    rm -rf /var/lib/apt/lists/*

RUN curl -SL https://github.com/wpilibsuite/opensdk/releases/download/v2023-5/cortexa9_vfpv3-roborio-academic-2023-x86_64-linux-gnu-Toolchain-12.1.0.tgz | sh -c 'mkdir -p /usr/local && cd /usr/local && tar xzf - --strip-components=2'
