FROM amazonlinux:2 as builder

ARG PYTHON_VERSION=3.10.4

# install build dependencies
RUN yum update -y
RUN yum groupinstall "Development Tools" -y
RUN yum -y install gcc openssl11-devel bzip2-devel libffi-devel sqlite-devel make xz-devel tar libffi-devel bzip2-devel wget

# build Python from source
RUN mkdir -p /home/build    && \
    pushd /home/build       && \
    curl -o python.tar.gz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz  && \
    tar xf python.tar.gz    && \
    mkdir python-build      && \
    pushd python-build      && \
    ../Python-${PYTHON_VERSION}/configure --prefix=/usr/local --with-lto --enable-shared --enable-optimizations  && \
    make -j $(nproc)        && \
    make install         && \
    popd;   \
    rm -rf *

FROM amazonlinux:2

COPY --from=builder /usr/local /usr/local/

# openssl11 is required for python3 to work
RUN yum -y update && yum -y install openssl11

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

RUN python3 -m pip install --upgrade pip virtualenv vex
