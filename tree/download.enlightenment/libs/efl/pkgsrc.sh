pkg_url="http://download.enlightenment.org/rel/libs/efl/efl-1.20.6.tar.xz"
pkg_ext="tar.xz"
pkg_rel=""
src_build="c"
src_prefix="/usr/local"
src_cflags="-O2 -ffast-math -march=native -g -ggdb3"
src_cxxflags=""
src_configure="--enable-systemd \
--disable-static --disable-tslib \
--enable-xinput22 \
--enable-multisense --enable-systemd \
--enable-image-loader-webp --enable-harfbuzz \
--enable-liblz4 \
--enable-drm --enable-elput"
