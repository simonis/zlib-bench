#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
NASM=${NASM:-nasm}
GAS=${GAS:-as}

ARCH=`uname -m`
if test "$ARCH" = "aarch64"; then
  AS=$GAS
  AS_FLAGS="-c"
  SUFFIX=".S"
else
  AS=$NASM
  AS_FLAGS="-f elf64 -DHAVE_AS_KNOWS_AVX512"
  SUFFIX=".asm"
fi

ISAL_DIR=../../isa-l/

IGZIP_C_FILES="adler32_base.c encode_df.c flatten_ll.c huff_codes.c hufftables_c.c "
IGZIP_C_FILES+="igzip_base.c igzip.c igzip_icf_base.c igzip_icf_body.c igzip_inflate.c "
if test "$ARCH" = "x86_64"; then
  IGZIP_ASM_FILES="adler32_avx2_4.asm adler32_sse.asm encode_df_04.asm encode_df_06.asm "
  IGZIP_ASM_FILES+="igzip_body.asm igzip_decode_block_stateless_01.asm "
  IGZIP_ASM_FILES+="igzip_decode_block_stateless_04.asm igzip_deflate_hash.asm igzip_finish.asm "
  IGZIP_ASM_FILES+="igzip_gen_icf_map_lh1_04.asm igzip_gen_icf_map_lh1_06.asm igzip_icf_body_h1_gr_bt.asm "
  IGZIP_ASM_FILES+="igzip_icf_finish.asm igzip_inflate_multibinary.asm igzip_multibinary.asm "
  IGZIP_ASM_FILES+="igzip_set_long_icf_fg_04.asm igzip_set_long_icf_fg_06.asm igzip_update_histogram_01.asm "
  IGZIP_ASM_FILES+="igzip_update_histogram_04.asm proc_heap.asm rfc1951_lookup.asm "
else
  IGZIP_C_FILES+="proc_heap_base.c aarch64/igzip_multibinary_aarch64_dispatcher.c "
  IGZIP_ASM_FILES="aarch64/igzip_inflate_multibinary_arm64.S aarch64/igzip_multibinary_arm64.S "
  IGZIP_ASM_FILES+="aarch64/igzip_isal_adler32_neon.S aarch64/igzip_deflate_body_aarch64.S "
  IGZIP_ASM_FILES+="aarch64/igzip_deflate_finish_aarch64.S aarch64/isal_deflate_icf_body_hash_hist.S "
  IGZIP_ASM_FILES+="aarch64/isal_deflate_icf_finish_hash_hist.S aarch64/igzip_set_long_icf_fg.S "
  IGZIP_ASM_FILES+="aarch64/encode_df.S aarch64/isal_update_histogram.S aarch64/gen_icf_map.S "
  IGZIP_ASM_FILES+="aarch64/igzip_deflate_hash_aarch64.S aarch64/igzip_decode_huffman_code_block_aarch64.S "
fi

CRC_C_FILES="crc_base.c "
if test "$ARCH" = "x86_64"; then
  CRC_ASM_FILES="crc16_t10dif_01.asm crc16_t10dif_by4.asm crc16_t10dif_copy_by4.asm "
  CRC_ASM_FILES+="crc32_gzip_refl_by8.asm crc32_ieee_01.asm crc32_ieee_by4.asm "
  CRC_ASM_FILES+="crc32_iscsi_00.asm crc32_iscsi_01.asm crc_multibinary.asm "
  CRC_ASM_FILES+="crc16_t10dif_02.asm crc16_t10dif_by16_10.asm crc16_t10dif_copy_by4_02.asm "
  CRC_ASM_FILES+="crc32_ieee_02.asm crc32_ieee_by16_10.asm crc32_iscsi_by16_10.asm "
  CRC_ASM_FILES+="crc32_gzip_refl_by8_02.asm crc32_gzip_refl_by16_10.asm "
else
  CRC_C_FILES+="aarch64/crc_aarch64_dispatcher.c"
  CRC_ASM_FILES="aarch64/crc_multibinary_arm.S aarch64/crc16_t10dif_pmull.S aarch64/crc16_t10dif_copy_pmull.S "
  CRC_ASM_FILES+="aarch64/crc32_ieee_norm_pmull.S aarch64/crc64_ecma_refl_pmull.S aarch64/crc64_ecma_norm_pmull.S "
  CRC_ASM_FILES+="aarch64/crc64_iso_refl_pmull.S aarch64/crc64_iso_norm_pmull.S aarch64/crc64_jones_refl_pmull.S "
  CRC_ASM_FILES+="aarch64/crc64_jones_norm_pmull.S aarch64/crc32_iscsi_refl_pmull.S aarch64/crc32_gzip_refl_pmull.S "
  CRC_ASM_FILES+="aarch64/crc32_iscsi_3crc_fold.S aarch64/crc32_gzip_refl_3crc_fold.S aarch64/crc32_iscsi_crc_ext.S "
  CRC_ASM_FILES+="aarch64/crc32_gzip_refl_crc_ext.S aarch64/crc32_mix_default.S aarch64/crc32c_mix_default.S "
  CRC_ASM_FILES+="aarch64/crc32_mix_neoverse_n1.S aarch64/crc32c_mix_neoverse_n1.S "
fi


rm -f *.o *.so

for FILE in $IGZIP_C_FILES; do
  $CC -Wall -O2 -I$ISAL_DIR/include -fPIC -c $ISAL_DIR/igzip/$FILE
done
for FILE in $CRC_C_FILES; do
  $CC -Wall -O2 -I$ISAL_DIR/include -fPIC -c $ISAL_DIR/crc/$FILE
done
for FILE in $IGZIP_ASM_FILES; do
  $AS $AS_FLAGS -I$ISAL_DIR/include/ -I$ISAL_DIR/igzip/ -o `basename $FILE $SUFFIX`.o $ISAL_DIR/igzip/$FILE
done
for FILE in $CRC_ASM_FILES; do
  $AS $AS_FLAGS -I$ISAL_DIR/include/ -o `basename $FILE $SUFFIX`.o $ISAL_DIR/crc/$FILE
done
$CC -shared -o libz-isal.so *.o -lc

popd
