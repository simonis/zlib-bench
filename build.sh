#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
JAVA=${JAVA:-java}
JAVAC=${JAVAC:-javac}

# This is only needed the first time but doesn't do any harm afterwards
git submodule update --init

bash build/isa-l/build.sh
bash build/zlib-cloudflare/build.sh
bash build/zlib-chromium/build.sh
bash build/zlib-ipp/build.sh
bash build/zlib-madler/build.sh
bash build/zlib-ng/build.sh
bash build/zlib-jtkukunas/build.sh

popd
