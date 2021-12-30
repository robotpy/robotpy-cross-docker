ARG VERSION=invalid-version
FROM robotpy/roborio-cross-ubuntu:${VERSION}-base

RUN set -xe; \
    apt-get update; \
    apt-get install -y ccache; \
    rm -rf /var/lib/apt/lists/*

ENV RPYBUILD_PARALLEL=1
ENV CC="ccache arm-frc2022-linux-gnueabi-gcc"
ENV GCC_COLORS=1