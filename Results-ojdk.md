## Benchmark details

The following results were measured on a Laptop with an Intel i7-8650U CPU running Ubuntu 18.04 and on a m6g.xlarge EC2 instance with a Graviton 2 CPU running RHEL 8.2. On the laptop, hyperthreading and turbo-boost were switched off, the CPU frequency was set to a fixed value of 1900MHz and the benchmark was run in its own [cpuset](http://manpages.ubuntu.com/manpages/bionic/man1/cset-set.1.html) as root user (see [`benchmarks/bash/benchmark_start.sh`](benchmarks/bash/benchmark_start.sh)). 

### Java benchmarks on Intel i7-8650U

For the Java benchmarks I've used the program [`ZBench.java`](benchmarks/java/io/simonis/ZBench.java) (which is basically a Java version of the corresponding C benchmark [`zbench.c`](benchmarks/c/zbench.c)). To dispatch between the various implementations I've used the new `org.openjdk.zlib.implementation` system properties proposed by [JDK-1234567](). For details you can take a look at the the harness script [`run-java-deflate.sh`](benchmarks/bash/run-java-deflate.sh).

Like for the [native benchmarks](Results.md) I've measured deflation throughput (in kb/ms) and the compression ratio for each compression level from 1 to 9 for every file from the [Silesia text corpus](http://www.data-compression.info/Corpora/SilesiaCorpus/index.html).

The next graph shows the deflation throughput of the "`bundled zlib`", the "`system zlib`", "`zlib-cloudflare`" and "`zlib-chromium`" at the default compression level 6. Precompiled versions of "`zlib-cloudflare`" and "`zlib-chromium`" can be found in the [`lib/`](lib/) folder. The bundled "`zlib`"'s throughput is defined to be 100%. You can click on a graph to get a larger version.

| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/file-silesia-openjdk-horizontal-part1.svg) |
|-------|
| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/file-silesia-openjdk-horizontal-part2.svg) |

The following set of graphs shows the deflate throughput and compression ratio for each of the Silesia files depending on the compression level. Click on a graph for a larger version.

| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-dickens.svg) | ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-mozilla.svg) |
|-----|-----|
| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-mr.svg) | ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-nci.svg) |
| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-ooffice.svg) | ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-reymont.svg) |
| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-samba.svg) | ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-sao.svg) |
| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-webster.svg) | ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-xml.svg) |
| ![](graphs/i7-8650U-1900MHz-deflate-silesia-openjdk-2020-07-17/ratio-silesia-x-ray.svg) | ![]() |

And finally a comparison of the inflation throughput of the various versions. As input data for all implementations I took the original Silesia files compressed with the original "`zlib`" version at the default compression level 6.

| ![](graphs/i7-8650U-1900MHz-inflate-silesia-openjdk-2020-07-17/file-silesia-openjdk-horizontal-part1.svg) |
|-------|
| ![](graphs/i7-8650U-1900MHz-inflate-silesia-openjdk-2020-07-17/file-silesia-openjdk-horizontal-part2.svg) |

### Java benchmarks on Graviton 2

Following are to corresponding results measured on Linux/aarch64:

| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/file-silesia-openjdk-horizontal-part1.svg) |
|-------|
| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/file-silesia-openjdk-horizontal-part2.svg) |

| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-dickens.svg) | ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-mozilla.svg) |
|-----|-----|
| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-mr.svg) | ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-nci.svg) |
| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-ooffice.svg) | ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-reymont.svg) |
| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-samba.svg) | ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-sao.svg) |
| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-webster.svg) | ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-xml.svg) |
| ![](graphs/graviton2-deflate-silesia-openjdk-2020-07-20/ratio-silesia-x-ray.svg) | ![]() |

| ![](graphs/graviton2-inflate-silesia-openjdk-2020-07-20/file-silesia-openjdk-horizontal-part1.svg) |
|-------|
| ![](graphs/graviton2-inflate-silesia-openjdk-2020-07-20/file-silesia-openjdk-horizontal-part2.svg) |
