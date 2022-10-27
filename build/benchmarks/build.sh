#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
JAVA=${JAVA:-java}
JAVAC=${JAVAC:-javac}
ARCH=`uname -m`

if test "$ARCH" = "x86_64"; then
  LIBS="-L../../ipp/lib64 -lippcore -lipps -lippdc"
fi

$CC -std=c99 -D_POSIX_C_SOURCE=199309L -O2 -o zbench \
    -I../../zlib-madler -I../../isa-l/include ../../benchmarks/c/zbench.c \
    -Wl,--unresolved-symbols=report-all -L../../build/zlib-madler -lz \
    $LIBS -L../isa-l -lz-isal -lrt

$JAVAC -d . ../../benchmarks/java/io/simonis/ZBench.java
$JAVAC -d . ../../benchmarks/java/io/simonis/CreateVegaLiteGraph.java
