#!/usr/bin/env bash
set -o errexit
set -o nounset
cd "$(dirname $0)"/../..

#
# Build and install xa65. When this stops working, check
# https://www.floodgap.com/retrotech/xa/dists/ for a newer version.
#

# XA_VERSION=2.3.13
XA_VERSION=$(wget --tries=1 -O - https://www.floodgap.com/retrotech/xa/dists/ 2>/dev/null | grep '"xa-[^"]*gz"' | sed -e 's,.*xa-,,' -e 's,.tar.gz.*,,' | sort -V | tail -n1)

if [ ! -e /usr/local/bin/xa65.exe ]
then
    pushd /usr/local
    mkdir -p src
    cd src
    wget https://www.floodgap.com/retrotech/xa/dists/xa-${XA_VERSION}.tar.gz
    tar -xzf xa-${XA_VERSION}.tar.gz
    cd xa-${XA_VERSION}
    make mingw install
    cp /usr/local/bin/xa.exe /usr/local/bin/xa65.exe
    popd
fi

ARGS="
    --disable-catweasel \
    --disable-hardsid \
    --disable-parsid \
    --disable-arch \
    --disable-pdf-docs \
    --with-png \
    --with-gif \
    --with-vorbis \
    --with-flac \
    --enable-ethernet \
    --enable-ipv6 \
    --enable-lame \
    --enable-midi \
    --enable-cpuhistory \
 	--enable-platformdox \
 	--enable-html-docs \
	--enable-rs232 \
	--enable-new8580filter \
	--with-fastsid \
	--with-resid \
	--enable-x64 \
	--enable-x64-image \
	--enable-realdevice \
	--enable-midi \
	--enable-rs232 \
	--with-mpg123 \
    "

#
#	--enable-debug \
#	--enable-native-gtk3ui \
#	--enable-debug-gtk3ui \
#	--enable-debug-threads \
#	--with-sdlsound \
#	--disable-hwscale \
#	--enable-libieee1284 \
#	--enable-embedded \
#	--enable-desktop-files \
#	--enable-quicktime \
#       --enable-ffmpeg \
#	--with-jpeg \
#	--enable-native-tools \
#	--disable-ssi2001 \
#	--enable-libx264 \
#

case "$1" in
GTK3)
    ARGS="--enable-gtk3ui $ARGS"
    ;;

SDL2)
    ARGS="--enable-sdl2ui $ARGS"
    ;;

SDL)
    ARGS="--enable-sdl1ui $ARGS"
    ;;

HLESS)
    ARGS="--enable-headlessui $ARGS"
    ;;
    
*)
    echo "Bad UI: $1"
    exit 1
    ;;
esac

echo WE ARE IN DIRECTORY: $PWD
./autogen.sh
./configure $ARGS || ( echo -e "\n**** CONFIGURE FAILED ****\n" ; cat config.log ; exit 1 )
make -j 8 -s
make bindist7zip
