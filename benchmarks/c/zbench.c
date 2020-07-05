/* Adapted from zpip.c to create a simple benchmark for comparing
   the original zlib performance with that of an IPP (Intel
   Performance Primitives) enhanced version of zlib. */

/* zpipe.c: example of proper use of zlib's inflate() and deflate()
   Not copyrighted -- provided to the public domain
   Version 1.4  11 December 2005  Mark Adler */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <locale.h>
#include "zlib.h"
#include "igzip_lib.h"

#define CHUNK 16384

/* Compress from file source to file dest until EOF on source.
   def() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_STREAM_ERROR if an invalid compression
   level is supplied, Z_VERSION_ERROR if the version of zlib.h and the
   version of the library linked do not match, or Z_ERRNO if there is
   an error reading or writing the files. */
int def(FILE *source, FILE *dest, int level)
{
    int ret, flush;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];

    /* allocate deflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    ret = deflateInit(&strm, level);
    if (ret != Z_OK)
        return ret;

    /* compress until end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            (void)deflateEnd(&strm);
            return Z_ERRNO;
        }
        flush = feof(source) ? Z_FINISH : Z_NO_FLUSH;
        strm.next_in = in;

        /* run deflate() on input until output buffer not full, finish
           compression if all of source has been read in */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = deflate(&strm, flush);    /* no bad return value */
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                (void)deflateEnd(&strm);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */

        /* done when last data in file processed */
    } while (flush != Z_FINISH);
    assert(ret == Z_STREAM_END);        /* stream will be complete */

    /* clean up and return */
    (void)deflateEnd(&strm);
    return Z_OK;
}

int level_size_buf[ISAL_DEF_MAX_LEVEL + 1] = {
	ISAL_DEF_LVL0_DEFAULT,
	ISAL_DEF_LVL1_DEFAULT,
	ISAL_DEF_LVL2_DEFAULT,
	ISAL_DEF_LVL3_DEFAULT
};

/* Compress from file source to file dest until EOF on source.
   def() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_STREAM_ERROR if an invalid compression
   level is supplied, Z_VERSION_ERROR if the version of zlib.h and the
   version of the library linked do not match, or Z_ERRNO if there is
   an error reading or writing the files. */
int isal_def(FILE *source, FILE *dest, int level)
{
    int ret, flush;
    unsigned have;
    struct isal_zstream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];

    if (level > ISAL_DEF_MAX_LEVEL || level < ISAL_DEF_MIN_LEVEL) {
        return ISAL_INVALID_LEVEL;
    }
    /* allocate deflate state */
    isal_deflate_init(&strm);
    strm.level = level;
    strm.flush = NO_FLUSH;
    strm.gzip_flag = IGZIP_ZLIB;

    if (level > ISAL_DEF_MIN_LEVEL) {
        strm.level_buf_size = level_size_buf[level];
        strm.level_buf = malloc(strm.level_buf_size);
    }

    /* compress until end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            free(strm.level_buf);
            return Z_ERRNO;
        }
        strm.end_of_stream = feof(source) ? 1 : 0;
        strm.next_in = in;

        /* run deflate() on input until output buffer not full, finish
           compression if all of source has been read in */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = isal_deflate(&strm);  /* no bad return value */
            assert(ret == COMP_OK);     /* state not clobbered */
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                free(strm.level_buf);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */

        /* done when last data in file processed */
    } while (strm.internal_state.state != ZSTATE_END);
    free(strm.level_buf);

    return Z_OK;
}

/* Decompress from file source to file dest until stream ends or EOF.
   inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_DATA_ERROR if the deflate data is
   invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
   the version of the library linked do not match, or Z_ERRNO if there
   is an error reading or writing the files. */
int inf(FILE *source, FILE *dest)
{
    int ret;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];

    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK)
        return ret;

    /* decompress until deflate stream ends or end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            (void)inflateEnd(&strm);
            return Z_ERRNO;
        }
        if (strm.avail_in == 0)
            break;
        strm.next_in = in;

        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = inflate(&strm, Z_NO_FLUSH);
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            switch (ret) {
            case Z_NEED_DICT:
                ret = Z_DATA_ERROR;     /* and fall through */
            case Z_DATA_ERROR:
            case Z_MEM_ERROR:
                (void)inflateEnd(&strm);
                return ret;
            }
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                (void)inflateEnd(&strm);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);

        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);

    /* clean up and return */
    (void)inflateEnd(&strm);
    return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
}

/* Decompress from file source to file dest until stream ends or EOF.
   inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_DATA_ERROR if the deflate data is
   invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
   the version of the library linked do not match, or Z_ERRNO if there
   is an error reading or writing the files. */
int isal_inf(FILE *source, FILE *dest)
{
    int ret;
    unsigned have;
    struct inflate_state strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];

    /* allocate inflate state */
    isal_inflate_init(&strm);
    strm.crc_flag = ISAL_ZLIB;

    /* decompress until deflate stream ends or end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            return Z_ERRNO;
        }
        if (strm.avail_in == 0)
            break;
        strm.next_in = in;

        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = isal_inflate(&strm);
            assert(ret == ISAL_DECOMP_OK || ret == ISAL_END_INPUT);  /* state not clobbered */
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);

        /* done when inflate() says it's done */
    } while (ret != ISAL_END_INPUT);

    /* clean up and return */
    return (ret == ISAL_END_INPUT || ret == ISAL_DECOMP_OK) ? Z_OK : Z_ERRNO;
}

/* report a zlib or i/o error */
void zerr(int ret)
{
    fputs("zpipe: ", stderr);
    switch (ret) {
    case Z_ERRNO:
        if (ferror(stdin))
            fputs("error reading stdin\n", stderr);
        if (ferror(stdout))
            fputs("error writing stdout\n", stderr);
        break;
    case Z_STREAM_ERROR:
        fputs("invalid compression level\n", stderr);
        break;
    case Z_DATA_ERROR:
        fputs("invalid or incomplete deflate data\n", stderr);
        break;
    case Z_MEM_ERROR:
        fputs("out of memory\n", stderr);
        break;
    case Z_VERSION_ERROR:
        fputs("zlib version mismatch!\n", stderr);
    }
}

#define NANO_SCALE 1000000000
static int clock_id = CLOCK_MONOTONIC;

static inline long long get_time(void) {
	struct timespec time;
	long long nano_total;
	 clock_gettime(clock_id, &time);
	 nano_total = time.tv_sec;
	 nano_total *= NANO_SCALE;
	 nano_total += time.tv_nsec;
	 return nano_total;
}

static inline long long get_res(void) {
	struct timespec time;
	long long nano_total;
	clock_getres(clock_id, &time);
	nano_total = time.tv_sec;
	nano_total *= NANO_SCALE;
	nano_total += time.tv_nsec;
	return nano_total;
}

void init_clock() {
  char *clock_name;
  switch (clock_id) {
  case CLOCK_REALTIME:
    clock_name = "CLOCK_REALTIME";
    break;
  case CLOCK_MONOTONIC:
    clock_name = "CLOCK_MONOTONIC";
    break;
  case CLOCK_PROCESS_CPUTIME_ID:
    clock_name = "CLOCK_PROCESS_CPUTIME_ID";
    break;
  case CLOCK_THREAD_CPUTIME_ID:
    clock_name = "CLOCK_THREAD_CPUTIME_ID";
    break;
  case CLOCK_MONOTONIC_RAW:
    clock_name = "CLOCK_MONOTONIC_RAW";
    break;
  case CLOCK_REALTIME_COARSE:
    clock_name = "CLOCK_REALTIME_COARSE";
    break;
  case CLOCK_MONOTONIC_COARSE:
    clock_name = "CLOCK_MONOTONIC_COARSE";
    break;
  }
  fprintf(stderr, "Clock resolution is %lldns using the %s clock\n", get_res(), clock_name);
}

#define INFLATE 1
#define DEFLATE 2

int count = 3;
long process = 100000000L;
int action = 0;
int isal = 0;
int comp_level_start = -99;
int comp_level_end = -99;
char *dir = "/tmp";
FILE *in, *out, *json = NULL;
char *zlib_kind, *file_name, *comp_file = NULL;

void parse_args(int argc, char **argv) {
  int opt;
  char *in_file, *out_file, *json_file = NULL;
  while ((opt = getopt(argc, argv, "n:t:dir:lc:p:a:b:z:j:")) != -1) {
    switch (opt) {
    case 'a':
      in_file = optarg;
      file_name = optarg;
      break;
    case 'b':
      out_file = optarg;
      break;
    case 'z':
      comp_file = optarg;
      break;
    case 'j':
      json_file = optarg;
      zlib_kind = optarg;
      break;
    case 'i':
      action |= INFLATE;
      break;
    case 'd':
      action |= DEFLATE;
      break;
    case 'n':
      count = atoi(optarg);
      break;
    case 'p':
      process = atol(optarg);
      break;
    case 'r':
      clock_id = atoi(optarg);
      break;
    case 'c':
      if (comp_level_start == -99) {
        comp_level_start = atoi(optarg);
      }
      else {
        comp_level_end = atoi(optarg);
      }
      break;
    case 't':
      dir = optarg;
      break;
    case 'l':
      isal = 1;
      break;
    default: /* '?' */
      fprintf(stderr, "Usage: zbench [-t tmp file directory (defaults to '/tmp')]\n"
                      "                (will contain the temporary deflated/inflated files\n"
                      "                 'zbench_deflated.tmp' and 'zbench_inflated.tmp')\n");
      fprintf(stderr, "              [-d] (deflate)\n");
      fprintf(stderr, "              [-i] (inflate)\n"
                      "                (without '-d' and '-i' the default is to deflate and inflate)\n");
      fprintf(stderr, "              [-n number of inflate/deflate runs] # (defaults to 3)\n");
      fprintf(stderr, "              [-p number of bytes to inflate/deflate in a run]\n"
                      "                (defaults to 100.000.000)\n");
      fprintf(stderr, "              [-c compression level]\n"
                      "                (defaults to 6 (Z_DEFAULT_COMPRESSION) for libz,\n"
                      "                 defaults to 0 (ISAL_DEF_MIN_LEVEL) for isa,\n"
                      "                 two '-c' will trigger measurement for all compression\n"
                      "                 levels in that range)\n");
      fprintf(stderr, "              [-l] (use isal library - default is zlib)\n");
      fprintf(stderr, "              [-j <name>]\n"
                      "                (writes '<name>-<infile>.json' results with 'type':'<name>' attribute)\n");
      fprintf(stderr, "              [-r clock used by clock_gettime()]\n"
                      "                (defaults to 1 (CLOCK_MONOTONIC)\n");
      fprintf(stderr, "              -a <infile>\n");
      fprintf(stderr, "              -b <outfile>\n");
      fprintf(stderr, "              -z <compressed file>\n");
      exit(EXIT_FAILURE);
    }
  }
  if ((in = fopen(in_file, "r")) == NULL) {
    fprintf(stderr, "%s: Can't open %s\n", strerror(errno), in_file);
    exit(EXIT_FAILURE);
  }
  if ((out = fopen(out_file, "w+")) == NULL) {
    fprintf(stderr, "%s: Can't open %s\n", strerror(errno), out_file);
    exit(EXIT_FAILURE);
  }
  if (strrchr(file_name, '/')) {
    file_name = strrchr(file_name, '/') + 1;
    char *pos = strchr(file_name, '.');
    if (pos) {
      *pos = '-';
    }
  }
  if (json_file != NULL) {
    char buf[FILENAME_MAX];
    snprintf(buf, FILENAME_MAX, "%s-%s.json", json_file, file_name);
    if ((json = fopen(buf, "w+")) == NULL) {
      fprintf(stderr, "%s: Can't open %s\n", strerror(errno), buf);
      exit(EXIT_FAILURE);
    }
  }
  else {
    if (isal) {
      zlib_kind = "isal";
    }
    else {
      zlib_kind = "zlib";
    }
  }
  if (action == 0) {
    action |= INFLATE | DEFLATE;
  }
  if ((comp_file != NULL) && (action & DEFLATE) != 0) {
    // Check to prevent 'comp_file' from being overwritten
    fprintf(stderr, "The '-z' option shouldn't be used with '-d'\n");
    exit(EXIT_FAILURE);
  }
  if (comp_level_start == -99) {
    if (isal) {
      /* For isal, the compression levels run from ISAL_DEF_MIN_LEVEL (i.e. 0)
         to ISAL_DEF_MAX_LEVEL (i.e. 3). There is no "no-compression" level
         like in zlib (see below) */
      comp_level_start = ISAL_DEF_MIN_LEVEL;
    } else {
      /* For zlib, compression levels go from Z_BEST_SPEED (i.e. 1) to
         Z_BEST_COMPRESSION (i.e. 9) with Z_DEFAULT_COMPRESSION == 6
         Z_NO_COMPRESSION == 0 */
      comp_level_start = Z_DEFAULT_COMPRESSION;
    }
  }
  if (isal && comp_level_start > 3) {
    fprintf(stderr, "Compression level %d not supported by ISAL. Reset to 3 (i.e. ISAL_DEF_MAX_LEVEL)\n", comp_level_start);
    comp_level_start = 3;
  }
  if (isal && comp_level_end > 3) {
    fprintf(stderr, "Compression level %d not supported by ISAL. Reset to 3 (i.e. ISAL_DEF_MAX_LEVEL)\n", comp_level_start);
    comp_level_end = 3;
  }
  if (comp_level_end == -99 || comp_level_end < comp_level_start) {
    comp_level_end = comp_level_start;
  }
}

void deflate_wrapper(FILE *inflated, FILE *deflated, int comp_level) {
  int ret;
  rewind(inflated);
  rewind(deflated);
  if (isal) {
    ret = isal_def(inflated, deflated, comp_level_start);
  } else {
    ret = def(inflated, deflated, comp_level_start);
  }
  if (ret != Z_OK) {
    zerr(ret);
  }
}

void inflate_wrapper(FILE *deflated, FILE *inflated) {
  int ret;
  rewind(inflated);
  rewind(deflated);
  if (isal) {
    ret = isal_inf(deflated, inflated);
  } else {
    ret = inf(deflated, inflated);
  }
  if (ret != Z_OK) {
    zerr(ret);
  }
}

int main(int argc, char **argv) {
  uint64_t in_size, out_size;
  FILE *inflated, *deflated;

  parse_args(argc, argv);
  init_clock();

  while (comp_level_start <= comp_level_end) {
    if (comp_level_start == -1) {
      // Same as 6 so skip
      comp_level_start++;
      continue;
    }
    if (comp_level_start == 0 && strcmp("isal", zlib_kind)) {
      // For isal, '0'  is the lowest compression level, for zlib
      // '0' means 'no compression' so we ignore it.
      comp_level_start++;
      continue;
    }
    char buf[FILENAME_MAX];
    snprintf(buf, FILENAME_MAX, "%s/zbench_inflated_%d.tmp", dir, comp_level_start);
    if ((inflated = fopen(buf, "w+")) == NULL) {
      fprintf(stderr, "%s: Can't open %s\n", strerror(errno), buf);
      exit(EXIT_FAILURE);
    }
    if (comp_file == NULL) {
      snprintf(buf, FILENAME_MAX, "%s/zbench_deflated_%d.tmp", dir, comp_level_start);
    }
    else {
      snprintf(buf, FILENAME_MAX, "%s", comp_file);
    }
    if ((deflated = fopen(buf, comp_file == NULL ? "w+" : "r")) == NULL) {
      fprintf(stderr, "%s: Can't open %s\n", strerror(errno), buf);
      exit(EXIT_FAILURE);
    }

    if (comp_file == NULL) {
      deflate_wrapper(in, deflated, comp_level_start);
    }
    inflate_wrapper(deflated, inflated);
    in_size = ftell(inflated);
    out_size = ftell(deflated);

    for (int i = 0; i < count; i++) {
      int counter = 0;
      long processed = 0;
      long long start = get_time();
      while (1) {
        if (action & DEFLATE) {
          deflate_wrapper(inflated, deflated, comp_level_start);
          processed += in_size;
        }
        if (action & INFLATE) {
          inflate_wrapper(deflated, inflated);
          processed += out_size;
        }
        counter++;
        if (processed > process)
          break;
      }
      long long stop = get_time();

      long run_time_ms = (stop - start) / 1000000;
      double comp_rate = ((double)out_size * 100) / in_size;
      double comp_ratio = (double)in_size / out_size;
      double throughput = (processed / run_time_ms) / 1024.0;
      // setlocale(LC_ALL, "");
      fprintf(
          stderr,
          "%s-%d: %d times %s required %'ld ms (compression rate %.2f%% (%.2f) "
          "troughput %.2f kb/ms)\n",
          zlib_kind, comp_level_start, counter,
          (action & DEFLATE && action & INFLATE
               ? "DEFLATE/INFLATE"
               : (action & DEFLATE ? "DEFLATE"
                                   : (action & INFLATE ? "INFLATE" : "ERROR"))),
          run_time_ms, comp_rate, comp_ratio, throughput);
      if (json != NULL) {
        fprintf(json, "{\"level\": \"%d\", \"type\": \"%s\", \"ratio\": \"%.2f\", \"throughput\": \"%.2f\", \"file\": \"%s\"},\n",
          comp_level_start, zlib_kind, comp_ratio, throughput, file_name);
      }
    }
    rewind(deflated);
    inf(deflated, out);
    fclose(inflated);
    fclose(deflated);
    comp_level_start++;
  }
  fclose(in);
  fclose(out);
  if (json) fclose(json);
}
