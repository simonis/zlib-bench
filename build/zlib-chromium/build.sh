#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
BASEDIR=../../zlib-chromium
ARCH=`uname -m`
if test "$ARCH" = "x86_64"; then
  FLAGS="-DX86_NOT_WINDOWS -DADLER32_SIMD_SSSE3 -DINFLATE_CHUNK_SIMD_SSE2 -DCRC32_SIMD_SSE42_PCLMUL -msse4.2 -mpclmul"
fi
if test "$ARCH" = "aarch64"; then
  FLAGS="-DARMV8_OS_LINUX -DADLER32_SIMD_NEON -DINFLATE_CHUNK_SIMD_NEON -DCRC32_ARMV8_CRC32 -march=armv8-a+crc"
  git -C ../../zlib-chromium checkout .
  patch -p1 --directory=../../zlib-chromium < aarch64_build.patch
fi

rm -f *.o *.so

${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o adler32_simd.o ${BASEDIR}/adler32_simd.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o inffast_chunk.o ${BASEDIR}/contrib/optimizations/inffast_chunk.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o inflate.o ${BASEDIR}/contrib/optimizations/inflate.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o crc32_simd.o ${BASEDIR}/crc32_simd.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o adler32.o ${BASEDIR}/adler32.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o compress.o ${BASEDIR}/compress.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o cpu_features.o ${BASEDIR}/cpu_features.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o crc32.o ${BASEDIR}/crc32.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o deflate.o ${BASEDIR}/deflate.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o gzclose.o ${BASEDIR}/gzclose.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o gzlib.o ${BASEDIR}/gzlib.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o gzread.o ${BASEDIR}/gzread.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o gzwrite.o ${BASEDIR}/gzwrite.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o infback.o ${BASEDIR}/infback.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o inffast.o ${BASEDIR}/inffast.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o inftrees.o ${BASEDIR}/inftrees.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o trees.o ${BASEDIR}/trees.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o uncompr.o ${BASEDIR}/uncompr.c
${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o zutil.o ${BASEDIR}/zutil.c
if test "$ARCH" = "x86_64"; then
  ${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o crc_folding.o ${BASEDIR}/crc_folding.c
  ${CC} -DCHROMIUM_ZLIB_NO_CHROMECONF -DINFLATE_CHUNK_READ_64LE -DUNALIGNED_OK ${FLAGS} -O3 -fPIC -I${BASEDIR} -I${BASEDIR}/contrib/optimizations -c -o fill_window_sse.o ${BASEDIR}/fill_window_sse.c
fi
${CC} -shared -o libz.so *.o -lc

if test "$ARCH" = "aarch64"; then
  git -C ../../zlib-chromium checkout .
fi

popd
