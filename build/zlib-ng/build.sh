#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
rm -rf *o *.h *.pc *.a *.log *1 Makefile mini* example* test arch a.out make* libz*
CC=$CC ../../zlib-ng/configure --zlib-compat
CC=$CC make
popd
