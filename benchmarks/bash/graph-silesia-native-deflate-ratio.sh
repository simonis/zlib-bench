#!/bin/bash

for file in dickens  mozilla  mr  nci  ooffice  reymont  samba  sao  webster  xml  x-ray; do
  java -cp build/benchmarks/ io.simonis.CreateVegaLiteGraph -legend "" -title "Deflater throughput/ratio per level for 'silesia/$file' on i7-8650U / 1900MHz" -template benchmarks/java/io/simonis/ratio-throughput.json -map "corretto-11-cf-ch-cf:Corretto 11 / zlib-cloudflare,corretto-11-cf-ch-system:Corretto 11 / system zlib" -sort "isal,ipp,cloudflare,ng,chromium,zlib" -json graphs/i7-8650U-1900MHz-deflate-silesia-2020-07-05/ratio-silesia-$file.json -sortRows "libjvm.so,imdb.js,BytecodeParser.class,BytecodeParser.java,imdb.html,imdb.css,amazon.html" -svg graphs/i7-8650U-1900MHz-deflate-silesia-2020-07-05/ratio-silesia-$file.svg -png graphs/i7-8650U-1900MHz-deflate-silesia-2020-07-05/ratio-silesia-$file.png -default-impl zlib -label-offset -83 results/i7-8650U-1900MHz-deflate-silesia-2020-07-05/*$file*.json
done
