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
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.9.21 /opt/_internal/cpython-3.9.21 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.9.21/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.10.16 /opt/_internal/cpython-3.10.16 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.10.16/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.11.11 /opt/_internal/cpython-3.11.11 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.11.11/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.12.8 /opt/_internal/cpython-3.12.8 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.12.8/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.13.1 /opt/_internal/cpython-3.13.1 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.13.1/bin/python -
    
RUN cd /pyenv/plugins/python-build \
&& git pull \
&& sudo bash ./install.sh \
&& env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.13.1t /opt/_internal/cpython-3.13.1t \
&& curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.13.1t/bin/python -

COPY finalize.sh python-tag-abi-tag.py /tmp/
RUN /tmp/finalize.sh

RUN if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/88491801 | egrep "https://github.com/NixOS/patchelf/releases/download/.*?i686" | cut -d : -f 2,3 | tr -d '"' ); \
    else \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/88491801 | egrep "https://github.com/NixOS/patchelf/releases/download/.*?$(uname -m)" | cut -d : -f 2,3 | tr -d '"' ); \
    fi \
    && curl -sSLo - ${url} | tar -zxv --strip-components=1 -C /usr/local

USER arm
WORKDIR /io
