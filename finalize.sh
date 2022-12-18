#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

mkdir /opt/python
find /opt/_internal/ -mindepth 1 -maxdepth 1 \( -name 'cpython*' -o -name 'pypy*' \) -print0 | while IFS= read -r -d '' PREFIX
do
  "${PREFIX}"/bin/python -m pip install -U build certifi wheel setuptools
  ABI_TAG=$("${PREFIX}"/bin/python /tmp/python-tag-abi-tag.py)
  ln -s "${PREFIX}" /opt/python/"${ABI_TAG}"
done

TOOLS_PATH=/opt/_internal/tools 
/opt/python/cp39-cp39/bin/python -m venv $TOOLS_PATH
source $TOOLS_PATH/bin/activate

pip install -U pipx

echo -e '#!/bin/bash\n\nset -euo pipefail\n\nif [ $(id -u) -eq 0 ]; then\n\texport PIPX_HOME=/opt/_internal/pipx\n\texport PIPX_BIN_DIR=/usr/local/bin\nfi\n/opt/_internal/tools/bin/pipx "$@"' > /usr/local/bin/pipx
chmod 755 /usr/local/bin/pipx
deactivate

pipx install auditwheel
