FROM ubuntu:18.04

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

RUN curl -SL https://github.com/wpilibsuite/roborio-toolchain/releases/download/v2020-2/FRC-2020-Linux-Toolchain-7.3.0.tar.gz | sh -c 'mkdir -p /usr/local && cd /usr/local && tar xzf - --strip-components=2'
