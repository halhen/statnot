#!/bin/sh
#
# Generate stuff that goes onto the website
# Called by ../../build_release.sh and depends on its actions
# Will also run in it's directory
# $1 is version number
#
# TODO: update pkgrel somehow


APPNAME="statnot"
RELEASENAME=$APPNAME-$1

echo "Generating archlinux package for $APPNAME"
echo "Make sure pkgrel in PKGBUILD-template is set correctly"

MD5=`(md5sum releases/${RELEASENAME}.tar.gz | awk '{print $1}')`

mkdir -p releases/archlinux
cat pkg/archlinux/PKGBUILD-template | sed s/CURVERSION/$1/g | sed s/MD5SUM/$MD5/g > releases/archlinux/PKGBUILD

cd releases/archlinux/

makepkg -f --source
rm PKGBUILD

cd ../../