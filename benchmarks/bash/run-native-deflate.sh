#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ITERATIONS="5"
DATA_SIZE="100000000"
START_LEVEL="-2"
END_LEVEL="9"
DATE=`date "+%Y-%m-%d"`
OUT_DIR="/tmp/deflate-$DATE"
INPUT_FILES=()
while (( "$#" )); do
  case "$1" in
    -s|--start-level)
      if [ -n "$2" ]; then
        START_LEVEL=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -e|--end-level)
      if [ -n "$2" ]; then
        END_LEVEL=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -i|--iterations)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        ITERATIONS=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -d|--data-size)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        DATA_SIZE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -o|--output-dir)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        OUT_DIR=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      INPUT_FILES+=("$( cd "$( dirname "$1" )" >/dev/null 2>&1 && pwd )"/`basename $1`)
      shift
      ;;
  esac
done

mkdir -p $OUT_DIR
pushd $OUT_DIR
echo "Changing to $OUT_DIR"
echo "Running benchmarks from $MYDIR"

declare -A IMPL_ENV
declare -A IMPL_ARG

IMPL_ENV["zlib"]="LD_LIBRARY_PATH=$MYDIR/../../build/isa-l:$MYDIR/../../ipp/lib64 LD_PRELOAD=$MYDIR/../../build/zlib-madler/libz.so.1.2.11"
IMPL_ENV["chromium"]="LD_LIBRARY_PATH=$MYDIR/../../build/isa-l:$MYDIR/../../ipp/lib64 LD_PRELOAD=$MYDIR/../../build/zlib-chromium/libz.so"
IMPL_ENV["ng"]="LD_LIBRARY_PATH=$MYDIR/../../build/isa-l:$MYDIR/../../ipp/lib64 LD_PRELOAD=$MYDIR/../../build/zlib-ng/libz.so.1.2.11.zlib-ng"
IMPL_ENV["cloudflare"]="LD_LIBRARY_PATH=$MYDIR/../../build/isa-l:$MYDIR/../../ipp/lib64 LD_PRELOAD=$MYDIR/../../build/zlib-cloudflare/libz.so.1.2.8"
IMPL_ENV["jtkukunas"]="LD_LIBRARY_PATH=$MYDIR/../../build/isa-l:$MYDIR/../../ipp/lib64 LD_PRELOAD=$MYDIR/../../build/zlib-jtkukunas/libz.so.1.2.11.1-motley"
IMPL_ENV["ipp"]="LD_LIBRARY_PATH=$MYDIR/../../build/isa-l:$MYDIR/../../ipp/lib64 LD_PRELOAD=$MYDIR/../../build/zlib-ipp/libz.so.1.2.11"
IMPL_ENV["isal"]="LD_LIBRARY_PATH=$MYDIR/../../build/isa-l:$MYDIR/../../ipp/lib64"
IMPL_ARG["zlib"]=""
IMPL_ARG["chromium"]=""
IMPL_ARG["ng"]=""
IMPL_ARG["cloudflare"]=""
IMPL_ARG["jtkukunas"]=""
IMPL_ARG["ipp"]=""
IMPL_ARG["isal"]="-l"

for file in "${INPUT_FILES[@]}"; do
  for impl in "${!IMPL_ENV[@]}"; do
    bash -c "${IMPL_ENV[$impl]} $MYDIR/../../build/benchmarks/zbench \
             ${IMPL_ARG[$impl]} -n $ITERATIONS -d -c $START_LEVEL -c $END_LEVEL -p $DATA_SIZE \
             -j $impl -a $file -b /tmp/`basename $file`.zlib"
  done
done

popd
