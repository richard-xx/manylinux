FROM ubuntu:16.04
ENV TZ='Asia/Shanghai'
ENV SHELL=/bin/bash
SHELL ["/bin/bash","-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV MANYLINUX_CPPFLAGS="-Wdate-time -D_FORTIFY_SOURCE=2"
ENV MANYLINUX_CFLAGS="-g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_CXXFLAGS="-g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_LDFLAGS="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now"
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update -qq \
    && apt-get install --no-install-recommends -qq -y apt-utils dialog \
    && apt-get install --no-install-recommends -qq wget curl ca-certificates \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv B43AA98A456BA62E7D0FC2570FFB30A4102243D5 \
    && echo "deb http://ppa.launchpadcontent.net/richard-deng/cmake/ubuntu xenial main" | tee /etc/apt/sources.list.d/richard-deng-ubuntu-cmake.list \
    && apt-get install --no-install-recommends -qq -y sudo git make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip ccache cmake \
    && if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    apt-get --no-install-recommends -qq -y install gcc-multilib g++-multilib ; \
    fi \
    && apt clean autoclean \
    && rm -rf /var/lib/{apt,cache,log} \
    && adduser --shell /bin/bash --disabled-password --gecos "" arm \
    && adduser arm sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "[global]" >> /etc/pip.conf \
    && echo "extra-index-url=https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf \
    && echo "                http://pypi.org/simple" >> /etc/pip.conf \
    && echo "                https://pypi.org/simple" >> /etc/pip.conf \
    && echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf \
    && echo "               pypi.org" >> /etc/pip.conf

RUN apt remove -y libssl-dev \
    && curl -sSLo openssl_1.1.1n.deb https://github.com/richard-xx/manylinux/releases/download/OpenSSL_1_1_1n/openssl_1.1.1n-1_"$(dpkg --print-architecture)".deb \
    && sudo dpkg -i openssl_1.1.1n.deb \
    && rm -rf openssl_1.1.1n.deb

RUN git clone https://github.com/pyenv/pyenv.git --depth 1 \
    && cd pyenv/plugins/python-build \
    && sudo bash ./install.sh
    
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 2.7.18 /opt/_internal/cpython-2.7.18
RUN curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py | /opt/_internal/cpython-2.7.18/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.5.10 /opt/_internal/cpython-3.5.10
RUN curl -sSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | /opt/_internal/cpython-3.5.10/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.6.15 /opt/_internal/cpython-3.6.15
RUN curl -sSL https://bootstrap.pypa.io/pip/3.6/get-pip.py | /opt/_internal/cpython-3.6.15/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.7.13 /opt/_internal/cpython-3.7.13
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.7.13/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.8.13 /opt/_internal/cpython-3.8.13
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.8.13/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.9.13 /opt/_internal/cpython-3.9.13
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.9.13/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.10.7 /opt/_internal/cpython-3.10.7
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.10.7/bin/python -

COPY finalize.sh python-tag-abi-tag.py /tmp/
RUN /tmp/finalize.sh

RUN if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    curl -sSLo - https://github.com/NixOS/patchelf/releases/download/0.15.0/patchelf-0.15.0-i686.tar.gz | tar -zxv --strip-components=1 -C /usr/local ; \
    else \
    curl -sSLo - https://github.com/NixOS/patchelf/releases/download/0.15.0/patchelf-0.15.0-$(uname -m).tar.gz | tar -zxv --strip-components=1 -C /usr/local ; \
    fi \

USER arm
WORKDIR /io
