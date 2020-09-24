#!/bin/bash

# (export PATH=$PATH:/share/software/vega-cli/node_modules/vega-lite/bin:/share/software/vega-cli/node_modules/vega-cli/bin)

CPU=${CPU:-"i7-8650U / 1900MHz"}
DIR=${DIR:-"i7-8650U-1900MHz-deflate-silesia-2020-09-16"}

for file in dickens mozilla mr nci ooffice osdb reymont samba sao webster xml x-ray; do
  java -cp build/benchmarks/ io.simonis.CreateVegaLiteGraph -legend "" -title "Deflater throughput/ratio per level for 'silesia/$file' on $CPU" -template benchmarks/java/io/simonis/ratio-throughput.json -sort "isal,ipp,cloudflare,jtkukunas,ng,chromium,zlib" -json graphs/$DIR/ratio-silesia-$file.json -sortRows "libjvm.so,imdb.js,BytecodeParser.class,BytecodeParser.java,imdb.html,imdb.css,amazon.html" -svg graphs/$DIR/ratio-silesia-$file.svg -png graphs/$DIR/ratio-silesia-$file.png -default-impl zlib -label-offset -83 results/$DIR/*$file*.json
done
