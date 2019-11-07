FROM centos:7 as builder

ARG PYTHON_VERSION=3.8.0

# install build dependencies
RUN yum -y install gcc openssl-devel bzip2-devel libffi-devel sqlite-devel make

# build Python from source
RUN mkdir -p /home/build    && \
    pushd /home/build       && \
    curl -o python.tar.gz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz  && \
    tar xf python.tar.gz    && \
    mkdir python-build      && \
    pushd python-build      && \
    ../Python-${PYTHON_VERSION}/configure --prefix=/usr/local --with-lto --enable-shared --enable-optimizations  && \
    make -j $(nproc)        && \
    make install            && \
    popd;   \
    rm -rf *

FROM centos:7
COPY --from=builder /usr/local /usr/local/

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

RUN python3 -m pip install --upgrade pip virtualenv vex
