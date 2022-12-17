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
    && apt update -qq \
    && apt install --no-install-recommends -qq -y apt-utils dialog \
    && apt install --no-install-recommends -qq -y wget curl ca-certificates apt-transport-https \
    && sed -i "s#http:#https:#g" /etc/apt/sources.list \
    && mkdir -p /usr/local/share/keyrings \
    && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x0FFB30A4102243D5" \
    | gpg --dearmor | tee /usr/local/share/keyrings/richard-cmake.gpg > /dev/null \
    && echo "deb [signed-by=/usr/local/share/keyrings/richard-cmake.gpg] https://ppa.launchpad.net/richard-deng/cmake/ubuntu xenial main" \
    | tee /etc/apt/sources.list.d/richard-deng-ubuntu-cmake.list \
    && apt update -qq \
    && apt install --no-install-recommends -qq -y sudo git make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip ccache cmake openssl \
    && if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    apt --no-install-recommends -qq -y install gcc-multilib g++-multilib ; \
    fi \
    && apt clean autoclean \
    && rm -rf /var/lib/{apt,cache,log} \
    && adduser --shell /bin/bash --disabled-password --gecos "" arm \
    && adduser arm sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "[global]" >> /etc/pip.conf \
    && echo "extra-index-url=https://mirrors.cernet.edu.cn/pypi/simple https://mirrors.tuna.tsinghua.edu.cn/pypi/simple" >> /etc/pip.conf \
    && echo "trusted-host = mirrors.cernet.edu.cn pypi.tuna.tsinghua.edu.cn pypi.org" >> /etc/pip.conf

# RUN apt remove -y libssl-dev \
#     && curl -sSLo openssl_1.1.1n.deb https://github.com/richard-xx/manylinux/releases/download/OpenSSL_1_1_1n/openssl_1.1.1n-1_"$(dpkg --print-architecture)".deb \
#     && sudo dpkg -i openssl_1.1.1n.deb \
#     && rm -rf openssl_1.1.1n.deb

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

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.7.16 /opt/_internal/cpython-3.7.16
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.7.16/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.8.16 /opt/_internal/cpython-3.8.16
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.8.16/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.9.16 /opt/_internal/cpython-3.9.16
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.9.16/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.10.9 /opt/_internal/cpython-3.10.9
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.10.9/bin/python -

RUN cd pyenv/plugins/python-build \
    && git pull \
    && sudo bash ./install.sh \
    && env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" python-build 3.11.1 /opt/_internal/cpython-3.11.1
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.11.1/bin/python -

COPY finalize.sh python-tag-abi-tag.py /tmp/
RUN /tmp/finalize.sh

RUN if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/latest | egrep "https://github.com/NixOS/patchelf/releases/download/.*?i686" | cut -d : f 2,3 | tr -d '"' ); \
    else \
    url=$(curl https://api.github.com/repos/NixOS/patchelf/releases/latest | egrep "https://github.com/NixOS/patchelf/releases/download/.*?$(uname -m)" | cut -d : -f 2,3 | tr -d '"' ); \
    fi \
    && curl -sSLo - ${url} | tar -zxv --strip-components=1 -C /usr/local

USER arm
WORKDIR /io
