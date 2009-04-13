if [ $# -ne 1 ]; then
    echo "Usage: build_release.sh <version number>"
    exit 1
fi

APPNAME="statnot"
RELEASENAME=$APPNAME-$1

mkdir $RELEASENAME

cat LICENSE | sed s/CURVERSION/$1/g > $RELEASENAME/LICENSE
cat README | sed s/CURVERSION/$1/g > $RELEASENAME/README
cat config.mk | sed s/CURVERSION/$1/g > $RELEASENAME/config.mk
cat Makefile | sed s/CURVERSION/$1/g > $RELEASENAME/Makefile
cat statnot | sed s/CURVERSION/$1/g > $RELEASENAME/statnot

mkdir releases

tar cvzf releases/${RELEASENAME}.tar.gz $RELEASENAME

find . -name 'build_pkg.sh' -exec {} $1 \;

rm -rf $RELEASENAME

echo "Now upload release to web and git-hub"