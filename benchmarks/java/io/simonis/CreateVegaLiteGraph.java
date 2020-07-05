package io.simonis;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Scanner;
import java.util.StringJoiner;
import java.util.stream.Collectors;

public class CreateVegaLiteGraph {

    public static void main(String[] args) throws IOException {
        String title = null, legend = "Deflater library", template = null;
        FileOutputStream json_file = null;
        String default_impl = null, default_level = "6", isal_level = "3";
        String label_offset = "0";
        String json_file_name = null, svg_file_name = null, png_file_name = null;
        List<Path> data_files = new ArrayList<>();
        HashMap<String, String> user_map = new HashMap<>();
        String user_label_sort = null;
        String user_row_sort = null;
        for (int i=0; i < args.length; i++) {
            if ("-title".equals(args[i])) {
                assert(i + 1 < args.length);
                title = args[++i];
            }
            else if ("-legend".equals(args[i])) {
                assert(i + 1 < args.length);
                legend = args[++i];
            }
            else if ("-template".equals(args[i])) {
                assert(i + 1 < args.length);
                template = Files.readString(Paths.get(args[++i]));
            }
            else if ("-map".equals(args[i])) {
                assert(i + 1 < args.length);
                String[] entries = args[++i].split(", *");
                for (String entry : entries) {
                    String[] key_val = entry.split(":");
                    assert(key_val.length == 2);
                    user_map.put(key_val[0], key_val[1]);
                }
            }
            else if ("-sort".equals(args[i])) {
                assert(i + 1 < args.length);
                String[] entries = args[++i].split(", *");
                StringJoiner sj = new StringJoiner(", ");
                for (String entry : entries) {
                    sj.add("\"" + entry + "\"");
                }
                user_label_sort = sj.toString();
            }
            else if ("-sortRows".equals(args[i])) {
                assert(i + 1 < args.length);
                String[] entries = args[++i].split(", *");
                StringJoiner sj = new StringJoiner(", ");
                for (String entry : entries) {
                    sj.add("\"" + entry + "\"");
                }
                user_row_sort = sj.toString();
            }
            else if ("-label-offset".equals(args[i])) {
                assert(i + 1 < args.length);
                label_offset = args[++i];
            }
            else if ("-default-impl".equals(args[i])) {
                assert(i + 1 < args.length);
                default_impl = args[++i];
            }
            else if ("-default-level".equals(args[i])) {
                assert(i + 1 < args.length);
                default_level = args[++i];
            }
            else if ("-isal-level".equals(args[i])) {
                assert(i + 1 < args.length);
                isal_level = args[++i];
            }
            else if ("-json".equals(args[i])) {
                assert(i + 1 < args.length);
                json_file_name = args[++i];
                json_file = new FileOutputStream(json_file_name);
            }
            else if ("-svg".equals(args[i])) {
                assert(i + 1 < args.length);
                svg_file_name = args[++i];
            }
            else if ("-png".equals(args[i])) {
                assert(i + 1 < args.length);
                png_file_name = args[++i];
            }
            else if (args[i].startsWith("-")) {
                // Unknown option, exit..
                System.err.println("Unknown option \"" + args[i] + "\"");
                System.exit(-1);
            }
            else {
                // All other arguments ar esupposed to be the data files
                data_files.add(Paths.get(args[i]));
            }
        }
        // Get data
        StringBuffer dataBuffer = new StringBuffer();
        for (Path p : data_files) {
            dataBuffer.append(Files.readString(p));
        }
        String data = dataBuffer.substring(0, dataBuffer.length() - 2); // remove last ',' from last data set
        data = data.replaceAll("(, \"file\": \".+)-([^-\"]+\"})", "$1.$2");

        // Get benchmark "types" and map/sort them
        StringJoiner type_map = new StringJoiner(",\n");
        StringJoiner label_sort = new StringJoiner(", ");
        List<String> types = new ArrayList<>();
        Scanner type_scanner = new Scanner(data);
        type_scanner.findAll(", \"type\": \"([^\"]+)\",").map(r -> r.group(1)).distinct().forEach(t -> types.add(t));
        for (String type : types) {
            String new_type = user_map.containsKey(type) ? user_map.get(type) : type;
            label_sort.add("\"" + new_type + "\"");
            type_map.add("{\"type\": \"" + type + "\", \"new-type\": \"" + new_type + "\"}");
        }
        if (user_label_sort == null) {
            user_label_sort = label_sort.toString();
        }
        // Compute the mean for the default implementation for each file. Didn't manage to do this in Vega Lite such
        // that it gets propagated to all datasets of the same file.
        if (default_impl == null) {
            System.err.println("WARNING: default type not given.");
            System.err.println("  assuming \"" + types.get(0) + "\" from " + types);
            default_impl = types.get(0);
        }
        StringJoiner default_data = new StringJoiner(",\n");
        String pattern = ".+\"level\": \"([0-9]+)\".+\"type\": \"" +
            default_impl + "\".+\"throughput\": \"(.+)\".+\"file\": \"(.+)\".+";
        Scanner default_scanner = new Scanner(data);
        final String level = default_level;
        default_scanner.findAll(pattern).
            filter(r -> level.equals(r.group(1))).
            map(r -> List.of(r.group(1), r.group(2), r.group(3))).
            collect(Collectors.groupingBy(l -> l.get(2), Collectors.averagingDouble(m -> Double.parseDouble(m.get(1))))).
            entrySet().
            stream().
            forEach(e -> default_data.add("{\"file\": \"" + e.getKey() + "\", \"default_val\": \"" + e.getValue() + "\"}"));

        // Get the different data files
        StringJoiner file_sort = new StringJoiner(", ");
        List<String> files = new ArrayList<>();
        Scanner file_scanner = new Scanner(data);
        file_scanner.findAll(", \"file\": \"([^\"]+)\"}").map(r -> r.group(1)).distinct().forEach(t -> files.add(t));
        for (String file : files) {
            file_sort.add("\"" + file + "\"");
        }
        if (user_row_sort == null) {
            user_row_sort = file_sort.toString();
        }

        String json = template.replaceFirst("__TITLE__", title);
        json = json.replaceFirst("__LEGEND__", legend);
        json = json.replaceFirst("__DATA__", data);
        json = json.replaceFirst("__ISAL_LEVEL__", isal_level);
        json = json.replaceFirst("__DEFAULT_LEVEL__", default_level);
        json = json.replaceFirst("__TYPE_MAP__", type_map.toString());
        json = json.replaceFirst("__DEFAULT_DATA__", default_data.toString());
        json = json.replace("__LABEL_ORDER__", user_label_sort);
        json = json.replace("__LABEL_OFFSET__", label_offset);
        json = json.replaceFirst("__ROW_ORDER__", user_row_sort);

        json_file.write(json.getBytes());
        json_file.close();

        if (svg_file_name != null) {
            ProcessBuilder vl2vg = new ProcessBuilder("vl2vg");
            vl2vg.redirectInput(new File(json_file_name));
            ProcessBuilder vg2svg = new ProcessBuilder("vg2svg", "-s", "2");
            vg2svg.redirectOutput(new File(svg_file_name));
            ProcessBuilder.startPipeline(List.of(vl2vg, vg2svg));
        }
        if (png_file_name != null) {
            ProcessBuilder vl2vg = new ProcessBuilder("vl2vg");
            vl2vg.redirectInput(new File(json_file_name));
            ProcessBuilder vg2png = new ProcessBuilder("vg2png", "-s", "2");
            vg2png.redirectOutput(new File(png_file_name));
            ProcessBuilder.startPipeline(List.of(vl2vg, vg2png));
        }
    }
}
