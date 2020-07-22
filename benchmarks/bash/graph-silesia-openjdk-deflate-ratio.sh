#!/bin/bash

CPU=${CPU:-"i7-8650U / 1900MHz"}
DIR=${DIR:-"i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17"}

for file in dickens  mozilla  mr  nci  ooffice  reymont  samba  sao  webster  xml  x-ray; do
  java -cp build/benchmarks/ io.simonis.CreateVegaLiteGraph -legend "" -title "Deflater throughput/ratio per level for 'silesia/$file' on $CPU" -template benchmarks/java/io/simonis/ratio-throughput.json -map "openjdk-bundled:ojdk / zlib-bundled,openjdk-system:ojdk / zlib-system,openjdk-cloudflare:ojdk / zlib-cloudflare,openjdk-chromium:ojdk / zlib-chromium" -sort "ojdk / zlib-cloudflare,ojdk / zlib-chromium,ojdk / zlib-system,ojdk / zlib-bundled" -sortRows "" -json graphs/$DIR/ratio-silesia-$file.json -svg graphs/$DIR/ratio-silesia-$file.svg -png graphs/$DIR/ratio-silesia-$file.png -default-impl openjdk-bundled -label-offset -136 results/$DIR/*$file*.json
done
