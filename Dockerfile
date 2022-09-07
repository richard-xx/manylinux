FROM ubuntu:16.04
ENV TZ 'Asia/Shanghai'
ENV SHELL /bin/bash
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
    && echo "index-url=https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf

RUN git clone https://github.com/pyenv/pyenv.git --depth 1 \
    && cd pyenv/plugins/python-build \
    && sudo bash ./install.sh
    
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto" python-build 2.7.18 /opt/_internal/cpython-2.7.18
RUN curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py | /opt/_internal/cpython-2.7.18/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto" python-build 3.5.10 /opt/_internal/cpython-3.5.10
RUN curl -sSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | /opt/_internal/cpython-3.5.10/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto" python-build 3.6.15 /opt/_internal/cpython-3.6.15
RUN curl -sSL https://bootstrap.pypa.io/pip/3.6/get-pip.py | /opt/_internal/cpython-3.6.15/bin/python -
    && pip install -U build certifi --no-cache-dir

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto" python-build 3.7.13 /opt/_internal/cpython-3.7.13
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.7.13/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto" python-build 3.8.13 /opt/_internal/cpython-3.8.13
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.8.13/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto" python-build 3.9.13 /opt/_internal/cpython-3.9.13
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.9.13/bin/python -

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto" python-build 3.10.7 /opt/_internal/cpython-3.10.7
RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | /opt/_internal/cpython-3.10.7/bin/python -

RUN mkdir /opt/python \
    && for PREFIX in $(find /opt/_internal/ -mindepth 1 -maxdepth 1 \( -name 'cpython*' -o -name 'pypy*' \)); do \
        $(${PREFIX}/bin/python -m pip install -U build certifi \
        ABI_TAG=$(${PREFIX}/bin/python ${MY_DIR}/python-tag-abi-tag.py) \
        ln -s ${PREFIX} /opt/python/${ABI_TAG} \
        if [[ "${PREFIX}" == *"/pypy"* ]]; then \
            ln -s ${PREFIX}/bin/python /usr/local/bin/pypy${PY_VER} \
        else \
            ln -s ${PREFIX}/bin/python /usr/local/bin/python${PY_VER} \
        fi \
    done \
    && TOOLS_PATH=/opt/_internal/tools \
    && /opt/python/cp39-cp39/bin/python -m venv $TOOLS_PATH \
    && source $TOOLS_PATH/bin/activate \
    && pip install -U pipx \
    && cat <<EOF > /usr/local/bin/pipx \
    #!/bin/bash 
    set -euo pipefail \
    if [ \$(id -u) -eq 0 ]; then \
        export PIPX_HOME=/opt/_internal/pipx \
        export PIPX_BIN_DIR=/usr/local/bin \
        fi \
        ${TOOLS_PATH}/bin/pipx "\$@" \
    EOF \
    && chmod 755 /usr/local/bin/pipx \
    && deactivate \
    && pipx install auditwheel \
    && pipx install patchelf

USER arm
WORKDIR /io
