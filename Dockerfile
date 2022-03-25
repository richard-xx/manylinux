FROM debian:stretch-slim
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
    && apt-get install --no-install-recommends -qq -y sudo git make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl ca-certificates llvm libncursesw5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip ccache \
    autoconf automake libtool gettext \
    && if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    apt-get --no-install-recommends -qq -y install gcc-multilib g++-multilib ; \
    fi \
    && apt clean autoclean \
    && rm -rf /var/lib/{apt,cache,log} \
    && adduser --shell /bin/bash --disabled-password --gecos "" arm \
    && adduser arm sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && echo "[global]" >> /etc/pip.conf \
    && echo "index-url=https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf \
    && echo "extra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf 
    
RUN git clone https://github.com/openssl/openssl.git --depth 1 -b OpenSSL_1_1_1-stable --recursive --shallow-submodules --quiet \
    && apt remove -y libssl-dev \
    && cd openssl \
    && if [[ "$(dpkg --print-architecture)" = i386 ]]; then \
    env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    MACHINE=$(dpkg --print-architecture) ./config --prefix=/usr --openssldir=/usr --libdir=lib no-shared zlib-dynamic '-Wl,--enable-new-dtags,-rpath,$(LIBRPATH)' > /dev/null ; \
    else \
    env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    ./config --prefix=/usr --openssldir=/usr --libdir=lib no-shared zlib-dynamic '-Wl,--enable-new-dtags,-rpath,$(LIBRPATH)' > /dev/null ;\
    fi \
    && make -s -j2 > /dev/null \
    && make install_sw -j2 > /dev/null \
    && cd .. && rm -rf openssl

# RUN git clone https://github.com/Kitware/CMake.git --depth 1 -b release --quiet \
#     && cd CMake \
#     && env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
#     ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release > /dev/null \
#     && make -s -j2 > /dev/null \
#     && make install -j2 > /dev/null \
#     && cd .. && rm -rf CMake

RUN git clone https://github.com/NixOS/patchelf.git --depth 1 --quiet \
    && cd patchelf \
    && sed -i "s@<optional>@<experimental/optional>@g" src/patchelf.* \
    && sed -i "s@std::optional@std::experimental::optional@g" src/patchelf.* \
    && env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    ./bootstrap.sh > /dev/null \
    && env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    ./configure > /dev/null \
    && make -s -j2 > /dev/null \
    && make check -j2 > /dev/null \
    && make install -j2 > /dev/null \
    && cd .. && rm -rf patchelf
    
USER arm
WORKDIR /io
ENV PYENV_ROOT /home/arm/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:/home/arm/.local/bin:$PATH

RUN curl -sSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && echo 'eval "$(pyenv init --path)"' >> ~/.profile \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc 
    
RUN env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 2.7.18
RUN eval "$(pyenv init -)" \
    && pyenv shell 2.7.18 \
    && curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py | python - \
    && pip install -U build certifi --no-cache-dir

RUN env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.5.10
RUN eval "$(pyenv init -)" \
    && pyenv shell 3.5.10 \
    && curl -sSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | python - \
    && pip install -U build certifi --no-cache-dir

RUN env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.6.15
RUN eval "$(pyenv init -)" \
    && pyenv shell 3.6.15 \
    && curl -sSL https://bootstrap.pypa.io/pip/3.6/get-pip.py | python - \
    && pip install -U build certifi --no-cache-dir

RUN env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.7.13
RUN eval "$(pyenv init -)" \
    && pyenv shell 3.7.13 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - \
    && pip install -U build pipx certifi --no-cache-dir

RUN env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.8.13
RUN eval "$(pyenv init -)" \
    && pyenv shell 3.8.13 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - \
    && pip install -U build pipx certifi --no-cache-dir

RUN env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.9.11
RUN eval "$(pyenv init -)" \
    && pyenv shell 3.9.11 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - \
    && pip install -U build pipx certifi --no-cache-dir

RUN eval "$(pyenv init -)" \
    && pyenv shell 3.9.11 \
    && pipx install auditwheel

RUN env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" \
    PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.10.3
RUN eval "$(pyenv init -)" \
    && pyenv shell 3.10.3 \
    && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - \
    && pip install -U build pipx certifi --no-cache-dir

RUN wget https://github.com/richard-xx/manylinux/releases/download/precompiled_cmake/cmake-3.23.0-Linux-"$(dpkg --print-architecture)".deb \
    && sudo dpkg -i cmake-3.23.0-Linux-"$(dpkg --print-architecture)".deb \
    && rm -rf cmake-3.23.0-Linux-"$(dpkg --print-architecture)".deb
