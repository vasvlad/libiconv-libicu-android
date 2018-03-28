#!/bin/sh

set -x

export BUILDDIR=`pwd`

NCPU=4
uname -s | grep -i "linux" && NCPU=`cat /proc/cpuinfo | grep -c -i processor`

NDK=`which ndk-build`
NDK=`dirname $NDK`
#NDK=`readlink -f $NDK`

for ARCH in armeabi-v7a; do

cd $BUILDDIR
mkdir -p $ARCH
cd $BUILDDIR/$ARCH

# =========== libandroid_support.a ===========

[ -e libandroid_support.a ] || {
mkdir -p android_support
cd android_support
ln -sf $NDK/sources/android/support jni

ndk-build -j$NCPU APP_ABI=$ARCH LIBCXX_FORCE_REBUILD=true || exit 1
cp -f obj/local/$ARCH/libandroid_support.a ../

} || exit 1

cd $BUILDDIR/$ARCH

# =========== libiconv.so ===========

#true || [ -e libiconv.so ] || {

	[ -e ../libiconv-1.14.tar.gz ] || curl -L http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz -o ../libiconv-1.14.tar.gz || exit 1

	tar xvf ../libiconv-1.14.tar.gz

	cd libiconv-1.14

	cp -f $BUILDDIR/config.sub build-aux/
	cp -f $BUILDDIR/config.guess build-aux/
	cp -f $BUILDDIR/config.sub libcharset/build-aux/
	cp -f $BUILDDIR/config.guess libcharset/build-aux/

	env CFLAGS="-I$NDK/sources/android/support/include" \
		LDFLAGS="-L$BUILDDIR/$ARCH -landroid_support" \
		$BUILDDIR/setCrossEnvironment-$ARCH.sh \
		./configure \
		--host=arm-linux-androideabi \
		--prefix=`pwd`/.. \
		--enable-static --enable-shared \
		|| exit 1

	env PATH=`pwd`:$PATH \
		$BUILDDIR/setCrossEnvironment-$ARCH.sh \
		make -j$NCPU V=1 || exit 1

	env PATH=`pwd`:$PATH \
		$BUILDDIR/setCrossEnvironment-$ARCH.sh \
		make V=1 install || exit 1

	cd ..

	for f in libiconv libcharset; do
		cp -f lib/$f.so ./
		$BUILDDIR/setCrossEnvironment-$ARCH.sh \
			sh -c '$STRIP'" $f.so"
	done

#} || exit 1

done # for ARCH in armeabi armeabi-v7a

exit 0
