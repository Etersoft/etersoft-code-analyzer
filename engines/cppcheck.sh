#!/bin/sh

[ $(dirname $0) = "." ] && cd ../
. ./config.sh

cd $REPO || fatal

# http://habrahabr.ru/post/210256/

cppcheck -q -j$NUMPROC $CPPCHECK_OPTS .

