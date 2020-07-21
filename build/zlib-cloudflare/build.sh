#!/bin/bash
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $MYDIR
OS=`uname`
if test "$OS" = "Darwin"; then
  CC=${CC:-clang}
else
  CC=${CC:-gcc}
fi
rm -f *o *.h *.pc *.a *.log *1 Makefile mini* example* libz* *.bat *.lib *.exp *.dll *.obj *.lo *.dylib
git -C ../../zlib-cloudflare checkout .
if [[ "$OS" == "CYGWIN"* ]]; then
  #
  # Very barebone, crappy, manual Windows build
  # Still needs to get the path to either "vcvars64.bat" or "VsDevCmd.BAT"
  # passed in via the "VS_ENV_CMD" environment variable.
  #
  # For Visual Studio 2017 the locations are:
  # C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat
  # C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\vsdevcmd.bat
  #
  patch -p1 --directory=../../zlib-cloudflare < build_on_windows.patch
  cp ../../zlib-cloudflare/zconf.h.in zconf.h
  SRC="adler32.c crc32.c gzclose.c gzread.c infback.c inflate.c trees.c zutil.c \
       compress.c deflate.c gzlib.c gzwrite.c inffast.c inftrees.c uncompr.c"
  if test "x$VS_ENV_CMD" = "x"; then
    echo "Must define VS_ENV_CMD to point to vcvars64.bat/vsdevcmd.bat of your Visual Studio installation"
    exit
  else
    VS_ENV_CMD_UNIX=$(cygpath -u "$VS_ENV_CMD")
    if [ ! -f "$VS_ENV_CMD_UNIX" ]; then
      echo "Can't open \"$VS_ENV_CMD\""
      echo "Can't open \"$VS_ENV_CMD_UNIX\""
      echo "VS_ENV_CMD must point to vcvars64.bat/vsdevcmd.bat of your Visual Studio installation"
      exit
    fi
    if [[ $VS_ENV_CMD == *"vcvars64"* ]]; then
      VS_ENV_CMD_ARG="amd64"
    else
      VS_ENV_CMD_ARG="-arch=amd64"
    fi
  fi
  MYDIR_WIN=`cygpath -m -l $MYDIR`
  echo "CALL \"$VS_ENV_CMD\" $VS_ENV_CMD_ARG" > compile.bat
  echo "ECHO ON" >> compile.bat
  for src in $SRC; do
    echo "cl -D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE -DWIN32 -DIAL \
          -nologo -MD -Zc:wchar_t- -DWINDOWS -DNDEBUG -W3 -wd4800 -D_LITTLE_ENDIAN \
          -DARCH='\"amd64\"' -Damd64 -D_AMD64_ -Damd64 -Z7 -d2Zi+ -DLIBRARY_NAME=zlib-cloudflare \
          -DHAS_SSE42 -D_WINDOWS -DZLIB_DLL -D_WINDLL -D__x86_64__ -wd4101 -wd4244 -wd4018 -WX -O2 \
          -I. -c $MYDIR_WIN/../../zlib-cloudflare/$src" >> compile.bat
  done
  echo "link.exe -nologo -opt:ref -incremental:no -dll -out:zlib.dll *.obj" >> compile.bat
  cmd /c compile.bat
else
  patch -p1 --directory=../../zlib-cloudflare < build_from_external_directory.patch
  CC=$CC ../../zlib-cloudflare/configure
  if test "$OS" = "Darwin"; then
    CC=$CC make libz.1.2.8.dylib
  else
    CC=$CC make libz.so.1.2.8
  fi
fi
git -C ../../zlib-cloudflare checkout .
popd
