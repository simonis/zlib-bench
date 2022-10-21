#!/bin/bash

# (export PATH=$PATH:/share/software/vega-cli/node_modules/vega-lite/bin:/share/software/vega-cli/node_modules/vega-cli/bin)

CPU=${CPU:-"i7-8650U / 1900MHz"}
DIR=${DIR:-"i7-8650U-1900MHz-inflate-silesia-2020-09-16"}

java -cp build/benchmarks/ io.simonis.CreateVegaLiteGraph -legend "" -title "Inflater throughput for Silesia corpus (part1) at compression level 6 on $CPU" -template benchmarks/java/io/simonis/file-throughput-horizontal.json -sort "zlib,cloudflare,jtkukunas,ng,chromium,ipp,isal" -json graphs/$DIR/file-inflate-silesia-horizontal-part1.json -svg graphs/$DIR/file-inflate-silesia-horizontal-part1.svg -png graphs/$DIR/file-inflate-silesia-horizontal-part1.png -default-impl zlib -isal-level 6 results/$DIR/*dickens.json results/$DIR/*mozilla.json results/$DIR/*mr.json results/$DIR/*nci.json results/$DIR/*ooffice.json results/$DIR/*osdb.json

java -cp build/benchmarks/ io.simonis.CreateVegaLiteGraph -legend "" -title "Inflater throughput for Silesia corpus (part2) at compression level 6 on $CPU" -template benchmarks/java/io/simonis/file-throughput-horizontal.json -sort "zlib,cloudflare,jtkukunas,ng,chromium,ipp,isal" -json graphs/$DIR/file-inflate-silesia-horizontal-part2.json -svg graphs/$DIR/file-inflate-silesia-horizontal-part2.svg -png graphs/$DIR/file-inflate-silesia-horizontal-part2.png -default-impl zlib -isal-level 6  results/$DIR/*reymont.json results/$DIR/*samba.json results/$DIR/*sao.json results/$DIR/*webster.json results/$DIR/*xml.json results/$DIR/*x-ray.json
