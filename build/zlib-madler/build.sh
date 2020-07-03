#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
rm -f *o *.h *.pc *.a *.log *1 Makefile mini* example*
CC=$CC ../../zlib-madler/configure
CC=$CC make
popd
