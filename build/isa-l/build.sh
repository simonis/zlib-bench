#!/bin/bash
MYDIR=`dirname $0`
pushd $MYDIR
CC=${CC:-gcc}
NASM=${NASM:-nasm}
ISAL_DIR=../../isa-l/
IGZIP_C_FILES="adler32_base.c encode_df.c flatten_ll.c huff_codes.c hufftables_c.c "
IGZIP_C_FILES+="igzip_base.c igzip.c igzip_icf_base.c igzip_icf_body.c igzip_inflate.c"
IGZIP_NASM_FILES="adler32_avx2_4.asm adler32_sse.asm encode_df_04.asm encode_df_06.asm "
IGZIP_NASM_FILES+="igzip_body.asm igzip_decode_block_stateless_01.asm "
IGZIP_NASM_FILES+="igzip_decode_block_stateless_04.asm igzip_deflate_hash.asm igzip_finish.asm "
IGZIP_NASM_FILES+="igzip_gen_icf_map_lh1_04.asm igzip_gen_icf_map_lh1_06.asm igzip_icf_body_h1_gr_bt.asm "
IGZIP_NASM_FILES+="igzip_icf_finish.asm igzip_inflate_multibinary.asm igzip_multibinary.asm "
IGZIP_NASM_FILES+="igzip_set_long_icf_fg_04.asm igzip_set_long_icf_fg_06.asm igzip_update_histogram_01.asm "
IGZIP_NASM_FILES+="igzip_update_histogram_04.asm proc_heap.asm rfc1951_lookup.asm"
CRC_C_FILES="crc_base.c"
CRC_NASM_FILES="crc16_t10dif_01.asm crc16_t10dif_by4.asm crc16_t10dif_copy_by4.asm "
CRC_NASM_FILES+="crc32_gzip_refl_by8.asm crc32_ieee_01.asm crc32_ieee_by4.asm "
CRC_NASM_FILES+="crc32_iscsi_00.asm crc32_iscsi_01.asm crc_multibinary.asm"

rm -f *.o *.so

for FILE in $IGZIP_C_FILES; do
  $CC -Wall -O2 -I$ISAL_DIR/include -fPIC -c $ISAL_DIR/igzip/$FILE
done
for FILE in $CRC_C_FILES; do
  $CC -Wall -O2 -I$ISAL_DIR/include -fPIC -c $ISAL_DIR/crc/$FILE
done
for FILE in $IGZIP_NASM_FILES; do
  $NASM -f elf64 -DHAVE_AS_KNOWS_AVX512 -I$ISAL_DIR/include/ -I$ISAL_DIR/igzip/ -o `basename $FILE .asm`.o $ISAL_DIR/igzip/$FILE
done
for FILE in $CRC_NASM_FILES; do
  $NASM -f elf64 -DHAVE_AS_KNOWS_AVX512 -I$ISAL_DIR/include/ -o `basename $FILE .asm`.o $ISAL_DIR/crc/$FILE
done
$CC -shared -o libz-isal.so *.o -lc

popd
