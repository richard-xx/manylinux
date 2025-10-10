#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

export PIP_BREAK_SYSTEM_PACKAGES=1
export PIP_ROOT_USER_ACTION=ignore
export UV_BREAK_SYSTEM_PACKAGES=true

mkdir /opt/python
find /opt/_internal/ -mindepth 1 -maxdepth 1 \( -name 'cpython*' -o -name 'pypy*' \) -print | sort -V | while IFS= read -r PREFIX
do
  if [[ "$PREFIX" =~ (2\.7|3\.[5-8]\.) ]]; then
    "${PREFIX}"/bin/python -m pip install -U pip build certifi wheel setuptools
  else
    uv pip install --python "${PREFIX}"/bin/python -U pip build certifi wheel setuptools
  fi

  ABI_TAG=$("${PREFIX}"/bin/python /tmp/python-tag-abi-tag.py)

  ln -s "${PREFIX}" /opt/python/"${ABI_TAG}"
done

uv tool install auditwheel
uv tool install patchelf