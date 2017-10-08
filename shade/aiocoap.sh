#!/bin/sh
set -e

git clone https://github.com/chrysn/aiocoap/
cd aiocoap
git reset --hard 3286f48f0b949901c8b5c04c0719dc54ab63d431
python3 -m pip install .
