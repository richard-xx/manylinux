FROM debian:stretch-slim
ENV TZ 'Asia/Shanghai'
ENV SHELL /bin/bash
SHELL ["/bin/bash","-c"]

WORKDIR /io

RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update -qq\
    && apt-get install --no-install-recommends -y sudo git make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev patchelf xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev unzip cmake \
    && apt clean autoclean \
    && rm -rf /var/lib/{apt,dpkg,cache,log} \
    && adduser --shell /bin/bash --disabled-password --gecos "" arm \
    && adduser arm sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \   
    && echo "[global]" >> /etc/pip.conf \
    && echo "extra-index-url=https://www.piwheels.org/simple" >> /etc/pip.conf 

USER arm
ENV PYENV_ROOT /home/arm/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:/home/arm/.local/bin:$PATH

RUN curl -sSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && echo 'eval "$(pyenv init --path)"' >> ~/.profile \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
    && sed -i "s@https://www.python.org/ftp@http://npm.taobao.org/mirrors@g" $PYENV_ROOT/plugins/python-build/share/python-build/*.* 
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared " pyenv install -v 2.7.18
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared " pyenv install -v 3.5.10
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared " pyenv install -v 3.6.15
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared " pyenv install -v 3.7.12
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared " pyenv install -v 3.8.12
RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared " pyenv install -v 3.9.10

RUN eval "$(pyenv init -)" && pyenv shell 2.7.18 && curl -sSL https://bootstrap.pypa.io/pip/2.7/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir
RUN eval "$(pyenv init -)" && pyenv shell 3.5.10 && curl -sSL https://bootstrap.pypa.io/pip/3.5/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir
RUN eval "$(pyenv init -)" && pyenv shell 3.6.15 && curl -sSL https://bootstrap.pypa.io/pip/3.6/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir
RUN eval "$(pyenv init -)" && pyenv shell 3.7.12 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir
RUN eval "$(pyenv init -)" && pyenv shell 3.8.12 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir
RUN eval "$(pyenv init -)" && pyenv shell 3.9.10 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir

RUN env PYTHON_MAKE_OPTS="-j$(nproc)" PYTHON_CONFIGURE_OPTS="--enable-shared " pyenv install -v 3.10.2
RUN eval "$(pyenv init -)" && pyenv shell 3.10.2 && curl -sSL https://bootstrap.pypa.io/get-pip.py | python - && pip install -U build pipx certifi --no-cache-dir

RUN eval "$(pyenv init -)" && pyenv shell 3.10.2 && pipx install -U auditwheel