#!/bin/sh
set -e
git clone --depth 1 --recursive -b dtls https://github.com/home-assistant/libcoap.git
cd libcoap
# Don't look at next 2 lines. These hacks are just too ugly.
sed -i "s/#if 0/#if 1/g" ext/tinydtls/sha2/sha2.h
sed -i "17i#include <time.h>" include/coap/coap_time.h
./autogen.sh
./configure --disable-documentation --disable-shared --without-debug CFLAGS="-D COAP_DEBUG_FD=stderr"
make
make install
