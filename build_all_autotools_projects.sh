#!/bin/sh

# various options for cmake based builds:
# CMAKE_BUILD_TYPE can specify a build (debug|release|...) build type
# LIB_SUFFIX can set the ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}
#     useful fro 64 bit distros
# LXQT_PREFIX changes default /usr/local prefix
# LXQT_JOB_NUM Number of jobs to run in parallel while building. Defaults to
#   whatever nproc returns.
#
# example:
# $ LIB_SUFFIX=64 ./build_all.sh
# or
# $ CMAKE_BUILD_TYPE=debug CMAKE_GENERATOR=Ninja CC=clang CXX=clang++ ./build_all.sh
# etc.

if [ -n "$LXQT_JOB_NUM" ]; then
    JOB_NUM="$LXQT_JOB_NUM"
elif which nproc > /dev/null; then
    # detect processor numbers (Linux only)
    JOB_NUM=`nproc`
else
    # assume default job number of 1 (non-Linux systems)
    JOB_NUM=1
fi
echo "Make job number: $JOB_NUM"

if env | grep -q ^LXQT_PREFIX= ; then
	PREF="--prefix=$LXQT_PREFIX"
else
	PREF=""
fi

# autotools-based projects

# build libfm-extras
echo
echo
echo "Building: libfm extras into ${PREF:-<default>}"
echo
cd "libfm"
(./autogen.sh $PREF --enable-debug --without-gtk --disable-demo && ./configure $PREF --with-extra-only && make -j$JOB_NUM && sudo make install) || exit 1
cd ..


AUTOMAKE_REPOS=" \
	menu-cache \
	lxmenu-data"


for d in $AUTOMAKE_REPOS
do
	echo "\n\nBuilding: $d into ${PREF:-<default>}\n"
	cd "$d"
	(./autogen.sh && ./configure $PREF && make -j$JOB_NUM && sudo make install) || exit 1
	cd ..
done


# build libfm
echo
echo
echo "Building: libfm into ${PREF:-<default>}"
echo
cd "libfm"
(./autogen.sh $PREF --enable-debug --without-gtk --disable-demo && ./configure $PREF && make -j$JOB_NUM && sudo make install) || exit 1
cd ..
