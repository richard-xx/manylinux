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

ENV UV_PYTHON_INSTALL_DIR="/opt/_internal" \
    UV_NO_CACHE=1 \
    UV_VENV_SEED=1 \
    UV_PYTHON_INSTALL_BIN=0 \
    UV_INSTALL_DIR="/usr/local/bin" \
    UV_TOOL_DIR="/opt/_internal/uv-tools" \
    UV_TOOL_BIN_DIR="/usr/local/bin"

ADD https://astral.sh/uv/install.sh /uv-installer.sh

RUN sh /uv-installer.sh && rm /uv-installer.sh

RUN uv python install 3.9.25

RUN uv python install 3.10.19

RUN uv python install 3.11.14

RUN uv python install 3.12.12

RUN uv python install 3.13.11
    
RUN uv python install 3.13.11t

RUN uv python install 3.14.2
    
RUN uv python install 3.14.2t

COPY finalize.sh python-tag-abi-tag.py /tmp/
RUN /tmp/finalize.sh

USER arm
WORKDIR /io
