#!/bin/bash

set -e

pip install -U pip==20.2.4

PIP_DOWNLOAD_CMD="pip download --no-deps --disable-pip-version-check"

mkdir -p dist

(
    cd dist

    if [[ -z "${UVLOOP_VERSION}" ]]; then
        echo "Set the UVLOOP_VERSION environment variable."
        exit 1
    fi

    echo "slimming wheels for uvloop version ${UVLOOP_VERSION}"
    
    $PIP_DOWNLOAD_CMD --python-version 3.9 --platform manylinux2010_x86_64 uvloop==${UVLOOP_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.8 --platform manylinux2010_x86_64 uvloop==${UVLOOP_VERSION}
    $PIP_DOWNLOAD_CMD --python-version 3.7 --platform manylinux2010_x86_64 uvloop==${UVLOOP_VERSION}

    for filename in ./*.whl
    do
        wheel unpack $filename
        strip uvloop-${UVLOOP_VERSION}/uvloop/*.so
        rm uvloop-${UVLOOP_VERSION}/uvloop/loop.c
        wheel pack uvloop-${UVLOOP_VERSION}

        rm -r uvloop-${UVLOOP_VERSION}
    done

    pip uninstall -y --disable-pip-version-check uvloop
    pip install \
        --disable-pip-version-check uvloop==${UVLOOP_VERSION} \
        -f . \
        --index-url https://westonsteimel.github.io/pypi-repo \
        --extra-index-url https://pypi.org/pypi

    python -c "
import uvloop
print(uvloop.__version__)
"
)
