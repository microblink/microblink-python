FROM centos:7 as builder

ARG PYTHON_VERSION=3.7.3

# install build dependencies
RUN yum -y install gcc openssl-devel bzip2-devel libffi-devel sqlite-devel make

# build Python from source
RUN mkdir -p /home/build    && \
    pushd /home/build       && \
    curl -o python.tar.gz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz  && \
    tar xf python.tar.gz    && \
    mkdir python-build      && \
    pushd python-build      && \
    ../Python-${PYTHON_VERSION}/configure --prefix=/home/python --enable-optimizations  && \
    make -j $(nproc)        && \
    make install            && \
    popd;   \
    rm -rf *

FROM centos:7
COPY --from=builder /home/python /usr/local/
RUN python3 -m pip install --upgrade pip
