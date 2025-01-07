#!/bin/bash
apt install libev-dev -y
git clone --depth 1 -b v1.41.1 https://github.com/aws/aws-lc
cd aws-lc
cmake -B build -DDISABLE_GO=ON
make -j$(nproc) -C build
cd ..
git clone --recursive https://github.com/ngtcp2/nghttp3
cd nghttp3
autoreconf -i
./configure --prefix=$PWD/build --enable-lib-only
make -j$(nproc) check
make install
cd ..
autoreconf -i
# For Mac users who have installed libev with MacPorts, append
# LIBEV_CFLAGS="-I/opt/local/include" LIBEV_LIBS="-L/opt/local/lib -lev"
./configure PKG_CONFIG_PATH=$PWD/nghttp3/build/lib/pkgconfig \
    BORINGSSL_CFLAGS="-I$PWD/aws-lc/include" \
    BORINGSSL_LIBS="-L$PWD/aws-lc/build/ssl -lssl -L$PWD/aws-lc/build/crypto -lcrypto" \
    --with-boringssl
make -j$(nproc) check