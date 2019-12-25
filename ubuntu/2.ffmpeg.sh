#!/bin/bash -e
echo 'Could run from docker images instead https://github.com/yoohahn/docker/tree/master/ffmpeg'
[ -z "${SANITY}" ] && echo "Add SANITY=X before running! Make sure first file has been executed and computer rebooted." && exit 1
[ -z "${HOME}" ] && echo "HOME not specified" && exit 1

FFMPEG_HOME=~/.ffmpeg-build
mkdir -p ~/.bin
mkdir -p $FFMPEG_HOME
mkdir -p $FFMPEG_HOME/ffmpeg_sources && mkdir -p $FFMPEG_HOME/ffmpeg_build
mkdir -p $FFMPEG_HOME/nv-codec-headers_build && cd $FFMPEG_HOME/nv-codec-headers_build
git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers
make && sudo make install

sudo apt-get update -qq && sudo apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  zlib1g-dev

cd $FFMPEG_HOME/ffmpeg_sources && \
wget https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.bz2 && \
tar xjvf nasm-2.14.02.tar.bz2 && \
cd nasm-2.14.02 && \
./autogen.sh && \
PATH="$HOME/.bin:$PATH" ./configure --prefix="$FFMPEG_HOME/ffmpeg_build" --bindir="$HOME/.bin" && \
make ; make install

cd $FFMPEG_HOME/ffmpeg_sources && \
wget -O yasm-1.3.0.tar.gz https://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz && \
tar xzvf yasm-1.3.0.tar.gz && \
cd yasm-1.3.0 && \
./configure --prefix="$FFMPEG_HOME/ffmpeg_build" --bindir="$HOME/.bin" && \
make ; make install

cd $FFMPEG_HOME/ffmpeg_sources && \
git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264.git && \
cd x264 && \
PATH="$HOME/.bin:$PATH" PKG_CONFIG_PATH="$FFMPEG_HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$FFMPEG_HOME/ffmpeg_build" --bindir="$HOME/.bin" --enable-static --enable-pic && \
PATH="$HOME/.bin:$PATH" make && \
make install

sudo apt-get install mercurial libnuma-dev -y && \
cd $FFMPEG_HOME/ffmpeg_sources && \
if cd x265 2> /dev/null; then hg pull && hg update && cd ..; else hg clone https://bitbucket.org/multicoreware/x265; fi && \
cd x265/build/linux && \
PATH="$HOME/.bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$FFMPEG_HOME/ffmpeg_build" -DENABLE_SHARED=off ../../source && \
PATH="$HOME/.bin:$PATH" make && \
make install

cd $FFMPEG_HOME/ffmpeg_sources && \
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac && \
cd fdk-aac && \
autoreconf -fiv && \
./configure --prefix="$FFMPEG_HOME/ffmpeg_build" --disable-shared && \
make && \
make install

cd $FFMPEG_HOME/ffmpeg_sources && \
wget -O lame-3.100.tar.gz https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz && \
tar xzvf lame-3.100.tar.gz && \
cd lame-3.100 && \
PATH="$HOME/.bin:$PATH" ./configure --prefix="$FFMPEG_HOME/ffmpeg_build" --bindir="$HOME/.bin" --disable-shared --enable-nasm && \
PATH="$HOME/.bin:$PATH" make && \
make install

cd $FFMPEG_HOME/ffmpeg_sources
git clone https://github.com/FFmpeg/FFmpeg.git
cd $FFMPEG_HOME/ffmpeg_sources/FFmpeg

PATH="$HOME/.bin:$PATH" PKG_CONFIG_PATH="$FFMPEG_HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$FFMPEG_HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$FFMPEG_HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$FFMPEG_HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="$HOME/.bin" \
  --enable-gpl \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
PATH="$HOME/.bin:$PATH" make -j 4 && \
make install ; hash -r

sudo wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | sudo apt-key add -
sudo add-apt-repository "deb https://mkvtoolnix.download/ubuntu/ $(lsb_release -cs) main"
sudo apt-get install mediainfo mediainfo-gui mkvtoolnix mkvtoolnix-gui -y

## Sanity cleanup
sudo apt-get update -y ; sudo apt-get upgrade -y ; sudo apt-get autoremove -y

exec $SHELL -l
ffmpeg -encoders 2>/dev/null | grep nvenc
