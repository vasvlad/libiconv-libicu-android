#!/bin/bash

IFS='
'

MYARCH=linux-x86_64
if uname -s | grep -i "linux" > /dev/null ; then
	MYARCH=linux-x86_64
fi
if uname -s | grep -i "darwin" > /dev/null ; then
	MYARCH=darwin-x86_64
fi
if uname -s | grep -i "windows" > /dev/null ; then
	MYARCH=windows-x86_64
fi

NDK=`which ndk-build`
NDK=`dirname $NDK`
[ $(uname) = "Linux" ] && NDK=`readlink -f $NDK`

#echo NDK $NDK
GCCPREFIX=aarch64-linux-android
[ -z "$NDK_TOOLCHAIN_VERSION" ] && NDK_TOOLCHAIN_VERSION=4.9
[ -z "$PLATFORMVER" ] && PLATFORMVER=android-21
LOCAL_PATH=`dirname $0`
if which realpath > /dev/null ; then
	LOCAL_PATH=`realpath $LOCAL_PATH`
else
	LOCAL_PATH=`cd $LOCAL_PATH && pwd`
fi
ARCH=arm64-v8a


CFLAGS="
-fexceptions
-frtti
-ffunction-sections
-funwind-tables
-fstack-protector-strong
-Wno-invalid-command-line-argument
-Wno-unused-command-line-argument
-no-canonical-prefixes
-I$NDK/sources/cxx-stl/llvm-libc++/include
-I$NDK/sources/cxx-stl/llvm-libc++abi/include
-I$NDK/sources/android/support/include
-DANDROID
-Wa,--noexecstack
-Wformat
-Werror=format-security
-DNDEBUG
-O2
-g
-gcc-toolchain
$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
-target
aarch64-none-linux-android
-fpic
--sysroot $NDK/platforms/android-21/arch-arm64
-isystem $NDK/sysroot/usr/include
-isystem $NDK/sysroot/usr/include/aarch64-linux-android
-D__ANDROID_API__=21
$CFLAGS"

CFLAGS="`echo $CFLAGS | tr '\n' ' '`"

LDFLAGS="
-shared
--sysroot $NDK/platforms/android-21/arch-arm64
$NDK/sources/cxx-stl/llvm-libc++/libs/arm64-v8a/libc++_static.a
$NDK/sources/cxx-stl/llvm-libc++abi/../llvm-libc++/libs/arm64-v8a/libc++abi.a
$NDK/sources/android/support/../../cxx-stl/llvm-libc++/libs/arm64-v8a/libandroid_support.a
-latomic -Wl,--exclude-libs,libatomic.a
-gcc-toolchain $NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
-target aarch64-none-linux-android -no-canonical-prefixes
-Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel -Wl,--fatal-warnings
-lc -lm -lstdc++
$LDFLAGS"

LDFLAGS="`echo $LDFLAGS | tr '\n' ' '`"

CC="$NDK/toolchains/llvm/prebuilt/$MYARCH/bin/clang"
CXX="$NDK/toolchains/llvm/prebuilt/$MYARCH/bin/clang++"
CPP="$CC -E $CFLAGS"

env PATH=$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin:$LOCAL_PATH:$PATH \
CFLAGS="$CFLAGS" \
CXXFLAGS="$CXXFLAGS $CFLAGS -frtti -fexceptions" \
LDFLAGS="$LDFLAGS" \
CC="$CC" \
CXX="$CXX" \
RANLIB="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-ranlib" \
LD="$CC" \
AR="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-ar" \
CPP="$CPP" \
NM="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-nm" \
AS="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-as" \
STRIP="$NDK/toolchains/$GCCPREFIX-$NDK_TOOLCHAIN_VERSION/prebuilt/$MYARCH/bin/$GCCPREFIX-strip" \
"$@"
