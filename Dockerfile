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

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.7.16 /opt/_internal/cpython-3.7.16 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.7.16/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.8.16 /opt/_internal/cpython-3.8.16 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.8.16/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.9.16 /opt/_internal/cpython-3.9.16 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.9.16/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.10.9 /opt/_internal/cpython-3.10.9 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.10.9/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.11.1 /opt/_internal/cpython-3.11.1 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.11.1/bin/python -

COPY finalize.sh python-tag-abi-tag.py /tmp/
RUN /tmp/finalize.sh

RUN if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/latest \
    | egrep "https://github.com/NixOS/patchelf/releases/download/.*?i686" \
    | cut -d : f 2,3 | tr -d '"' | tr -d '[:space:]'); \
    else \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/latest \
    | egrep "https://github.com/NixOS/patchelf/releases/download/.*?$(uname -m)" \
    | cut -d : -f 2,3 | tr -d '"' | tr -d '[:space:]'); \
    fi \
    && curl -sSLo - ${url} | tar -zxv --strip-components=1 -C /usr/local

USER arm
WORKDIR /io
