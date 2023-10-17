#
# This is a semi complete emacs compile script for emacs (on master branch - currently 28.0.50). Please make pull requests if you find the apt install incomplete, or have updates for this.
#
# Currently tested on:
# 1. WSL 2 with Ubuntu 20.04.2 LTS (Focal Fossa)
#

git clone git://git.savannah.gnu.org/emacs.git ~/git/emacs

cd ~/git/emacs

git pull

sudo apt update
sudo apt install -y autoconf make gcc texinfo libgtk-3-dev libxpm-dev \
     libjpeg-dev libgif-dev libtiff5-dev libgnutls28-dev libncurses5-dev \
     libjansson-dev libharfbuzz-dev libharfbuzz-bin imagemagick libmagickwand-dev libgccjit-10-dev libgccjit0 gcc-10 libjansson4 libjansson-dev xaw3dg-dev texinfo libx11-dev

export CC="gcc-10"

./autogen.sh

./configure --with-native-compilation -with-json --with-modules --with-harfbuzz --with-compress-install \
   --with-threads --with-included-regex --with-x-toolkit=lucid --with-zlib --with-jpeg --with-png --with-imagemagick --with-tiff --with-xpm --with-gnutls \
   --with-xft --with-xml2 --with-mailutils

make -j 8
sudo make install
