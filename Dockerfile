FROM amazonlinux:2022 as builder

ARG PYTHON_VERSION=3.11.0

# install build dependencies
RUN yum update -y
RUN yum groupinstall "Development Tools" -y
RUN yum -y install gcc openssl-devel bzip2-devel libffi-devel sqlite-devel make xz-devel tar libffi-devel wget

# build Python from source
RUN mkdir -p /home/build    && \
    pushd /home/build       && \
    curl -o python.tar.gz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz  && \
    tar xf python.tar.gz    && \
    mkdir python-build      && \
    pushd python-build      && \
    ../Python-${PYTHON_VERSION}/configure --prefix=/usr/local  --with-lto --enable-shared LDFLAGS=-Wl,-rpath,/usr/local/lib --enable-optimizations  && \
    make -j $(nproc)        && \
    make install         && \
    popd;   \
    rm -rf *

FROM amazonlinux:2022

COPY --from=builder /usr/local /usr/local/

# openssl is required for python3 to work
RUN yum -y update && yum -y install openssl

RUN python3 -m pip install --upgrade pip virtualenv vex
