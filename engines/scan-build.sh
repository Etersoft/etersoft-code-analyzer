#!/bin/sh

[ $(dirname $0) = "." ] && cd ../
. ./config.sh

epm assure scan-build clang-analizer

cd $REPO || fatal

# TODO: local path
LOGDIR=/var/ftp/pub/people/lav/coverage
#LOGDIR=scan-build-log
mkdir -p $LOGDIR || exit


jmake clean

export CC=clang
export CXX=clang++
export LINK=clang++

$CONFIGURECMD

# due  scan-build doesn't understand -isystem/DIR
# https://llvm.org/bugs/show_bug.cgi?id=13237
find -name "Makefile" | xargs subst "s|-isystem|-I|g"

# http://clang-analyzer.llvm.org/scan-build

PROJECT=$(basename $(pwd))
OPTIONS="$SCANBUILD_OPTS -o $LOGDIR/$PROJECT"

#scan-build $OPTIONS jmake
# TODO: почему jmake не работает?
# TODO: сделать jmake clang?
scan-build $OPTIONS make -j$NUMPROC CC=clang CXX=clang++ LINK=clang++
