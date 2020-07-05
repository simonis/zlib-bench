#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
JAVA=${JAVA:-java}
JAVAC=${JAVAC:-javac}

$CC -std=c99 -D_POSIX_C_SOURCE=199309L -O2 -o zbench \
    -I../../zlib-madler -I../../isa-l/include ../../benchmarks/c/zbench.c \
    -Wl,--unresolved-symbols=report-all -L../../build/zlib-madler -lz \
    -L../../ipp/lib64 -lippcore -lipps -lippdc -L../isa-l -lz-isal -lrt

$JAVAC -d . ../../benchmarks/java/io/simonis/ZBench.java
$JAVAC -d . ../../benchmarks/java/io/simonis/CreateVegaLiteGraph.java
