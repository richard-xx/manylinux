FROM debian:stretch-slim
ENV TZ 'Asia/Shanghai'
ENV SHELL /bin/bash
SHELL ["/bin/bash","-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV MANYLINUX_CPPFLAGS="-Wdate-time -D_FORTIFY_SOURCE=2"
ENV MANYLINUX_CFLAGS="-g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_CXXFLAGS="-g -O2 -Wall -fdebug-prefix-map=/=. -fstack-protector-strong -Wformat -Werror=format-security"
ENV MANYLINUX_LDFLAGS="-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now"
ARG env CPPFLAGS="${MANYLINUX_CPPFLAGS}" CFLAGS="${MANYLINUX_CFLAGS} -fPIC" CXXFLAGS="${MANYLINUX_CXXFLAGS} -fPIC" LDFLAGS="${MANYLINUX_LDFLAGS} -fPIC" 
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update -qq \
    && apt-get install --no-install-recommends -y apt-utils dialog \
    && apt-get install --no-install-recommends -y sudo git make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl ca-certificates llvm libncursesw5-dev \
    xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip ccache \
    && if [[ "$(uname -m)" =~ *86* ]]; then \
    apt-get --no-install-recommends -y install gcc-multilib g++-multilib ; \
    fi \
    && apt clean autoclean \
    && rm -rf /var/lib/{apt,cache,log} \
    && adduser --shell /bin/bash --disabled-password --gecos "" arm \
    && adduser arm sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \   
    && echo "[global]" >> /etc/pip.conf \
    && echo "index-url=https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf \
    && echo "extra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf 

RUN wget -O- https://mirrors.cloud.tencent.com/openssl/source/old/1.1.1/openssl-1.1.1l.tar.gz | tar -xzf - \
    && mkdir -p openssl-1.1.1l/build \
    && cd openssl-1.1.1l/build \
    && ../config --prefix=/usr --openssldir=/usr --libdir=lib no-shared zlib-dynamic \
    && make -j \
    && make install -j \
    && cd ../.. && rm -rf CMake

RUN git clone  https://github.com/Kitware/CMake.git --depth 1 \
    && cd CMake \
    && ./bootstrap \
    && make -j \
    && make install -j \
    && cd .. && rm -rf CMake

RUN git clone https://github.com/NixOS/patchelf.git --depth 1 \
    && cd patchelf \
    && ./bootstrap.sh \
    && ./configure \
    && make -j \
    && make check \
    && make install -j \
    && cd .. && rm -rf patchelf

USER arm
WORKDIR /io
ENV PYENV_ROOT /home/arm/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:/home/arm/.local/bin:$PATH

RUN curl -sSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && echo 'eval "$(pyenv init --path)"' >> ~/.profile \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc 
    
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 2.7.18
RUN eval "$(pyenv init -)" && pyenv shell 2.7.18 && curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py | python - && pip install -U build certifi --no-cache-dir

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.5.10
RUN eval "$(pyenv init -)" && pyenv shell 3.5.10 && curl -sSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | python - && pip install -U build certifi --no-cache-dir

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.6.15
RUN eval "$(pyenv init -)" && pyenv shell 3.6.15 && curl -sSL https://bootstrap.pypa.io/pip/3.6/get-pip.py | python - && pip install -U build certifi --no-cache-dir

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.7.12
RUN eval "$(pyenv init -)" && pyenv shell 3.7.12 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.8.12
RUN eval "$(pyenv init -)" && pyenv shell 3.8.12 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.9.10
RUN eval "$(pyenv init -)" && pyenv shell 3.9.10 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir

RUN eval "$(pyenv init -)" && pyenv shell 3.9.10 && pipx install auditwheel

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared --with-openssl-rpath=auto --with-ensurepip=no" pyenv install 3.10.2
RUN eval "$(pyenv init -)" && pyenv shell 3.10.2 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir

