#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
rm -f *o *.h *.pc *.a *.log *1 Makefile mini* example* libz*
git -C ../../zlib-cloudflare checkout .
patch --directory=../../zlib-cloudflare < build_from_external_directory.patch
CC=$CC ../../zlib-cloudflare/configure
CC=$CC make libz.so.1.2.8
git -C ../../zlib-cloudflare checkout .
popd
