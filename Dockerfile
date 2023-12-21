FROM phusion/baseimage:jammy-1.0.1 AS builder


ARG PYTHON_VERSION=3.12.1

# install build dependencies
RUN apt update && \
    apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget

# build Python from source
RUN mkdir -p /home/build    && \
    cd /home/build       && \
    curl -o python.tar.gz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz  && \
    tar xf python.tar.gz    && \
    mkdir python-build      && \
    cd python-build      && \
    ../Python-${PYTHON_VERSION}/configure --prefix=/usr/local  --with-lto --enable-shared LDFLAGS=-Wl,-rpath,/usr/local/lib --enable-optimizations  && \
    make -j $(nproc)        && \
    make install         && \
    cd ..;   \
    rm -rf *

FROM phusion/baseimage:jammy-1.0.1

COPY --from=builder /usr/local /usr/local/

# remove ubuntu's built-in old python and install openssl as it's required for python to work
RUN apt update && apt remove -y python3 && apt install -y openssl

RUN ln -s /usr/local/bin/python3 /usr/local/bin/python
RUN python -m pip install --upgrade pip virtualenv vex
