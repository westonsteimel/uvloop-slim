#!/bin/bash

set -e

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${UVLOOP_VERSION}" ]]; then
        UVLOOP_VERSION=$(pip search uvloop | pcregrep -o1 -e "^uvloop \((.*)\).*$")
    fi

    echo "slimming wheels for uvloop version ${UVLOOP_VERSION}"
    
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2010_x86_64 uvloop==${UVLOOP_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2010_x86_64 uvloop==${UVLOOP_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.6 --platform manylinux2010_x86_64 uvloop==${UVLOOP_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.5 --platform manylinux2010_x86_64 uvloop==${UVLOOP_VERSION}

    for filename in ./*.whl
    do
        wheel unpack $filename
        strip uvloop-${UVLOOP_VERSION}/uvloop/*.so
        rm uvloop-${UVLOOP_VERSION}/uvloop/loop.c
        wheel pack uvloop-${UVLOOP_VERSION}

        rm -r uvloop-${UVLOOP_VERSION}
    done

    pip uninstall -y --disable-pip-version-check uvloop
    pip install --disable-pip-version-check uvloop -f .

    python -c "
import uvloop
print(uvloop.__version__)
"
)
