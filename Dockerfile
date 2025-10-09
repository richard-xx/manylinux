FROM ghcr.io/richard-xx/raspbian:9_base
ENV TZ='Asia/Shanghai'
ENV SHELL=/bin/bash
SHELL ["/bin/bash","-c"]
USER root
ENV DEBIAN_FRONTEND=noninteractive
ENV MANYLINUX_CPPFLAGS="-march=armv6 -Wdate-time -D_FORTIFY_SOURCE=2"
ENV MANYLINUX_CFLAGS="-march=armv6 -g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_CXXFLAGS="-march=armv6 -g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_LDFLAGS="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -L/usr/local/ssl/lib -Wl,-rpath,/usr/local/ssl/lib"

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.9.23 /opt/_internal/cpython-3.9.23 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.9.23/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.10.18 /opt/_internal/cpython-3.10.18 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.10.18/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.11.13 /opt/_internal/cpython-3.11.13 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.11.13/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.12.11 /opt/_internal/cpython-3.12.11 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.12.11/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.13.8 /opt/_internal/cpython-3.13.8 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.13.8/bin/python -
    
RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.13.8t /opt/_internal/cpython-3.13.8t \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.13.8t/bin/python -

RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.14.0 /opt/_internal/cpython-3.14.0 \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.14.0/bin/python -
    
RUN cd /pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.14.0t /opt/_internal/cpython-3.14.0t \
    && curl -fsSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.14.0t/bin/python -

COPY finalize.sh python-tag-abi-tag.py /tmp/
RUN /tmp/finalize.sh

RUN if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/88491801 | egrep "https://github.com/NixOS/patchelf/releases/download/.*?i686" | cut -d : f 2,3 | tr -d '"' ); \
    else \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/88491801 | egrep "https://github.com/NixOS/patchelf/releases/download/.*?$(uname -m)" | cut -d : -f 2,3 | tr -d '"' ); \
    fi \
    && curl -sSLo - ${url} | tar -zxv --strip-components=1 -C /usr/local

USER pi
WORKDIR /io
