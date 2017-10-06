#!/bin/sh
set -e

git clone --depth 1 https://git.fslab.de/jkonra2m/tinydtls
cd tinydtls
autoreconf
./configure --with-ecc --without-debug
cd cython
python3 setup.py install
