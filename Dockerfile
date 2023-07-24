FROM ghcr.io/richard-xx/manylinux:base
ENV TZ='Asia/Shanghai'
ENV SHELL=/bin/bash
SHELL ["/bin/bash","-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV MANYLINUX_CPPFLAGS="-Wdate-time -D_FORTIFY_SOURCE=2"
ENV MANYLINUX_CFLAGS="-g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_CXXFLAGS="-g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_LDFLAGS="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now"

USER root

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.7.17 /opt/_internal/cpython-3.7.17 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.7.17/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.8.17 /opt/_internal/cpython-3.8.17 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.8.17/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.9.17 /opt/_internal/cpython-3.9.17 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.9.17/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.10.12 /opt/_internal/cpython-3.10.12 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.10.12/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.11.4 /opt/_internal/cpython-3.11.4 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.11.4/bin/python -

COPY finalize.sh python-tag-abi-tag.py /tmp/
RUN /tmp/finalize.sh

USER arm
WORKDIR /io
