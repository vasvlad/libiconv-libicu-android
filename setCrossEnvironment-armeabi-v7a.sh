#!/bin/sh

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
GCCPREFIX=arm-linux-androideabi
[ -z "$NDK_TOOLCHAIN_VERSION" ] && NDK_TOOLCHAIN_VERSION=4.9
[ -z "$PLATFORMVER" ] && PLATFORMVER=android-15
LOCAL_PATH=`dirname $0`
if which realpath > /dev/null ; then
	LOCAL_PATH=`realpath $LOCAL_PATH`
else
	LOCAL_PATH=`cd $LOCAL_PATH && pwd`
fi
ARCH=armeabi-v7a


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
$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
-target
armv7-none-linux-androideabi15
-march=armv7-a
-mfloat-abi=softfp
-mfpu=vfpv3-d16
-mthumb
-fpic
-fno-integrated-as
--sysroot $NDK/platforms/android-14/arch-arm
-isystem $NDK/sysroot/usr/include
-isystem $NDK/sysroot/usr/include/arm-linux-androideabi
-D__ANDROID_API__=15
$CFLAGS"

CFLAGS="`echo $CFLAGS | tr '\n' ' '`"

LDFLAGS="
-shared
--sysroot $NDK/platforms/android-14/arch-arm
$NDK/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a/libc++_static.a
$NDK/sources/cxx-stl/llvm-libc++abi/../llvm-libc++/libs/armeabi-v7a/libc++abi.a
$NDK/sources/android/support/../../cxx-stl/llvm-libc++/libs/armeabi-v7a/libandroid_support.a
$NDK/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a/libunwind.a
-latomic -Wl,--exclude-libs,libatomic.a
-gcc-toolchain
$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
-no-canonical-prefixes -target armv7-none-linux-androideabi14
-Wl,--fix-cortex-a8 -Wl,--exclude-libs,libunwind.a -Wl,--build-id -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--warn-shared-textrel -Wl,--fatal-warnings
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
