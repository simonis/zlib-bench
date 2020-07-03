package io.simonis;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.zip.Deflater;
import java.util.zip.DeflaterOutputStream;
import java.util.zip.Inflater;
import java.util.zip.InflaterOutputStream;

public class ZBench {

    private static final int CHUNK = 16384;
    private static byte[] buf = new byte[CHUNK];

    static void def(InputStream in, OutputStream out, int comp_level) throws IOException {
        DeflaterOutputStream deflate = new DeflaterOutputStream(out, new Deflater(comp_level), CHUNK);
        int len;
        while ((len = in.read(buf)) != -1) {
            deflate.write(buf, 0, len);
        }
        deflate.finish();
    }

    static void inf(InputStream in, OutputStream out) throws IOException {
        InflaterOutputStream inflate = new InflaterOutputStream(out, new Inflater(), 8 * CHUNK);
        int len;
        while ((len = in.read(buf)) != -1) {
            inflate.write(buf, 0, len);
        }
        inflate.finish();
    }

    public static void main(String[] args) throws IOException {
        final int INFLATE = 1;
        final int DEFLATE = 2;
        long process = 0;
        int count = 0;
        int action = 0;
        int comp_level_start = -99;
        int comp_level_end = -99;
        int isal = 0;
        String json_file = null, zlib_kind = null;
        String in_file = null, out_file = null, file_name = null;
        String comp_file = null;
        FileOutputStream json = null;

        for (int i=0; i < args.length; i++) {
            if ("-i".equals(args[i])) {
                action |= INFLATE;
            }
            else if ("-d".equals(args[i])) {
                action |= DEFLATE;
            }
            else if ("-n".equals(args[i])) {
                assert(i + 1 < args.length);
                count = Integer.parseInt(args[++i]);
            }
            else if ("-p".equals(args[i])) {
                assert(i + 1 < args.length);
                process = Long.parseLong(args[++i]);
            }
            else if ("-c".equals(args[i])) {
                assert(i + 1 < args.length);
                if (comp_level_start == -99) {
                    comp_level_start = Integer.parseInt(args[++i]);
                  }
                  else {
                    comp_level_end = Integer.parseInt(args[++i]);
                  }
            }
            else if ("-a".equals(args[i])) {
                in_file = file_name = args[++i];
            }
            else if ("-b".equals(args[i])) {
                out_file = args[++i];
            }
            else if ("-z".equals(args[i])) {
                comp_file = args[++i];
            }
            else if ("-j".equals(args[i])) {
                json_file = zlib_kind = args[++i];
            }
            else if ("-l".equals(args[i])) {
                isal = 1;
            }
        }

        file_name = file_name.substring(file_name.lastIndexOf('/') + 1);
        file_name = file_name.replace('.', '-');
        if (json_file != null) {
            json = new FileOutputStream(json_file + "-" + file_name + ".json");
        }
        else {
            if (isal == 1) {
                zlib_kind = "isal";
            } else {
                zlib_kind = "zlib";
            }
        }
        if ((comp_file != null) && (action & DEFLATE) != 0) {
          // Check to prevent 'comp_file' from being overwritten
          System.err.printf("The '-z' option shouldn't be used with '-d'\n");
          System.exit(0);
        }
        if (count == 0 && process == 0) {
            process = 100_000_000L;
        }
        if (comp_level_start == -99) {
            if (isal == 1) {
                /*
                 * For isal, the compression levels run from ISAL_DEF_MIN_LEVEL (i.e. 0) to
                 * ISAL_DEF_MAX_LEVEL (i.e. 3). There is no "no-compression" level like in zlib
                 * (see below)
                 */
                comp_level_start = 0 /* ISAL_DEF_MIN_LEVEL */;
            } else {
                /*
                 * For zlib, compression levels go from Z_BEST_SPEED (i.e. 1) to
                 * Z_BEST_COMPRESSION (i.e. 9) with Z_DEFAULT_COMPRESSION == 6 Z_NO_COMPRESSION
                 * == 0
                 */
                comp_level_start = 6 /* Z_DEFAULT_COMPRESSION */;
            }
        }
        if (isal == 1 && comp_level_start > 3) {
            System.err.printf("Compression level %d not supported by ISAL. Reset to 3 (i.e. ISAL_DEF_MAX_LEVEL)\n", comp_level_start);
            comp_level_start = 3;
        }
        if (isal == 1 && comp_level_end > 3) {
            System.err.printf("Compression level %d not supported by ISAL. Reset to 3 (i.e. ISAL_DEF_MAX_LEVEL)\n", comp_level_start);
            comp_level_end = 3;
        }
        if (comp_level_end == -99 || comp_level_end < comp_level_start) {
            comp_level_end = comp_level_start;
        }

        String tmpdir = System.getProperty("java.io.tmpdir");
        Path inflated = Paths.get(tmpdir, "ZBench_inflated.tmp");
        inflated.toFile().createNewFile();
        Path deflated = Paths.get(tmpdir, "ZBench_deflated.tmp");
        deflated.toFile().createNewFile();

        FileInputStream def_in = new FileInputStream(deflated.toFile());
        FileOutputStream def_out = new FileOutputStream(deflated.toFile());
        FileInputStream inf_in = new FileInputStream(inflated.toFile());
        FileOutputStream inf_out = new FileOutputStream(inflated.toFile());
        FileInputStream in = new FileInputStream(in_file);
        FileOutputStream out = new FileOutputStream(out_file);
        long in_size = 0, out_size = 0;
        // Compress from input file to temp file
        def(in, def_out, Deflater.DEFAULT_COMPRESSION);
        in.getChannel().position(0);
        def_out.getChannel().position(0);
        long amount = 0;
        int j = 0;
        // Warmup
        while (true) {
            inf(def_in, inf_out);
            if (j == 0) {
                in_size = inf_out.getChannel().position();
                out_size = def_in.getChannel().position();
                assert(in_size == inf_out.getChannel().size());
                assert(out_size == def_in.getChannel().size());
                System.err.printf("Original file size: %d\nCompressed file size: %d\n", in_size, out_size);
            }
            def_in.getChannel().position(0);
            inf_out.getChannel().position(0);
            // Warmup all levels
            def(inf_in, def_out, j % 10);
            inf_in.getChannel().position(0);
            def_out.getChannel().position(0);
            amount+= in_size;
            if (amount > 1_000_000_000L || j++ > 5000) break;
        }
        def_in.close();
        def_out.close();
        inf_in.close();
        inf_out.close();

        while (comp_level_start <= comp_level_end) {
            if (comp_level_start == -1) {
              // Same as 6 so skip
              comp_level_start++;
              continue;
            }
            if (comp_level_start == 0 && !"isal".equals(zlib_kind)) {
              // For isal, '0'  is the lowest compression level, for zlib
              // '0' means 'no compression' so we ignore it.
              comp_level_start++;
              continue;
            }

            inflated = Paths.get(tmpdir, "ZBench_inflated_" + comp_level_start + ".tmp");
            inflated.toFile().createNewFile();
            if (comp_file == null) {
              deflated = Paths.get(tmpdir, in_file.substring(in_file.lastIndexOf('/') + 1) + ".zip");
              deflated.toFile().createNewFile();
            }
            else {
              // The user provided a compresed file, so use that one (and don't change it)
              deflated = Paths.get(comp_file);
            }

            def_in = new FileInputStream(deflated.toFile());
            def_out = new FileOutputStream(deflated.toFile(), comp_file != null /* append mode to prevent overwriting 'comp_file' */);
            inf_in = new FileInputStream(inflated.toFile());
            inf_out = new FileOutputStream(inflated.toFile());

            if (comp_file == null) {
              def(in, def_out, comp_level_start);
              in.getChannel().position(0);
              def_out.getChannel().position(0);
            }

            inf(def_in, inf_out);
            in_size = inf_out.getChannel().size();
            out_size = def_in.getChannel().size();
            def_in.getChannel().position(0);
            inf_out.getChannel().position(0);

            for (int i = 0; i < count; i++) {
                int counter = 0;
                long processed = 0;
                System.gc();
                long start = System.nanoTime();
                while (true) {
                    if ((action & DEFLATE) != 0) {
                        def(inf_in, def_out, comp_level_start);
                        inf_in.getChannel().position(0);
                        def_out.getChannel().position(0);
                        processed += in_size;
                    }
                    if ((action & INFLATE) != 0) {
                        inf(def_in, inf_out);
                        def_in.getChannel().position(0);
                        inf_out.getChannel().position(0);
                        processed += out_size;
                    }
                    counter++;
                    if (processed > process) break;
                }
                long stop = System.nanoTime();
                long run_time_ms = (stop - start) / 1000000;
                double comp_rate = ((double)out_size * 100) / in_size;
                double comp_ratio = (double)in_size / out_size;
                double throughput = (processed / run_time_ms) / 1024.0;

                System.err.printf("%s-%d: %d times %s required %,d ms (compression rate %.2f%% (%.2f), troughput %.2f kb/ms)\n",
                                  zlib_kind, comp_level_start, counter,
                                  (((action & DEFLATE) != 0) && ((action & INFLATE) != 0) ?
                                      "DEFLATE/INFLATE" :
                                      (((action & DEFLATE) != 0) ?
                                          "DEFLATE" :
                                          (((action & INFLATE) != 0) ?
                                              "INFLATE" :
                                              "ERROR"))), run_time_ms, comp_rate, comp_ratio, throughput);
                if (json != null) {
                    new PrintStream(json).printf("{\"level\": \"%d\", \"type\": \"%s\", \"ratio\": \"%.2f\", \"throughput\": \"%.2f\", \"file\": \"%s\"},\n",
                                                 comp_level_start, zlib_kind, comp_ratio, throughput, file_name);
                }
            }
            inf(def_in, out);
            def_in.close();
            def_out.close();
            inf_in.close();
            inf_out.close();
            comp_level_start++;
        }
        in.close();
        out.close();
        if (json != null) json.close();
    }
}
