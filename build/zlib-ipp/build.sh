#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
rm -f *o *.h *.pc *.a *.log *1 Makefile
git -C ../../zlib-ipp checkout .
patch -p1 --directory=../../zlib-ipp < ../../ipp/ipp_zlib/zlib-1.2.11.patch
CC=$CC CFLAGS="-m64 -DWITH_IPP -I../../ipp/include" LDFLAGS="-L../../ipp/lib64 -lippdc -lipps -lippcore" ../../zlib-ipp/configure
CC=$CC make libz.so.1.2.11
git -C ../../zlib-ipp checkout .
popd
